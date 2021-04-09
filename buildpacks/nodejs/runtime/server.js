'use strict';

const framework = require('faas-js-runtime');
const ON_DEATH = require('death')({ uncaughtException: true });

const functionPath = process.env.FUNCTION_PATH || '../';
const LISTEN_PORT = process.env.LISTEN_PORT || 8080;
const FUNCTION_LOG_LEVEL = process.env.FUNCTION_LOG_LEVEL || 'info'

try {
  framework(require(functionPath), LISTEN_PORT, server => {
    console.log('FaaS framework initialized');
    ON_DEATH(_ => { server.close(); });
  }, {
    logLevel: FUNCTION_LOG_LEVEL
  });
} catch (err) {
  console.error(`Cannot load user function at ${functionPath}`);
  throw err;
}
