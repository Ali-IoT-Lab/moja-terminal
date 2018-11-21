var chalk  = require('chalk');
module.exports = {
    PREFIX_MSG              : chalk.green('[moja] '),
    PREFIX_MSG_ERR          : chalk.red('[moja][ERROR] '),
    PREFIX_MSG_MOD          : chalk.bold.green('[moja][Module] '),
    PREFIX_MSG_MOD_ERR      : chalk.red('[moja][Module][ERROR] '),
    PREFIX_MSG_WARNING      : chalk.yellow('[moja][WARN] '),
    PREFIX_MSG_SUCCESS      : chalk.cyan('[moja] '),
    SUCCESS_EXIT            : 0,
    ERROR_EXIT              : 1,
    CODE_UNCAUGHTEXCEPTION  : 1,
    LOGS_BUFFER_SIZE        : 8,
    CONTEXT_ON_ERROR        : 2,
};

