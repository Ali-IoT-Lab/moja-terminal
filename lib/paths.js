const os     = require('os');
const p     = require('path');

function getMojaPath() {
  var HOME="";
  if (os.platform() == 'darwin'){HOME='Users'}
  if (os.platform() == 'linux'){HOME='home'}
  return HOME;
}

module.exports = function() {
  var MOJA_HOME = p.join('/',getMojaPath(),'moja','.moja');
  var moja_terminal_file_stucture = {
    MOJA_VERSION             : p.resolve(MOJA_HOME, 'moja-version'),
    STARTPATH                : p.resolve(MOJA_HOME, 'client/start.js'),
  };
  return moja_terminal_file_stucture;
};