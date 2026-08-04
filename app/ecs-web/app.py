from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

APP_VERSION = os.getenv("APP_VERSION", "v1")


@app.route("/")
def home():
    return f"""
    <html>
      <head><title>AWS SRE ECS Lab</title></head>
      <body>
        <h1>AWS ECS Lab</h1>
        <p>Phase 2A containerized Flask app running successfully.</p>
        <p>Version: {APP_VERSION}</p>
        <p>Hostname: {socket.gethostname()}</p>
      </body>
    </html>
    """
    
@app.route("/health")
def health():
    return jsonify({
      "status": "healthy",
      "version": APP_VERSION,
      "hostname": socket.gethostname()
    })
    
@app.route("/version")
def version():
    return jsonify({
      "version": APP_VERSION
    })
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)