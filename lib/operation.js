const path = require('path');
const os = require('os');
const child_process = require('child_process');
function mojaOperation() {
  
}

mojaOperation.prototype.start=function () {
  var HOME="";
  if (os.platform() == 'darwin'){HOME='Users'}
  if (os.platform() == 'linux'){HOME='home'}
  var cmd = `node /${HOME}/moja/.moja/client/start.js`;
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