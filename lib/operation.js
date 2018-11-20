const path = require('path');
const child_process = require('child_process');
function mojaOperation() {
  
}

mojaOperation.prototype.start=function () {
  var cmd = `sh ${path.resolve(path.join(__dirname, "../scripts/start.sh"))}`;
  child_process.exec(cmd,function (error,stdout,stderr) {
    if(error) {
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