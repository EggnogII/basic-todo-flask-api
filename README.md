# basic-todo-flask-api
Run of the mill basic CRUD flask web app. It's a todo app

## Some basic info

> This is a flask based Web Api that expects a connection to a Postgresql Database. Can be local host, your own instance, whatever you want.

It features a Todo list that is not authenticated, meaning anybody who can connect and update and destroy records as they want. My requirements did not state authentication 
was required for this one, (but another project) so I didn't bother. This is a bare bones app designed to test app deployment from a CI/CD framework to a cloud provider.

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


