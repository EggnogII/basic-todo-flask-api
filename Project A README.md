# Project A
## Flask Web API
Run of the mill basic CRUD flask web app. It's a todo app

## Some basic info

> This is a flask based Web Api that expects a connection to a Postgresql Database. Can be local host, your own instance, whatever you want.

It features a Todo list that is not authenticated, meaning anybody who can connect and update and destroy records as they want. My requirements did not state authentication 
was required for this one, (but another project) so I didn't bother. This is a bare bones app designed to test app deployment from a CI/CD framework to a cloud provider.

The app design follows a similar methodology as Project B, (Routes, Models, DB, and in this case UI).

## Manifest

The following is an example manifest, this file is expected to be in the working dir, so it will have to be made on Docker image creation.
So securely echo the contents into a JSON file here (using secure strings), and build it. Probably make sure your database is alive first on RDS or locally.
```json
{
    "database_server_host": "localhost",
    "database_server_port": "5432",
    "database": "postgres",
    "db_user": "postgres",
    "db_password": "****"
}
```

## Infrastructure

* GitHub Actions, and GitHub in general doesn't really deal with Terraform State, so my considerations are
    * Run the Terraform locally and manage the state locally
    * Encrypt and Decrypt the State file in the git repository (storing TF state in the git repository is a bad practice and want to avoid)
    * Store the TF State in AWS (probably a better move in general, this isn't Azure DevOps Server or Gitlab where we have better options for that)

* Leaning towards local management, for the purposes of how fast the turnaround time is right now. Bad overall for collaboration, but since its just me this is acceptable.

### Database

* Opted to use RDS with AWS so that we aren't keeping a database running on the Docker image. Sure we could do that for simplicity, but if I were working locally I'd just use SQLite instead or Postgres options.

* My last company used Postgres and MSSQL quite extensively. Only considerations is IAM permissions between the ECS service the DB, and making sure the manifest has that information before deployment (using pipeline variable to hide true values)


### ECS

* The ECS solution uses Fargate and EC2's with a preset compute options.
* A cluster is present, so is a basic iam role to assumrole as well as the ECSTaskExecutionPolicy
* Healthcheck was something I wasn't used to setting up, so that was a little bit of a learning experience. Most of my unhealthy status was due to my Dockerfile not including "curl" when I thought it had it.
  * During the troubleshooting phase I make some cloudwatch logs, but I never actually got a logstream. Something to look at later.
* Since this is a public application I opted to use an ALB to get a generated DNS from Amazon.

### Networking (Security Groups)

* The ALB needs a security group as well to allow inbound traffic to the ECS service, ingress is configured for 80, and egress is pretty open. Not a networking expert, I'm certain there are better options.

* The ECS's security group is setup the same as the ALB security group, and references the ALB security group

* The RDS security group here is designed to allow traffic from ECS on port 5432. This one references the ECS's security group

  * RDS's own security group is setup similarly, might have a redundancy there but I'm rolling with it

## Deployment Process

We are using GitHub Actions to create and publish the Dockerimage to ECR. We need to create the proper manifest which includes information on what RDS to connect to, with what credentials (these are injected as masked secrets). So before we do that we need to deploy the RDS infrastructure.

Prerequisites:

* Authentication to AWS on your system or target CI system in the form of Access and Secret keys
* Terraform on your system or target CI system

Order of Operations are as follows:

1) Update the TFVars for RDS, and create RDS Postgres Infrastructure from `/terraform/rds-for-adobe`
  * Take the output DNS name for the RDS instance and put it into the GitHub Actions.
  * There are other secrets to input as well such as the `AWS_SECRET_ACCESS_KEY`, `AWS_SECRET_ACCESS_KEY_ID`, `DATABASE_SERVER_HOST`, `DATABASE_SERVER_PORT` (Usually `5432`), `DB_USER` and the `DB_PASSWORD`.
     * Most of these should come from the TFVars setup for RDS.
2) Publish the Docker Image to ECR using GitHub Actions
  * This should happen after you commit if your branch is `development`. It is an automated trigger.
3) Update the TFVars file for ECS, and create the ECS Infrastructure from `/terraform/ecs-for-adobe`
  * The final output should be the ALB DNS which you can paste into the browser.
  * If there are issues, then we need to investigate the health check using either the AWS CLI, or the Web Console.

### Limitations

* GitHub actions does not store TF State, so I'd need an S3 bucket to store it.
* To that end, and for some simplicity (and time considering this is a 3 day project and there is a second half to do as well) we are just deploying from local system using local configs that are not present on the repo since they would contain sensitive information.
   * A better solution, probably would involve using secrets manager from Amazon to store said secrets or Hashicorp Vault and inject them during Pipeline run.
   * With that in mind I'll provide examples for the var files below

#### Example TFVars for ECS

```
rds_cluster_password="******************************"
rds_instance="adobe-aurora-postgres-instance-0"
db_name="******************************"
db_user="******************************"
vpc_id="vpc="******************************"
subnet_id_b="subnet-="******************************"
subnet_id_c="subnet-="******************************"
ecr_image_uri="******************************"
```

#### Example TFVars for RDS

```
rds_cluster_password="***"
db_name="***"
db_user="***"
vpc_id="vpc-***"
instance_type="db.r7i.large"
subnet_id_b="subnet-***"
subnet_id_c="subnet-***" 
```

## Final Thoughts

* This took the majority of my 3 day project, and the funny part is the app creation only took 3 hours for me. It was infrastructure setup (pipeline, containerization, and IaaC) that were the meat and potatoes of this effort.
* Timeline ended up being the following:
  * Day 1: Create the Application, Test Locally (3 hours), and setup Dockerfile (1 Hour).
  * Day 2: Setup Pipeline for Docker Build (1 Hour), and IaaC to deploy RDS and ECS (3 Hours)
  * Day 2 Extended: Troubleshoot connectivity and Healthcheck issues, test locally and redeploy. Several hours of whack a mole.
  * Day 3: Clean up Terraform, and complete Project B (6 hours)

* Overall win or lose, I feel like I've learned a lot in a crunch scenario like this. I found this experience valuable if not taxing on my computer chair posture.