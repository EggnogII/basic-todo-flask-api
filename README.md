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