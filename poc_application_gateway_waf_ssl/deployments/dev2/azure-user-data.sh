#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo ufw disable
echo "<html>VIRTUAL MACHINE = #XXX#</html>" > /var/www/html/index.html
sudo service apache2 restart