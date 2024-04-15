# finalproject-group1
This is the final year project of Cloud Automation and Control Systems

To start with the project we will start with cloning our repo.

to clone:

git clone git@github.com:ayush10-web/finalproject-group1.git


then to deploy dev:
  The first step is deploying its networks as:
  1. cd Module/aws_network
  2. terraform init
  3. terraform fmt
  4. terraform plan
  5. terraform apply

  The second step is deploying its web server as: 
  1. cd Module/aws_webserver
  2. ssh-keygen -t rsa -f "finalproject"
  3. terraform init
  4. terraform fmt
  5. terraform plan
  6. terraform apply

Similarly to deploying prod:
  The first step is deploying its networks as:
  1. cd Project/prod/network
  2. terraform init
  3. terraform fmt
  4. terraform plan
  5. terraform apply

  The second step is deploying its web server as: 
  1. cd Project/prod/webserver
  2. ssh-keygen -t rsa -f "finalproject"
  3. terraform init
  4. terraform fmt
  5. terraform plan
  6. terraform apply

Similarly to deploying staging:
  The first step is deploying its networks as:
  1. cd Project/staging/network
  2. terraform init
  3. terraform fmt
  4. terraform plan
  5. terraform apply

  The second step is deploying its web server as: 
  1. cd Project/staging/webserver
  2. ssh-keygen -t rsa -f "finalproject"
  3. terraform init
  4. terraform fmt
  5. terraform plan
  6. terraform apply




