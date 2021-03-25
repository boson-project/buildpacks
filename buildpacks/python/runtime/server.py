import sys
import os

from flask import Flask, request
from cloudevents.http import from_http
from waitress import serve

serverDir = os.path.dirname(__file__)
funcDir = os.path.realpath(os.path.join(serverDir, ".."))
sys.path.append(funcDir)

import func

app = Flask(__name__)

@app.route("/", methods=["POST"])
def handle_post():
  context = {
    'request': request
  }
  try:
    context['cloud_event'] = from_http(request.headers, request.get_data())
  except Exception:
    app.logger.warning('No CloudEvent available')
  return func.main(context)

@app.route("/", methods=["GET"])
def handle_get():
  context = {
    'request': request
  }
  return func.main(context)

@app.route("/health/liveness")
def liveness():
  return "OK"

@app.route("/health/readiness")
def readiness():
  return "OK"

if __name__ == "__main__":
  serve(app, host='0.0.0.0', port=8080)
