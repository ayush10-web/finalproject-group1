# finalproject-group1
This is the final year project of Cloud Automation and Control Systems

To start with the project we will start by cloning our repo.

To clone:

Firstly setup the ssh key as:

ssh-keygen

Then copy the content of the key as:

cat /home/ec2-user/.ssh/id_rsa.pub

Then pass the ssh-key to the github

Now repo can be cloned by following the command:

git clone git@github.com:ayush10-web/finalproject-group1.git

Then we will be creating the s3 bucket: finalprojectacs

Then upload the pictures from the Images folder in the repo to the Images folder in the S3 bucket making it public 

Then pass the URL of each images onto the finalproject-group1/Module/aws_webserver/install_httpd.sh.tpl

Install the terraform:
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform


Then to deploy dev:
  The first step is deploying its networks as:
  1. cd finalproject-group1/Module/aws_network
  2. terraform init
  3. terraform fmt
  4. terraform plan
  5. terraform apply

  The second step is deploying its web server as: 
  1. cd finalproject-group1/Module/aws_webserver
  2. ssh-keygen -t rsa -f "finalproject" //to generate the public key
  3. terraform init
  4. terraform fmt
  5. terraform plan
  6. terraform apply

Similarly to deploying prod:
  The first step is deploying its networks as:
  1. cd finalproject-group1/Project/prod/network
  2. terraform init
  3. terraform fmt
  4. terraform plan
  5. terraform apply

  The second step is deploying its web server as: 
  1. cd finalproject-group1/Project/prod/webserver
  2. ssh-keygen -t rsa -f "finalproject" //to generate the public key
  3. terraform init
  4. terraform fmt
  5. terraform plan
  6. terraform apply

Similarly to deploying staging:
  The first step is deploying its networks as:
  1. cd finalproject-group1/Project/staging/network
  2. terraform init
  3. terraform fmt
  4. terraform plan
  5. terraform apply

  The second step is deploying its web server as: 
  1. cd finalproject-group1/Project/staging/webserver
  2. ssh-keygen -t rsa -f "finalproject" //to generate the public key
  3. terraform init
  4. terraform fmt
  5. terraform plan
  6. terraform apply




