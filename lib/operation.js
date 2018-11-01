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

mojaOperation.prototype.set_key=function (option, moja_key) {
  child_process.exec(operation.set_key(option, moja_key), function (error, stdout, stderr) {
    if(error || stderr) {
      console.log("start app with error: " + error + " ,stderr: " + stderr);
    }else{
      if(option == '-k')
      {
        console.log('set user key success!');
      }
    }
  })
}

module.exports = new mojaOperation;