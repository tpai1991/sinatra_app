# Introduction
This guide will instruct the user on how to deploy an ec2 instance to host a Sinatra application from REAGroup's GitHub. Please follow the instructions to set up your local machine and install the required tools before proceeding with deploying the application.

The tools used in this guide are: 
- Terraform (infrastructure deployment)
- Windows Subsystem for Linux (WSL) is enabled to run Ansible
- Ansible (infrastructure configuration)

The reason I have chosen these tools are because they are platform agnostic and open source with wide community backing and resources available to provide information on tasks I want to complete. In this instance, deploying a Virtual Machine (VM) is quite a common infrastructure task and Terraform was able to perform this task quite easily. Also configuring VMs regarding packaging, firewalls, and service management is quite simple using Ansible. This will be shown later in the guide.

## Set Up - Terraform
---
1. Download the Terraform installer from the following link: https://www.terraform.io/downloads.html (choose installer relevant to your OS). In this case, I am using a 64-bit Windows 10 machine and I downloaded the 64-bit Windows Installer.
2. Unzip the Terraform package and move file to desired location.
3. Configure environment variables for Terraform: 
   - Navigate to: This PC(MyComputer)—>properties —>advanced system settings–>environment variables—>system variables—>path–edit–>new
   - Add the path where the Terraform package resides.
4. Check that Terraform works by checking the version running the following command in your terminal: "terraform version"

## Set Up - WSL
---
1. Press the Windows Start key on the keyboard.
2. Type "Turn Windows Features on or off".
3. Select the "Windows Subsystem for Linux" checkbox.
4. Windows will download and install required files. Once this is done, click the "Restart Now" button to apply changes.
5. After the PC restarts, download the Linux distribution of your choice on the Microsoft Store app. In this case, I downloaded Ubuntu 20.04 LTS. Launch the application.

## Set Up - Ansible
---
1. Run the Ubuntu app you just downloaded.
2. Set up your credentials (username/password).
3. Log in to your Ubuntu app.
4. Run an update of all packages on OS by running the following command: 
   `sudo apt-get update`
5. Install the "software-properties-common" package: `sudo apt-get install software-properties-common`
6. Add the required repository for installing Ansible: `sudo apt-add-repository ppa:ansible/ansible`
7. Install Ansible: `sudo apt-get install ansible`

## Infrastructure Deployment (Terraform/AWS)
---
1. There are two terraform (.tf) files included in the repository:
   - The "provider.tf" defines the platform to which we are configuring resources. Configure the provider file with your AWS account's access key and secret key
     
        `terraform {`
        
            required_providers {
                
                aws = {
                    source = "hashicorp/aws"
                    version = "~> 3.0"
                }
            }
        `}`

        `provider "aws" {` 
            
            access_key  = "$(your_access_key)"
            secret_key  = "$(your_secret_key)"
            region      = "ap-southeast-2"
        `}`
   - The "rhel-ec2.tf" file defines the resources that will be created (security group, ec2 instance, key-pair). In my terraform file I have configured the owner to be redhat and I am provisioning a RHEL8.4 VM. This was chosen because I am comfortable using redhat systems.
2. In your project directory containing the terraform files, run the following commands:

    `terraform init` - To initialize terraform

    `terraform plan` - To preview infrastructure changes

    `terraform apply` - To deploy the infrastructure on AWS

Log into the VM from your local PC using public/private key pair used when provisioning the VM. Ensure the public and private key are available in your home directory as follows:

`ls /home/$USER/.ssh`

output: `id_rsa id_rsa.pub known_hosts`

Log in via the VM's public ip address using the following command: `ssh -i ~/.ssh/id_rsa ec2-user@x.x.x.x`

## Infrastructure Configuration (Ansible)
---
1. Configure the inventory file in your home directory on your local linux subsystem:
   
   `~$ vi inventory`

    Add the following entry:

    `[ec2]`
    
    `{public_ip_of_vm}`

2. Run ansible playbook on linux subsystem
   
   `~$ ansible-playbook -i inventory sinatra.yml`

## Install Passenger + Nginx to Deploy Sinatra Application
---
1. Ansible has already installed the passenger gem. This will enable you as the user to run the passenger installer for the nginx module. The installer is a guided process requiring you to select options at the prompt. The Ansible playbook should have also enabled the right permissions on the default destination where nginx will be installed. Therefore, now you just have to run the following command to start the passenger installer for nginx:

    `[ec2-user@web-sinatra ~]$ cd sinatra`
    
    `[ec2-user@web-sinatra sinatra]$ passenger-install-nginx-module`

    At the prompt select `Ruby` as the choice of language. Press Enter.

    At the next prompt enter `1` as the option for the installer to install nginx.

2. At this point the installer will have installed and configured the /opt/nginx/conf/nginx.conf file for you. Now make some minor adjustments for your application as mentioned below:

    Add the following directive to set the environment for passenger in the `http {...}` block:
    
    `passenger_app_env development;`

    Edit the `/opt/nginx/conf/nginx.conf` file and delete/comment the following directives in the `location / {...}` block:

    `# root html;`

    `# index index.html index.htm`

    Add the following lines instead:

    `root /home/ec2-user/sinatra/public;`

    `passenger_enabled on;`

    `proxy_pass http://127.0.0.1:9292;`

    The final line mentioned above is used to pass inbound requests on port 80 to port 9292 where the sinatra application will run.

3. Start the nginx server by running `sudo /opt/nginx/sbin/nginx`

4. Run the sinatra application by running the following commands in the `/home/ec2-user/sinatra` directory:

    `[ec2-user@web-sinatra sinatra]$ bundle install`

    `[ec2-user@web-sinatra sinatra]$ bundle exec rackup`

    The application will run on port 9292, but the nginx webserver has been configured to pass requests on port 80 to port 9292

5. Test the application by running your local browser and entering the public ip of the VM in the URL. You will see "Hello World!" served. 

---
## Summary
The files provided in this repository will set up the environment and server on AWS to host the rails application provided in this exercise. It is automated to the point of passenger + nginx installation and configuration. For even greater simplicity, these steps should also be automated as part of provisioning. For security considerations, at the time of deployment, the security group was configured as only allowing ssh and http inbound connections, while allowing all outbound connections. On the VM itself, the firewall is allowing ssh and port 80/tcp traffic. The settings for the webserver could be tuned further for performance and security reasons. However, the guide provided should enable the app to be deployed and work as expected.
