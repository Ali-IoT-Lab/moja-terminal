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
    if(error) {
      console.log("start app with error: " + error + " ,stderr: " + stderr);
    }else{
      console.log(stdout);
    }
  })
}

mojaOperation.prototype.set_key=function (moja_key) {
  var cmd = `sh ${path.resolve(path.join(__dirname, "../scripts/set-key.sh"))} ${moja_key}`;
  child_process.exec(cmd, function (error, stdout, stderr) {
    if(error) {
      console.log("start app with error: " + error + " ,stderr: " + stderr);
    }else{
      console.log(stdout);
    }
  })
}

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
}

module.exports = new mojaOperation;