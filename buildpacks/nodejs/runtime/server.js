'use strict';

const framework = require('@redhat/faas-js-runtime');

const functionPath = process.env.FUNCTION_PATH || '../';
const LISTEN_PORT = process.env.LISTEN_PORT || 8080;

let server;

module.exports.close = function close() {
  if (server) server.close();
};

try {
  framework(require(functionPath), LISTEN_PORT, srv => {
    console.log('FaaS framework initialized');
    server = srv;
  });
} catch (err) {
  console.error(`Cannot load user function at ${functionPath}`);
  throw err;
}
