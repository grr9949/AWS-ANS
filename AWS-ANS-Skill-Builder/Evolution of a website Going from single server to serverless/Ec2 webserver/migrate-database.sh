# put this in /var/www/html

echo "Renaming index.php to compute-index.php"
mv /var/www/html/index.php /var/www/html/compute-index.php

echo "Renaming serverless-index.php to index.php"
mv /var/www/html/serverless-index.php /var/www/html/index.php

echo "Restarting Apache"
sudo systemctl restart httpd