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
  if(option == '-k'){
    var buff = new Buffer(moja_key, 'base64');
    var publicKey = buff.toString();
  }else {
    var publicKey = moja_key;
  }
  child_process.exec(operation.set_key(option, publicKey), function (error, stdout, stderr) {
    if(error || stderr) {
      console.log("start app with error: " + error + " ,stderr: " + stderr);
    }else{
      if(option == '-k')
      {
        console.log('set public key success!');
      }
      if(option == '-e')
      {
        console.log('set public email success!');
      }
    }
  })
}

module.exports = new mojaOperation;