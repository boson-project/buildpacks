'use strict';
const path      = require('path');
const { start } = require('faas-js-runtime');
const ON_DEATH  = require('death')({ uncaughtException: true });

const functionPath = extractFullPath(process.env.FUNCTION_PATH || process.env.FUNC_PATH || '../');
const code      = require(functionPath);

const options = {
  listenPort: process.env.FUNC_PORT,
  logLevel: process.env.FUNC_LOG_LEVEL,
  config: functionPath
}

let func;
if (typeof code === 'function') {
  func = code;
} else if (typeof code.handle === 'function') {
  func = code.handle;
} else {
  console.error(code);
  throw new TypeError(`Cannot find invokable function in ${code}`);
}

start(func, options)
  .then(server => {
    console.log('FaaS framework initialized');
    ON_DEATH(_ => { server.close(); });
  }).catch(err => {
    console.error(`Cannot load user function at ${functionPath}`);
    throw err;
  });

function extractFullPath(file) {
  if (path.isAbsolute(file)) return file;
  return path.join(process.cwd(), file);
}
