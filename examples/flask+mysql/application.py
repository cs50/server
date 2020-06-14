import os

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from werkzeug.middleware.proxy_fix import ProxyFix

# Application
app = Flask(__name__)

# Database
app.config["SQLALCHEMY_DATABASE_URI"] = "mysql://{}:{}@{}/{}".format(
    os.environ["MYSQL_USERNAME"], os.environ["MYSQL_PASSWORD"], os.environ["MYSQL_HOST"], os.environ["MYSQL_DATABASE"])
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db = SQLAlchemy(app)

# ProxyFix
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1)  # http://stackoverflow.com/a/23504684/5156190


@app.route("/")
def hello():
    rows = db.session.execute("SELECT 'hello, world'")
    return rows.first()[0]
