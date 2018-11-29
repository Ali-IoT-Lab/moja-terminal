const fs = require('fs');
const path = require('path');
const http = require('http');
const Base64 = require('js-base64').Base64;
const child_process = require('child_process');
const paths = require('./paths');
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

mojaOperation.prototype.download=function (file) {
  var req = http.get(`http://47.97.210.118?uploadPath=${Base64.encode(path.resolve(file))}`,function (res) {
    var str = '';
    res.on('data',function (trunk) {
      str += trunk;
    })
    res.on('end',function () {
      console.log(str);
    })
  });
  req.on('error',function (error) {
    console.log('error: ' + error)
  });
  req.end();
};

module.exports = new mojaOperation;