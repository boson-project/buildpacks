import sys
import os

from flask import Flask, request
from cloudevents.http import from_http

serverDir = os.path.dirname(__file__)
funcDir = os.path.realpath(os.path.join(serverDir, ".."))
sys.path.append(funcDir)

import func

app = Flask(__name__)

# create an endpoint at localhost:3000

@app.route("/", methods=["POST"])
def handler():
  # create a CloudEvent
  event = from_http(request.headers, request.get_data())
  return func.main(event)

if __name__ == "__main__":
  app.run(port=8080)