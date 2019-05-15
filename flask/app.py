from flask import Flask, request,jsonify
from datetime import datetime as dt
import uuid

app = Flask(__name__)

@app.route('/')
def index():
  return(
    jsonify(
      {
        'Message': 'Hello World!',
        'current_date_time': dt.now().strftime('%m/%d/%Y, %H:%M:%S')
      }
    )
  )

@app.route('/uuid/')
def generate_uuid():
  return(
    jsonify({
      'uuid': uuid.uuid4()
    })
  )

if(__name__ == '__main__'):
  app.run(
    debug=True,
    host='0.0.0.0'
  )
