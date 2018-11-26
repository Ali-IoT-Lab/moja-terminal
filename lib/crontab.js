const path = require('path');
const child_process = require('child_process');

var cmd = `sh ${path.resolve(path.join(__dirname, "../scripts/preinstall.sh"))}`;
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
});
crontab.on("exit", (code, signal) => {
  if(!(code == 0||code==null)){
    console.log(uerr);
  }
});
setKey.on("close", (code, signal) => {

});