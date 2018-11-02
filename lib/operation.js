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
  child_process.exec(operation.set_key(moja_key), function (error, stdout, stderr) {
    if(error || stderr) {
      console.log("start app with error: " + error + " ,stderr: " + stderr);
    }else{
      console.log(stdout);
    }
  })
}

module.exports = new mojaOperation;