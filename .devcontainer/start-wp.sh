#!/bin/bash

echo "🔧 Starting WordPress Development Environment..."
echo ""

# Start services
echo "📦 Starting MariaDB..."
sudo service mariadb start

echo "🌐 Starting Apache..."
sudo service apache2 restart

# Wait a moment for services to fully start
sleep 3

# Check if WordPress is responding
echo "🧪 Testing WordPress..."
if curl -s --connect-timeout 5 http://localhost:8000 >/dev/null; then
    echo "✅ WordPress is responding!"
    
    # Activate custom theme if available
    if [ -d "themes/epdc-base" ]; then
        echo "🎨 Activating epdc-base theme..."
        cd /var/www/html
        wp theme activate epdc-base
    fi
    
    echo ""
    echo "🎉 WordPress is ready!"
    echo "🌐 Website: http://localhost:8000"
    echo "👤 Admin: http://localhost:8000/wp-admin"
    echo "   Username: admin"
    echo "   Password: password"
    echo ""
else
    echo "❌ WordPress is not responding. Check the logs:"
    echo "📋 Apache logs: sudo tail -20 /var/log/apache2/error.log"
    echo "🔍 WordPress debug: Check wp-config.php for debugging options"
fi