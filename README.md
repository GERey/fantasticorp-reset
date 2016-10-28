#Setting Up A Demo

There are 7 steps to setting up a demo.

1. Register a domain name of your choice like fantasticorp.click
2. Create instance of CCIE, give it a hostname like circleci.fantasticorp.click.
	* Follow the instructions here to create an instance of CCIE `https://circleci.com/docs/enterprise/aws/`
3. Create a Launch Configuration using t2.small/t2.micro instances. Under `advanced options` the user data must look like example 1 below. Subsitute the name `fantasticorp-home` with the name of the ecs cluster you wish the instances to join.
	* When choosing what ami to deploy, use this resource: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html
4. Create an autoscaling group out of your launch configuration.
5. Create an ELB for the ECS service:
	* Instructions for Application LB: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-application-load-balancer.html
	* Instructions for Classic: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-standard-load-balancer.html
6. Register a AWS ECS cluster and service
	* Instructions: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/get-set-up-for-amazon-ecs.html
7. Point your domain name to the elb fronting the ECS service
8. Copy the `secrets.template` file to a file named `secrets`
9. (Optional) Create a Trello account to demo integrating with Trello (leave all TRELLO_* env vars unset to skip)
10. Fill in the file `secrets`
11. Run `./reset.sh`


####Example 1

```
#!/bin/bash

echo ECS_CLUSTER=fantasticorp-home > /etc/ecs/ecs.config
```
