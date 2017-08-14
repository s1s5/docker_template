# coding: utf-8
from __future__ import absolute_import
from __future__ import unicode_literals
from __future__ import print_function

from flask import Flask
app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Flask Dockerized'


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
