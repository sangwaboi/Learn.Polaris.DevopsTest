# Flask CI/CD Project

Simple Flask app with containerization and automated deployment.

## What's This?

- Flask web app that returns "Hello from your containerized Flask app!"
- Dockerized for consistent deployment
- Multiple deployment options (Render, Vercel, Heroku, AWS)
- CI/CD pipeline with GitHub Actions

## Local Development

```bash
# Clone and run locally
git clone https://github.com/sangwaboi/Learn.Polaris.DevopsTest.git
cd flask-cicd-project
pip install -r requirements.txt
python app.py
# Visit http://localhost:5000
```

## Docker

```bash
# Build and run with Docker
docker build -t flask-app .
docker run -p 8080:5000 flask-app
# Visit http://localhost:8080
```

## Deployment Options

### 🚀 Render (Recommended)
1. Go to [render.com](https://render.com)
2. Connect GitHub repo
3. Render auto-deploys using `render.yaml`

### ⚡ Vercel
1. Go to [vercel.com](https://vercel.com)
2. Import GitHub repo
3. Uses `vercel.json` config

### 🟣 Heroku
1. Create Heroku app
2. Add `HEROKU_API_KEY` to GitHub secrets
3. Uses `Procfile` and GitHub Actions

## Files

- `app.py` - Flask application
- `Dockerfile` - Container config
- `requirements.txt` - Python dependencies
- `render.yaml` - Render deployment config
- `vercel.json` - Vercel deployment config
- `Procfile` - Heroku deployment config
- `.github/workflows/` - CI/CD pipelines

## Live URL

Once deployed, your app will be available at the URL provided by your chosen platform.
