#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1> We are Group 1.  Private IP is $myip this is hosted in private subnet. </h1><br> Group Members:
<ul>
    <li>Ayush Nepal</li>
    <li>Sandesh Maharjan</li>
</ul> <br>
The Images are: <br>
<img src="https://finalprojectacs.s3.amazonaws.com/Images/ilovedogs.jpg" height="50" width="50" alt="dog"> 
<img src="https://finalprojectacs.s3.amazonaws.com/Images/ilovecats.jpg" height="50" width="50" alt="cat">" >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd