# DEFINE ALL YOUR VARIABLES HERE

instance_type = "t3.large"
ami           = "ami-0f8a61b66d1accaee" # Ubuntu 24.04
key_name      = "<pem_key>-key"    # Replace with your key-name without .pem extension
volume_size   = 50
region_name   = "us-east-1"
server_name   = "JENKINS-SERVER"

# Note: 
# a. First create a pem-key manually from the AWS console
# b. Copy it in the same directory as your terraform code