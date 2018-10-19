const child_process = require("child_process");
const io = require('socket.io-client');
const fs = require("fs");
const os = require("os");
const pty = require('node-pty');
const crypto = require('crypto');
const version = require('./version/moja-version.js').version;
var HOME="";
if (os.platform() == 'darwin'){HOME='Users'}
if (os.platform() == 'linux'){HOME='home'}
const terminalId = require('/'+HOME+'/moja/.moja/terminalId.js');
const userId = require('/'+HOME+'/moja/.moja/userId.js');
var publicKey="";
if(fs.existsSync('/'+HOME+'/moja/.moja/publicKey.js')){
  publicKey = require('/'+HOME+'/moja/.moja/publicKey.js').publicKey;
}
const email = require('/'+HOME+'/moja/.moja/email.js').email;
const config = require('./config/config.js');
const getExecShellLog = require('./lib/getExecShellLog.js');
const msmonit = require('./lib/monitor');
/* 非信任证书免认证 */
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0';
var idPath = '/'+HOME+'/moja/.moja';
var eth0MacAddress = "", eth0IPAddress = "", wlan0MacAddress = "", wlan0IPAddress = "", totalDf = 0, usedDf = 0, availDf = 0, productModel = "",terminalIdTmp="",userIdTmp="";
var terminal = {}, logs = {},closeCommMsg = {};
var topListData = [],totalUsage = [],g_updateStatus ={};

setTimeout(function () {
  var oldVersion = fs.readFileSync("/"+HOME+"/moja/.moja/moja-version").toString().replace(/(\r|\n)/gi, "");
  if(oldVersion != version) {
    child_process.execSync("sh ./operation/killApp.sh "+version);
    child_process.execSync("echo > /"+HOME+"/moja/.moja/stage");
  }
},2000);

try {
  usedDf = child_process.execSync('echo `df -k  |grep -w "/"|awk -F \' \'  \'{print $3}\'`').toString().trim();
  availDf = child_process.execSync('echo `df -k  |grep -w "/"|awk -F \' \'  \'{print $4}\'`').toString().trim();
  totalDf = parseInt(usedDf) + parseInt(availDf);
  productModel = os.hostname();
  netInterInfo = os.networkInterfaces();
  if(os.platform() == 'linux') {
    netInterInfo.eth0 && (eth0MacAddress = netInterInfo.eth0[0].mac);
    netInterInfo.eth0 && (eth0IPAddress = netInterInfo.eth0[0].address);
    netInterInfo.wlan0 && (wlan0MacAddress = netInterInfo.wlan0[0].mac);
    netInterInfo.wlan0 && (wlan0IPAddress = netInterInfo.wlan0[0].address);
  }
  if(os.platform() == 'darwin'){
    //netInterInfo.eth0 && (eth0MacAddress = netInterInfo.en0[0].mac);
    //netInterInfo.eth0 && (eth0IPAddress = netInterInfo.en0[0].address);
    netInterInfo.en0 && (wlan0MacAddress = netInterInfo.en0[1].mac);
    netInterInfo.en0 && (wlan0IPAddress = netInterInfo.en0[1].address);
  }
} catch (error) {
  console.error('[' + (new Date()) + '] Init variable with ERROR: ' + error);
}
var macAddr = JSON.stringify({
  eth0: eth0MacAddress,
  wlan0: wlan0MacAddress
});
var ip = JSON.stringify({
  eth0IPAddress: eth0IPAddress,
  wlan0IPAddress: wlan0IPAddress,
});
terminalIdTmp = terminalId;
userIdTmp = userId;

var controlQuery = "&totalDf="+totalDf+"&usedDf="+usedDf +"&productModel="+productModel+"&macAddr="+macAddr+"&ip="+ip;
var timestamp = Date.now();
var authorize = {
  "reconnect":false,
  "email": email,
  "timestamp": timestamp,
  "terminalId":terminalId,
  "ticket": crypto.publicEncrypt(publicKey, Buffer.from(email + '-' + timestamp))
};
var controlRequestUrl = config.httProtocol+ config.HOST +"?type="+config.CONTROLPATH+controlQuery;
var commandRequestUrl = config.httProtocol + config.HOST +"?type="+config.COMMNDPATH;
if (publicKey.length !== 0) {
  controlRequestUrl+="&key=public"+"&version="+version;
  commandRequestUrl+="&key=public";
}
const socket = io(controlRequestUrl,{
  secure:true,
  reconnection:true,
  reconnectionAttempts:8643, //超过24 小时不再重连
  rejectUnauthorized: false,
  reconnectionDelayMax:10000,
  reconnectionDelay:800,
  randomizationFactor:0.1,
  transports:['websocket', 'polling'],
  extraHeaders: {
    authorize:JSON.stringify(authorize)
  }
});
 socket.on('reconnect_attempt',()=> {
   authorize['terminalId'] = terminalIdTmp;
   socket.io.opts.extraHeaders = {
     authorize:JSON.stringify(authorize),
   }
 });
