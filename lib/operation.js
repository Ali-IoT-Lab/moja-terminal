const fs = require('fs');
const path = require('path');
const request = require('request');
const child_process = require('child_process');
const Base64 = require('js-base64').Base64;
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
    var resoPath = path.resolve(filePath);
    var fileName = path.basename(resoPath);
    request({
      method: 'PUT',
      preambleCRLF: true,
      postambleCRLF: true,
      uri: `${hostName}/api/remote-terminal/terminal/file/${Base64.encode(fileName)}`,
      formData:{
        file: {
          value:  fs.createReadStream(resoPath),
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
