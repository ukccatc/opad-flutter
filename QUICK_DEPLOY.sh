#!/bin/bash

# Quick Email Backend Deployment Script
# Usage: ./QUICK_DEPLOY.sh username@opad.com.ua

if [ -z "$1" ]; then
    echo "Usage: ./QUICK_DEPLOY.sh username@opad.com.ua"
    exit 1
fi

SSH_HOST=$1
REMOTE_PATH="~/public_html/api"

echo "🚀 Starting Email Backend Deployment..."
echo "📍 Target: $SSH_HOST:$REMOTE_PATH"
echo ""

# Step 1: Upload files
echo "📤 Uploading backend files..."
scp backend/EmailConfig.php "$SSH_HOST:$REMOTE_PATH/"
scp backend/EmailService.php "$SSH_HOST:$REMOTE_PATH/"
scp backend/composer.json "$SSH_HOST:$REMOTE_PATH/"
scp backend/.env.example "$SSH_HOST:$REMOTE_PATH/"
scp backend/api.php "$SSH_HOST:$REMOTE_PATH/"

echo "✅ Files uploaded"
echo ""

# Step 2: Install Composer and PHPMailer
echo "📦 Installing Composer and PHPMailer..."
ssh "$SSH_HOST" << 'EOSSH'
cd ~/public_html/api

# Check if composer exists
if ! command -v composer &> /dev/null; then
    echo "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    php composer.phar install
else
    echo "Composer found, installing dependencies..."
    composer install
fi

echo "✅ Composer and PHPMailer installed"
EOSSH

echo ""

# Step 3: Create .env file
echo "⚙️  Creating .env file..."
echo ""
echo "Please enter your SMTP credentials:"
read -p "SMTP Host (default: mail.opad.com.ua): " SMTP_HOST
SMTP_HOST=${SMTP_HOST:-mail.opad.com.ua}

read -p "SMTP Port (default: 587): " SMTP_PORT
SMTP_PORT=${SMTP_PORT:-587}

read -p "SMTP User (default: noreply@opad.com.ua): " SMTP_USER
SMTP_USER=${SMTP_USER:-noreply@opad.com.ua}

read -sp "SMTP Password: " SMTP_PASSWORD
echo ""

ssh "$SSH_HOST" << EOSSH
cd ~/public_html/api

cat > .env << 'EOF'
SMTP_HOST=$SMTP_HOST
SMTP_PORT=$SMTP_PORT
SMTP_SECURE=false
SMTP_USER=$SMTP_USER
SMTP_PASSWORD=$SMTP_PASSWORD
SMTP_FROM_EMAIL=$SMTP_USER
SMTP_FROM_NAME=OPAD - Одеська обласна профспілка авіадиспетчерів

DB_HOST=s19.thehost.com.ua
DB_USER=opad2016
DB_PASSWORD=opad2016
DB_NAME=opad

PORT=8000
NODE_ENV=production
EOF

chmod 600 .env
echo "✅ .env file created and secured"
EOSSH

echo ""

# Step 4: Test email service
echo "🧪 Testing email service..."
ssh "$SSH_HOST" << 'EOSSH'
cd ~/public_html/api

cat > test_email.php << 'EOF'
<?php
require 'vendor/autoload.php';
require 'EmailConfig.php';
require 'EmailService.php';

try {
    $emailService = new EmailService();
    echo "✅ Email service initialized successfully\n";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
EOF

php test_email.php
rm test_email.php
EOSSH

echo ""

# Step 5: Verify installation
echo "✅ Verifying installation..."
ssh "$SSH_HOST" << 'EOSSH'
cd ~/public_html/api

echo "📁 Backend files:"
ls -lh EmailConfig.php EmailService.php api.php .env 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'

echo ""
echo "📦 PHPMailer installation:"
if [ -d "vendor/phpmailer/phpmailer" ]; then
    echo "  ✅ PHPMailer installed"
else
    echo "  ❌ PHPMailer not found"
fi

echo ""
echo "🔐 File permissions:"
ls -l .env | awk '{print "  .env: " $1}'
EOSSH

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Test API endpoint:"
echo "   curl -X POST https://opad.com.ua/api/email/send-welcome \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"email\": \"your_email@example.com\", \"name\": \"Test User\"}'"
echo ""
echo "2. Check email logs:"
echo "   ssh $SSH_HOST 'tail -f /var/log/mail.log'"
echo ""
echo "3. For more details, see DEPLOY_EMAIL_BACKEND.md"
echo ""
