const fs = require('fs');
const path = require('path');
const request = require('request');
const child_process = require('child_process');
const paths = require('./paths');
const hostName="http://47.97.210.118";
function mojaOperation() {
  
}

mojaOperation.prototype.start=function () {
  var version = fs.readFileSync(paths().MOJA_VERSION).toString().trim();
  var cmd = `node ${paths().STARTPATH} ${version} npm`;
  child_process.exec(cmd,function (error,stdout,stderr) {
    if(error || stderr) {
      console.log(error+stderr);
    }else{
      console.log(stdout);
    }
  })
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
    console.log('file not exist!')
  }else {
    function callback(error, response, body) {
      if(error){
        console.log(error)
      }else if(response.statusCode !== 200){
        console.log('Error Code: ' + response.statusCode)
      }else {
        console.log('请点击下载：url' + body)
      }
    }
    var resoPath = path.resolve(filePath);
    var fileName = path.basename(resoPath);
    var base64Name = Buffer.from(fileName,'base64').toString();
    fs.createReadStream(resoPath).pipe(request.put(`${hostName}/terminal/file/${base64Name}`,callback))
  }
};

module.exports = new mojaOperation;