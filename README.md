#Setting Up A Demo

There are 7 steps to setting up a demo.

1. Register a domain name of your choice like pixelgroup.click
2. Create instance of CCIE, give it a hostname like circleci.pixelgroup.click.
	* Follow the instructions here to create an instance of CCIE `https://circleci.com/docs/enterprise/aws/`
3. Register a AWS ECS cluster and service
	* Instructions: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/get-set-up-for-amazon-ecs.html  
3. Create a Launch Configuration using t2.small/t2.micro instances. Under `advanced options` the user data must look like example 1 below. Subsitute the name `pixelgroup-home` with the name of the ecs cluster you wish the instances to join. 
	* When choosing what ami to deploy, use this resource: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html
4. Create an autoscaling group out of your launch configuration.
5. Attach your autoscaling group to your ELB.
	* Instructions: http://docs.aws.amazon.com/autoscaling/latest/userguide/attach-load-balancer-asg.html 	
4. Point your domain name to the elb fronting the ECS service
5. Copy the `secrets.template` file to a file named `secrets`
6. Fill in the file `secrets` 
7. Run `./reset.sh`


####Example 1

```
#!/bin/bash

echo ECS_CLUSTER=pixelgroup-home > /etc/ecs/ecs.config
```

