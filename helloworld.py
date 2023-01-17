# print hello world on port 5000
from flask import Flask

app = Flask(__name__)

@app.route('/')
def helloIndex():
    return 'Hello World from DevOps!'

app.run(host='0.0.0.0', port=5000)
