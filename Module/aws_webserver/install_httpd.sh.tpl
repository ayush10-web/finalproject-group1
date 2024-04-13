#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1> We are Group 1.  Private IP is $myip this is hosted in private subnet. </h1><br> Group Members:
<ul>
    <li>Ayush Nepal</li>
    <li>Sandesh Maharjan</li>
</ul> <br>
The Images are:
<img src="https://finalprojectacs.s3.amazonaws.com/pictures/cat.jpeg" alt="pussycat">"  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd