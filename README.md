# Automate the provision of a Consul cluster using terrafrom

1. We have used AWS for hosting our solution
2. For operating our infrastructure we have setup a HA Consul cluster distributed over at least 3
  availability zones i.e. (in my case) us-east-1
3. The setup and maintenance should be fully automated and consul instances are discovered themselves using DNS
4. Once code is provisioned on cloud. We can access consul cluster using ELB DNS address which will be pointing to backend consul cluster of 3 nodes
5. We have tested our code by provisioning a sample service which auto discovers on consul cluster


# Task - What steps have we taken so far.
> I have also faced some issue during the code creation. Hope it may help you when you do it at your end. 

* Let's start !!!
1. Setup your AWS account and get Access and Secret key and integrate it with "aws cli configure" command. So that terrafrom can start contacting with cloud provider via cli mode.
2. Below are the listed file which consist code of deploying consul cluster which will be provisioned on EC2 (t2.micro). I am running consul on container to save my time and joining rest of the nodes as well using EC2's private IP.
instances.tf  -- Instance specifications
main.tf -- Executioner file
security_group.tf -- Maintain security group for Ingress and Egress rules
subnet.tf -- File to segregate the subnets
variable.tf -- Defined variables which will be used in other files
vpc.tf -- File to create isolated consul cluster space

## Below are the steps to implement it. 
1. Clone the code from public repository.

``` git clone https://github.com/manukoli1986/tf_consul_aws.git```
2. Go inside directory and initiate terraform

```#cd tf_consul_aws/consul_aws/```

3. You will find below output once command is executed. 

```$xslt
#terrafrom init
Initializing modules...
- frontend in instance

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (terraform-providers/aws) 2.25.0...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.25"

# terraform plan -- (To check code is valid and can be executed without any failures)

# terrafrom apply -auto-approve  --  (Command to execute code with auto-approve comment)
aws_vpc.consul: Creating...
aws_key_pair.mayank-user: Creating...
aws_vpc.consul: Still creating... [10s elapsed]
aws_key_pair.mayank-user: Still creating... [10s elapsed]
aws_key_pair.mayank-user: Creation complete after 13s [id=mayank-user]
aws_vpc.consul: Still creating... [20s elapsed]
aws_vpc.consul: Still creating... [30s elapsed]
aws_vpc.consul: Still creating... [40s elapsed]
aws_vpc.consul: Still creating... [50s elapsed]
aws_vpc.consul: Still creating... [1m0s elapsed]
aws_vpc.consul: Still creating... [1m10s elapsed]
aws_vpc.consul: Still creating... [1m20s elapsed]
aws_vpc.consul: Creation complete after 1m26s [id=vpc-0a0875d9ff58cc46f]
aws_security_group.consul: Creating...
aws_subnet.consul_1: Creating...
......
.....
Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

Outputs:

frontend_address = elb-public-frontend-1307923329.us-east-1.elb.amazonaws.com
ips1 = [
  "3.227.9.49",
]
ips2 = [
  "3.95.150.101",
]
ips3 = [
  "54.90.198.151",
]

```

4. You will see above output and will receive a "frontend address" url to access consul cluster dashboard. (If you do not get error)

![alt text](https://github.com/manukoli1986/tf_consul_aws/blob/master/consul_aws/images/1.jpg)
![alt text](https://github.com/manukoli1986/tf_consul_aws/blob/master/consul_aws/images/2.jpg)


## Testing 

* Let's deploy any microsevice on docker on any one of the host and it will be shown up in consul cluster UI. This will be done by Registrator service which is a handy utility which will automatically register any new services we run to Consul.
* We run a goofy sample microservice (which registrator will register for us)
```
We have relaunched the code to run sample service on consul node. 
Below are new ELB DNS URL.
Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

Outputs:

frontend_address = elb-public-frontend-429445632.us-east-1.elb.amazonaws.com
ips1 = [
  "3.210.185.163",
]
ips2 = [
  "52.87.180.255",
]
ips3 = [
  "34.236.152.140",
]


>> Lets connect to anyone ec2 and deploy service.

# ssh -i /vagrant/mayank-user ec2-user@3.210.185.163
The authenticity of host '3.210.185.163 (3.210.185.163)' can't be established.
ECDSA key fingerprint is ac:5f:27:08:fd:e0:91:fc:61:2f:9f:f4:80:06:83:d9.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '3.210.185.163' (ECDSA) to the list of known hosts.
Last login: Sun Aug 25 20:26:19 2019 from 112.196.159.228

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
4 package(s) needed for security, out of 12 available
Run "sudo yum update" to apply all updates.
[ec2-user@ip-10-0-1-100 ~]$ sudo su -
[root@ip-10-0-1-100 ~]# docker run -d -p 5000:5000 dwmkerr/zapp-service
8268ab0762f7044bdc43c9061409eb0e569c26a71b41640585ea409d47db2e06
[root@ip-10-0-1-100 ~]# docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED              STATUS              PORTS                    NAMES
8268ab0762f7        dwmkerr/zapp-service            "python app.py"          About a minute ago   Up About a minute   0.0.0.0:5000->5000/tcp   agitated_jepsen
9bd917f8956a        gliderlabs/registrator:latest   "/bin/registrator co…"   12 minutes ago       Up 11 minutes                                registrator
9a68a91237ks        consul                          "docker-entrypoint.s…"   12 minutes ago       Up 12 minutes                                competent_edison
```

![alt text](https://github.com/manukoli1986/tf_consul_aws/blob/master/consul_aws/images/3.jpg)
![alt text](https://github.com/manukoli1986/tf_consul_aws/blob/master/consul_aws/images/4.jpg)

## Issues I have faced so far.

1. Terrafrom- connection - host name issue.
Fixed by giving complete information of host.
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file(var.priv_key_path)}"
      agent       = "false"

2. Error launching source instance: InvalidKeyPair.NotFound:  -- Resolved by creating keys ( ssh-keygen -f deploy-user)
resource "aws_key_pair" "deploy_user" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
Fixed by giving proper and accurate information about user name and key pair path.

3 . Error: timeout - last error: ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain	
Fixed by changing the permission of private key to 600 which was locally generated using below command.
```#ssh-keygen -f <user-name>```

4. Error: Invalid template interpolation value: Cannot include the given value in a string template: string required.
Fixed by mentioning the complete format in resource while you are uing any dynamic variable.

5. Still creating.
Enabled tf_log to debug the issue.

Mayank Koli
