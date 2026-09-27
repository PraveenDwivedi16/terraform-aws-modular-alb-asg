#!/bin/bash
# Update OS and install Nginx
yum update -y
yum install -y nginx

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Fetch instance metadata using IMDSv2 (AWS security best practice)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

# Create dynamic load-balanced landing page
cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Production AWS Auto-Scaled Web Cluster</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0f172a; color: #f8fafc; text-align: center; padding: 50px; }
        .card { background: #1e293b; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.5); max-width: 600px; margin: 0 auto; padding: 30px; border: 1px solid #334155; }
        h1 { color: #38bdf8; font-size: 24px; margin-bottom: 5px; }
        .badge { background: #10b981; color: white; padding: 4px 12px; border-radius: 9999px; font-weight: bold; font-size: 14px; display: inline-block; margin-bottom: 20px; }
        .metric-table { width: 100%; border-collapse: collapse; margin-top: 20px; text-align: left; }
        .metric-table td { padding: 12px; border-bottom: 1px solid #334155; }
        .metric-table td.label { font-weight: bold; color: #94a3b8; }
        .metric-table td.value { color: #f1f5f9; font-family: monospace; font-size: 15px; }
        .footer { margin-top: 25px; color: #64748b; font-size: 13px; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 High-Availability Web Cluster</h1>
        <div class="badge">${environment} ENVIRONMENT</div>
        <p>Traffic distributed across Multi-AZ via AWS Application Load Balancer.</p>
        <table class="metric-table">
            <tr><td class="label">Instance ID:</td><td class="value">$${INSTANCE_ID}</td></tr>
            <tr><td class="label">Availability Zone:</td><td class="value">$${AZ}</td></tr>
            <tr><td class="label">Private IP:</td><td class="value">$${PRIVATE_IP}</td></tr>
            <tr><td class="label">Managed By:</td><td class="value">Terraform Modular Architecture</td></tr>
        </table>
        <div class="footer">Automated Auto Scaling Group & Application Load Balancer Architecture</div>
    </div>
</body>
</html>
EOF
