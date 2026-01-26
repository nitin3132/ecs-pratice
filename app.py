from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.get("/")
def home():
    return "Hello from ECS behind ALB!\n"

@app.get("/api")
def api():
    return jsonify(service="demo", env=os.getenv("ENV", "dev"))

@app.get("/health")
def health():
    return "ok\n", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
