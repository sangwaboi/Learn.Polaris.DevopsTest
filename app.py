from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from your containerized Flask app! ~Deployed via CI/CD"
    return "can you hear me?"
    

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
