# 🚀 Flask CI/CD Project - Containerized Web Application

A complete DevOps pipeline that automatically builds, tests, and deploys a Flask web application using Docker and GitHub Actions.

## 📋 Project Overview

This project demonstrates:
- **Containerization** with Docker
- **Continuous Integration/Continuous Deployment (CI/CD)** with GitHub Actions
- **Cloud Deployment** to AWS EC2 (or any Linux VM)
- **Infrastructure as Code** with Terraform (bonus)

## 🏗️ Architecture

```
Developer → GitHub → GitHub Actions → Docker Build → Test → Deploy to VM → Live Website
```

## 📁 Project Structure

```
flask-cicd-project/
├── app.py                    # Flask web application
├── requirements.txt          # Python dependencies
├── Dockerfile               # Container configuration
├── .github/workflows/       # CI/CD pipeline
│   └── deploy.yml          # GitHub Actions workflow
├── terraform/              # Infrastructure as Code (bonus)
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites
- Docker installed locally
- GitHub account
- AWS account (for cloud deployment)

### 1. Local Testing

```bash
# Clone the repository
git clone <your-repo-url>
cd flask-cicd-project

# Test Flask app locally
pip install -r requirements.txt
python app.py

# Test with Docker
docker build -t flask-app .
docker run -p 8080:5000 flask-app
curl http://localhost:8080
```

### 2. GitHub Setup

1. **Create GitHub Repository**
   - Create a new repository on GitHub
   - Push this code to your repository

2. **Configure GitHub Secrets**
   Go to your repository → Settings → Secrets and variables → Actions

   **Required Secrets:**
   - `SERVER_HOST`: Your VM's public IP address
   - `SERVER_USER`: SSH username (usually `ubuntu` for AWS EC2)
   - `SERVER_SSH_KEY`: Private SSH key content
   - `SERVER_PORT`: SSH port (default: 22)

   **Optional Secrets (for Docker Hub):**
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password/token

### 3. AWS EC2 Setup

#### Option A: Manual Setup
1. **Launch EC2 Instance**
   - AMI: Ubuntu 22.04 LTS
   - Instance Type: t2.micro (free tier)
   - Security Group: Allow SSH (22) and HTTP (80)

2. **Generate SSH Key Pair**
   ```bash
   # Create new key pair
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/flask-app-key
   
   # Add public key to EC2 instance
   # Copy content of ~/.ssh/flask-app-key.pub to EC2 authorized_keys
   ```

3. **Add Private Key to GitHub Secrets**
   ```bash
   # Copy private key content
   cat ~/.ssh/flask-app-key
   # Paste this content into SERVER_SSH_KEY secret
   ```

#### Option B: Terraform (Automated)
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## 🔄 CI/CD Pipeline Explained

### What Happens When You Push Code:

1. **Trigger**: Push to `main` branch
2. **Build Stage**:
   - Checkout code
   - Build Docker image
   - Tag with commit SHA
3. **Test Stage**:
   - Run container
   - Test HTTP endpoint
   - Verify response
4. **Deploy Stage** (only on main branch):
   - SSH into VM
   - Pull latest code
   - Build new Docker image
   - Stop old container
   - Start new container
   - Verify deployment

### GitHub Actions Workflow Breakdown:

```yaml
# .github/workflows/deploy.yml

# 1. Build and Test Job
build-and-test:
  - Builds Docker image
  - Tests container locally
  - Optionally pushes to Docker Hub

# 2. Deploy Job
deploy:
  - Only runs on main branch
  - SSHs into server
  - Deploys new version
  - Verifies deployment
```

## 🐳 Docker Explained

### Dockerfile Breakdown:
```dockerfile
FROM python:3.9-slim          # Base image with Python
WORKDIR /app                  # Set working directory
COPY requirements.txt .       # Copy dependencies first (for caching)
RUN pip install --no-cache-dir -r requirements.txt  # Install dependencies
COPY app.py .                 # Copy application code
CMD ["python", "app.py"]      # Command to run the app
```

### Why This Order?
- **Layer Caching**: Docker caches layers. By copying `requirements.txt` first, if only `app.py` changes, Docker won't reinstall packages.
- **Efficiency**: Faster builds and deployments.

## 🔧 Troubleshooting

### Common Issues:

1. **SSH Connection Failed**
   ```bash
   # Test SSH connection manually
   ssh -i ~/.ssh/flask-app-key ubuntu@<your-ec2-ip>
   ```

2. **Docker Build Failed**
   ```bash
   # Check Docker is running
   docker --version
   
   # Build locally to debug
   docker build -t flask-app .
   ```

3. **Container Won't Start**
   ```bash
   # Check container logs
   docker logs <container-name>
   
   # Run interactively to debug
   docker run -it flask-app /bin/bash
   ```

4. **Port Already in Use**
   ```bash
   # Find what's using the port
   lsof -i :5000
   
   # Kill the process
   kill -9 <PID>
   ```

## 📊 Monitoring & Verification

### Check Deployment Status:
```bash
# SSH into your server
ssh ubuntu@<your-ec2-ip>

# Check if container is running
sudo docker ps

# Check container logs
sudo docker logs flask-app

# Test the application
curl http://localhost
```

### Access Your Application:
- **Local**: http://localhost:8080
- **Production**: http://your-ec2-public-ip

## 🎯 Learning Objectives Achieved

✅ **Containerization**: Packaged app with Docker
✅ **CI/CD Pipeline**: Automated build, test, deploy
✅ **Cloud Deployment**: Running on AWS EC2
✅ **Infrastructure as Code**: Terraform scripts
✅ **DevOps Best Practices**: Version control, automation, monitoring

## 🚀 Next Steps

1. **Add HTTPS**: Use Let's Encrypt for SSL certificates
2. **Load Balancing**: Add multiple instances behind a load balancer
3. **Database**: Add PostgreSQL or MongoDB
4. **Monitoring**: Add Prometheus and Grafana
5. **Logging**: Centralized logging with ELK stack

## 📚 Technologies Used

- **Flask**: Python web framework
- **Docker**: Containerization platform
- **GitHub Actions**: CI/CD automation
- **AWS EC2**: Cloud virtual machine
- **Terraform**: Infrastructure as Code
- **Ubuntu**: Linux operating system

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

**Happy Coding! 🎉**

*This project demonstrates a complete DevOps pipeline from development to production deployment.* 