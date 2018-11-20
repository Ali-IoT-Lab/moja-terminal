module.exports = {
  set_key: function (moja_key) {
    return `#!/bin/bash
    moja_key=` + moja_key + `
    HOME_DIR=""
    touch ~/.moja
    osType=\`uname -s|tr '[A-Z]' '[a-z]'\`
    if [ $osType = "darwin" ] ;then
      HOME_DIR='Users'
    fi
    
    if [ $osType = "linux" ] ;then
      HOME_DIR='home'
    fi
    echo "PPPopeuwrpouwpoeuropuwqepruqwuerpuqwpeuropuqweopruquwerqwe"
    echo `+moja_key
  }
}
