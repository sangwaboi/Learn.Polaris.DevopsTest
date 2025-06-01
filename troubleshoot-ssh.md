# SSH Connection Troubleshooting Guide

## Current Issue
The GitHub Actions workflow is failing to connect to the EC2 instance via SSH with the error:
```
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain
```

## Troubleshooting Steps

### 1. Verify EC2 Instance Status
Check if your EC2 instance is still running:
- Go to AWS Console → EC2 → Instances
- Verify instance `i-xxxxx` is in "running" state
- Check the public IP is still `65.0.61.182`

### 2. Check Security Group
Ensure your security group allows SSH access:
- Go to EC2 → Security Groups
- Find your security group
- Verify inbound rules include:
  - Type: SSH, Protocol: TCP, Port: 22, Source: 0.0.0.0/0

### 3. Verify SSH Key
The SSH key might be corrupted or mismatched. Try these steps:

#### Option A: Test SSH locally
```bash
# Test from your local machine
ssh -i ~/Downloads/flask-app-key.pem -o StrictHostKeyChecking=no ubuntu@65.0.61.182 "echo 'test'"
```

#### Option B: Regenerate SSH Key
If the above fails, you may need to:
1. Stop the EC2 instance
2. Detach the current key pair
3. Create a new key pair
4. Attach the new key pair
5. Start the instance
6. Update GitHub secrets with the new key

### 4. Alternative: Create New EC2 Instance
If the issue persists, create a fresh EC2 instance:

1. **Launch new instance:**
   - AMI: Ubuntu 22.04 LTS
   - Instance type: t2.micro
   - Create new key pair: `flask-app-key-new.pem`
   - Security group: Allow SSH (22) and HTTP (80)

2. **Update GitHub secrets:**
   - SERVER_HOST: [new public IP]
   - SERVER_SSH_KEY: [content of new .pem file]

3. **Test connection:**
   ```bash
   ssh -i flask-app-key-new.pem ubuntu@[NEW_IP] "echo 'connection test'"
   ```

### 5. GitHub Secrets Verification
Ensure your GitHub secrets are correctly set:
- `SERVER_HOST`: Public IP of EC2 instance
- `SERVER_USER`: ubuntu
- `SERVER_PORT`: 22
- `SERVER_SSH_KEY`: Complete content of .pem file (including headers)

### 6. Common Issues and Solutions

#### Issue: "Permission denied (publickey)"
- **Cause**: SSH key doesn't match the instance
- **Solution**: Regenerate key pair or create new instance

#### Issue: "Connection timeout"
- **Cause**: Security group blocking SSH
- **Solution**: Update security group rules

#### Issue: "Host key verification failed"
- **Cause**: Host key mismatch
- **Solution**: Use StrictHostKeyChecking=no (already implemented)

## Quick Fix Commands

### Test SSH connection locally:
```bash
ssh -v -i ~/Downloads/flask-app-key.pem ubuntu@65.0.61.182 "whoami"
```

### Check if instance is reachable:
```bash
ping 65.0.61.182
```

### Verify key format:
```bash
head -1 ~/Downloads/flask-app-key.pem
# Should show: -----BEGIN RSA PRIVATE KEY-----
```

## Next Steps
1. Try the local SSH test first
2. If it fails, create a new EC2 instance with a fresh key pair
3. Update GitHub secrets with new credentials
4. Re-run the workflow

## Updated Workflow Features
The latest workflow now includes:
- SSH connection test before deployment
- Better error handling
- Reduced debug output for cleaner logs
- Connection timeout settings 