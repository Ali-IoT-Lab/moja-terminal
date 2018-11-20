const path = require('path');
const child_process = require('child_process');
const operation = require("../common/operation")
function mojaOperation() {
  
}

mojaOperation.prototype.start=function () {
  child_process.exec(operation.start,function (error,stdout,stderr) {
    if(error || stderr) {
      console.log("start app with error: " + error + " ,stderr: " + stderr);
    }else{
      console.log(stdout);
    }
  })
}

mojaOperation.prototype.set_key=function (moja_key) {
  var cmd = `sh ${path.resolve(path.join(__dirname, "../scripts/set_key.sh"))} ${moja_key}`;
  child_process.exec(cmd, function (error, stdout, stderr) {
    if(error) {
      console.log("start app with error: " + error + " ,stderr: " + stderr);
    }else{
      console.log(stdout);
    }
  })
}

module.exports = new mojaOperation;