# print hello world on port 5000
from flask import Flask
from flask import render_template

app = Flask(__name__,  static_folder='static')

@app.route('/')
def helloIndex():
    return render_template(
        'home2.html',
        title="Jinja Demo Site",
        description="Smarter page templates with Flask & Jinja."
    )

app.run(host='0.0.0.0', port=443)