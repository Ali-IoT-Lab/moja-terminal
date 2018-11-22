const os     = require('os');
const p     = require('path');
module.exports = function() {
  var MOJA_HOME = p.join(os.homedir(),'.moja');
  var moja_terminal_file_stucture = {
    MOJA_VERSION             : p.resolve(MOJA_HOME, 'moja-version'),
    STARTPATH                : p.resolve(MOJA_HOME, 'client/start.js')
  };
  return moja_terminal_file_stucture;
};