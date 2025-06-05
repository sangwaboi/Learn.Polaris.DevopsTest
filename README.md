# Flask CI/CD Project

Simple Flask app with Docker containerization.

## What I Did

- Created a Flask app that returns "Hello from your containerized Flask app!"
- Containerized it with Docker
- Set up CI/CD with GitHub Actions

## Run Locally

```bash
pip install -r requirements.txt
python app.py
# Visit http://localhost:5000
```

## Docker

```bash
# Build
docker build -t flask-app .

# Run
docker run -p 8080:5000 flask-app
# Visit http://localhost:8080
```

## Files

- `app.py` - Flask app
- `Dockerfile` - Container setup
- `requirements.txt` - Dependencies
- `.github/workflows/` - CI/CD pipeline
