const fs = require('fs');
const path = require('path');
const request = require('request');
const child_process = require('child_process');
var log = require('single-line-log').stdout;
const Base64 = require('js-base64').Base64;
const config = require('../config/config.js');
const hostName=config.hostname;

function mojaOperation() {

}

mojaOperation.prototype.start=function () {
  var cmd = `sh ${path.resolve(path.join(__dirname, "../scripts/start.sh"))}`;
  var setKey = child_process.exec(cmd, { maxBuffer : 10000 * 1024 });
  var uout = "", uerr = "";
  setKey.stdout.on("data", (trunk) => {
    uout += trunk;
  });
  setKey.stderr.on("data", (trunk) => {
    uerr += trunk;
  });
  setKey.on("error", (error) => {
    console.log(error);
  });
  setKey.on("exit", (code, signal) => {
    console.log(uerr+' ,' +uout )
  });
  setKey.on("close", (code, signal) => {

  });
}

mojaOperation.prototype.init=function () {
  var cmd = `sh ${path.resolve(path.join(__dirname, "../scripts/init.sh"))}`;
  var setKey = child_process.exec(cmd, { maxBuffer : 10000 * 1024 });
  var uout = "", uerr = "";
  setKey.stdout.on("data", (trunk) => {
    uout += trunk;
    var tmp = trunk.replace('npm',"").replace('fetch',"").replace('http',"");
    if(tmp.indexOf('https') > -1){
      log('npm http fetch GET '+tmp);
    }else {
      console.log()
      log(trunk.replace(/[\r\n]/g,""));
    }
  });
  setKey.stderr.on("data", (trunk) => {
    uerr += trunk;
    var tmp = trunk.replace('npm',"").replace('fetch',"").replace('http',"");
    if(tmp.indexOf('https') > -1){
      log('npm http fetch GET '+tmp);
    }else {
      console.log()
      log(trunk.replace(/[\r\n]/g,""));
    }
  });
  setKey.on("error", (error) => {
    console.log(error);
  });
  setKey.on("exit", (code, signal) => {

  });
  setKey.on("close", (code, signal) => {

  });
}
mojaOperation.prototype.stop=function () {
  var cmd = `sh ${path.resolve(path.join(__dirname, "../scripts/stop.sh"))}`;
  var setKey = child_process.exec(cmd, { maxBuffer : 10000 * 1024 });
  var uout = "", uerr = "";
  setKey.stdout.on("data", (trunk) => {
    uout += trunk;
  });
  setKey.stderr.on("data", (trunk) => {
    uerr += trunk;
  });
  setKey.on("error", (error) => {
    console.log(error);
  });
  setKey.on("exit", (code, signal) => {
    console.log(uerr+' ,' +uout )
  });
  setKey.on("close", (code, signal) => {

  });
}

mojaOperation.prototype.set_key=function (moja_key) {
  var cmd = `sh ${path.resolve(path.join(__dirname, "../scripts/set-key.sh"))} ${moja_key}`;
  var setKey = child_process.exec(cmd, { maxBuffer : 10000 * 1024 });
  var uout = "", uerr = "";
  setKey.stdout.on("data", (trunk) => {
    uout += trunk;
    console.log(trunk)
  });
  setKey.stderr.on("data", (trunk) => {
    uerr += trunk;
    console.log(trunk)
  });
  setKey.on("error", (error) => {
    console.log(error);
  });
  setKey.on("exit", (code, signal) => {

  });
  setKey.on("close", (code, signal) => {

  });
};

mojaOperation.prototype.download=function (filePath) {
  if(!fs.existsSync(path.resolve(filePath))){
    console.log('File not exist!');
  } else if(fs.statSync(path.resolve(filePath)).size > 100*1024*1024){
    console.log('Max upload is 100MB!');
  }else {
    var flag = true;
    var read = 0;
    var resoPath = path.resolve(filePath);
    var fileName = path.basename(resoPath);
    var size = fs.statSync(resoPath).size;
    var rdfs = fs.createReadStream(resoPath);
    rdfs.on('data', function(data) {
      read += data.length;
      var percentage = Math.floor(100*read/size)+'%';
      if(flag) {
        flag = false;
        log(percentage);
      }else {
        log('\r\r\r');
        log(percentage);
      }
    });
    request({
      method: 'PUT',
      preambleCRLF: true,
      postambleCRLF: true,
      uri: `${hostName}/api/remote-terminal/terminal/file/${Base64.encode(fileName)}`,
      formData:{
        file: {
          value: rdfs,
           options: {
           filename: resoPath,
           contentType: 'multipart/form-data'
          }
        }
      }
    },
      function (error, response, body) {
        if (error) {
          console.error(error);
        }else if(response.statusCode !== 200){
          console.log('Error Code: ' + response.statusCode)
        }else {
          console.log('请点击下载: ', body);
        }
      })
   }
};

module.exports = new mojaOperation;