socket.on('error', (error) => {
  console.error('[' + (new Date()) + ' Control] Connect error  ' + controlRequestUrl + " With " + JSON.stringify(arguments[0]));
});
socket.on('connect_error', (data) => {
  console.error('[' + (new Date()) + ' Control] Connect connect_error  ' + controlRequestUrl + " With " + JSON.stringify(arguments[0]));
});
socket.on('message', (MSG) => {
  console.log('[' + (new Date()) + ' Control] Client receive message ' + JSON.stringify(MSG));
  try {
    var message = JSON.parse(MSG);
  } catch (error) {
    console.error('[' + (new Date()) + ' Control] Client receive message with error: ' + error);
    return;
  }
  if (message.Type == "closeEvent") {
    if (message.opType == 1) {
      var tmPid = message.data.pid;
      closeCommMsg[tmPid]=message;
      socket.send(JSON.stringify({Type:'closeEvent',opType:1,userId:message.data.userId,pid:tmPid}));
    }
  }else if(message.Type == "execScript"){
    if (message.opType == 1) {
      var termId = message.terminalId, time = message.time, shellId = message.shellId, userIdm = message.userId;
      var topic = userIdm + termId + time;
      getExecShellLog.getShellExecLog(termId,shellId,userIdm,function (err, result) {
        socket.emit(topic,JSON.stringify({Type: "execScript", result:result}))
      })
    }
  }else if (message.Type == "terminal") {
    var terminObj = message.data;
    if (message.opType == 1) {
      var cols = terminObj.cols, rows = terminObj.rows, pid = terminObj.pid;
      socket.send(JSON.stringify({type: 'terminal', opType: 1, userId: userIdTmp}));
      if (!terminal[pid]) {
//---------------------------------------次处单独封装后现象为：主动触发disconnect没反应 间隔30s断开(disconnect)重连---------------------------------------------------
        var socketComm = io(commandRequestUrl+"&pid="+pid+"&version="+version+"&terminalId="+terminalIdTmp,{
          secure: true,
          reconnection:true,
          reconnectionAttempts:8643, //超过24 小时不再重连
          rejectUnauthorized: false,
          reconnectionDelayMax:10000,
          reconnectionDelay:300,
          randomizationFactor:0.5,
          transports:['websocket', 'polling'],
          extraHeaders: {
            authorize:JSON.stringify(authorize)
          }
        });
        socketComm.on('reconnect_attempt',()=> {
          authorize['reconnect'] = true;
            socketComm.io.opts.extraHeaders = {
              authorize:JSON.stringify(authorize),
            }
        });
        socketComm.on('error', (error) => {
          console.error('[' + (new Date()) + ' Command] Connect error  ' + commandRequestUrl + " With " + JSON.stringify(arguments[0])+", pid from server: " + pid);
        });
        socketComm.on('connect_error', (data) => {
          console.error('[' + (new Date()) + ' Command] Connect connect_error  ' + commandRequestUrl + " With " + JSON.stringify(arguments[0])+", pid from server: " + pid);
        });
        socketComm.on('message', (msg) => {
          console.log('[' + (new Date()) + ' Command] Client receive message ' +msg+", pid from server: " + pid);
          try {
            terminal[pid].write(msg);
          } catch (error) {
            console.error('[' + (new Date()) + ' Command] Terminal write msg with error: ' + error+", pid from server: " + pid);
          }
        });
        socketComm.on('connect', () => {
          authorize['reconnect']=false;
          console.log('[' + (new Date()) + ' Command] Client Connected With URL ' + commandRequestUrl+", pid from server: " + pid);
          if (!terminal[pid]) {
            terminal[pid] = pty.spawn(process.platform === 'win32' ? 'cmd.exe' : 'bash', [], {
              name: 'xterm-color',
              cols: cols || 80,
              rows: rows || 24,
              cwd: "/"+HOME+"/moja",
              env: process.env
            });
            terminal[pid].on('data', (data) => {
              logs[pid] += data;
              socketComm.send(data);
            });
          }
          console.log('[' + (new Date()) + ' Command] Created terminal with PID: ' + terminal[pid].pid+", pid from server: " + pid);
          //socketComm.send(logs[pid]||"moja@"+os.hostname());
          //socket失去连接时触发（包括关闭浏览器，主动断开，掉线等任何断开连接的情况)
        });
        socketComm.on('disconnect', () => {
          console.log('[' + (new Date()) + ' Command] Connection Closed by server pid: ' + pid+", pid from server: " + pid);
          if(closeCommMsg[pid] && closeCommMsg[pid].Type == "closeEvent"){
            terminal[pid].kill();
            delete closeCommMsg[pid];
            delete terminal[pid];
            delete logs[pid];
          }
        })
//---------------------------------------------------------------------------------------------
      }
    }
  }else if (message.Type == "terminalId") {
    var terminObj = message.data;
    terminalIdTmp = terminObj.terminalId;
    userIdTmp =terminObj.userId;
    fs.writeFileSync(idPath+'/terminalId.js', "exports = module.exports = "+'"'+terminObj.terminalId+'"'+';');
    fs.writeFileSync(idPath+'/userId.js', "exports = module.exports = "+'"'+terminObj.userId+'"'+';');
  }else if (message.Type == "delete") {
    var cmd = ["sh","./operation/uninstall.sh " + version,"2 > /"+HOME+"/moja/.moja/uninstall.log"].join(" ");
    var unIsntall = child_process.exec(cmd, { maxBuffer : 10000 * 1024 });
    var uout = "", uerr = "";
    unIsntall.stdout.on("data", (trunk) => {
      uout += trunk;
    });
    unIsntall.stderr.on("data", (trunk) => {
      uerr += trunk;
    });
    unIsntall.on("error", (error) => {
      console.error('[' + (new Date()) + ' error delete operation] exec operation  with error: ' + error+" ,terminalId: "+ terminObj.terminalId +" ,userId: " + userIdTmp);
    });
    unIsntall.on("exit", (code, signal) => {
      console.log('[' + (new Date()) + ' exit delete operation] exit operation with code: ' + code+" ,stdout: " + uout + " ,stderr: " + uerr+" ,terminalId: "+ terminObj.terminalId+" ,userId: " + userIdTmp);
    });
    unIsntall.on("close", (code, signal) => {
      console.log('[' + (new Date()) + ' close delete operation] close operation with code: ' + code+" ,terminalId: "+ terminObj.terminalId+" ,userId: " + userIdTmp);
    });
  }else if (message.Type == "upgrade") {
    var terminObj = message.data;
    var cmd = ["sh","./operation/upgrade.sh " + terminObj.version,"2 > /"+HOME+"/moja/.moja/update.log"].join(" ");
    var updateShell = child_process.exec(cmd, { maxBuffer : 10000 * 1024 });
    var uout = "", uerr = "";
    g_updateStatus = {Type:"progress",isUpdateCompelete:true,result:false,logString:"",terminalId:terminalIdTmp,userId:userIdTmp};
    updateShell.stdout.on("data", (trunk) => {
      uout += trunk;
    });
    updateShell.stderr.on("data", (trunk) => {
      uerr += trunk;
    });
    updateShell.on("error", (error) => {
      g_updateStatus.isUpdateCompelete = false;
      g_updateStatus.logString = error;
      console.error('[' + (new Date()) + ' error upgrade operation] exec operation with error: ' + error+" ,terminalId: "+ terminObj.terminalId+" ,userId: " + userIdTmp);
    });
    updateShell.on("exit", (code, signal) => {
      console.log('[' + (new Date()) + ' exit upgrade operation] exit operation with code: ' + code+" ,stdout: " + uout + " ,stderr: " + uerr+" ,terminalId: "+ terminObj.terminalId+" ,userId: " + userIdTmp);
      g_updateStatus.isUpdateCompelete = false;
      if(code ==0 || code == null) {
        g_updateStatus.logString = "upgrade success!";
        g_updateStatus.result = true;
      }else {
        g_updateStatus.logString = fs.readFileSync("/"+HOME+"/moja/.moja/update.log").toString();
        g_updateStatus.result = false;
      }
    });
    updateShell.on("close", (code, signal) => {
      console.log('[' + (new Date()) + ' close upgrade operation] close operation with code: ' + code+" ,terminalId: "+ terminObj.terminalId+" ,userId: " + userIdTmp);
    })

    var updateTimer = setInterval(function(){
      var stage = fs.readFileSync("/"+HOME+"/moja/.moja/stage").toString().replace(/(\r|\n)/gi, "");
      g_updateStatus.progress = stage;
      socket.send(JSON.stringify(g_updateStatus));
      if(!g_updateStatus.isUpdateCompelete){
        g_updateStatus.isUpdateCompelete = true;
        clearInterval(updateTimer);
      }
    },500)

  }else {
    console.log('[' + (new Date()) + ' Control] Received Unknown Websocket Message: ' + MSG);
    socket.send(JSON.stringify({message: {errorCode: 1}, userId: userIdTmp}));
  }
});
socket.on('connect', () => {
  console.log('[' + (new Date()) + ' Control] Client Connected With URL ' + controlRequestUrl);
});
socket.on('disconnect', () => {
  console.error('[' + (new Date()) +  ' Control] Connect disconnect  ' + controlRequestUrl + " With " + JSON.stringify(arguments[0]));
})
setInterval(function () {
  if(userIdTmp.length != 0 && terminalIdTmp.length != 0) {
    msmonit.taskList(function (error,topList) {
      topListData.push(topList);
    });
    msmonit.totalUsage(function(err,usage){
      totalUsage.push(usage);
    })
  }
},1000*5);
setInterval(function () {
  if(userIdTmp.length != 0 && terminalIdTmp.length !=0) {
    msmonit.sendData(JSON.stringify({"userId":userIdTmp,"terminalId":terminalIdTmp,"topListData":topListData,"totalUsage":totalUsage,"cpuCode":msmonit.cpuCode()}),function(){
      topListData.length = 0;
      totalUsage.length = 0;
    });
  }
},1000*60);


