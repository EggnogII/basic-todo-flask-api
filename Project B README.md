# Project B

## Go-based REST API with Rate Limiting

* This project's question asked to "Design and implement an API Server with authentication and rate limiting capabilities".
* I opted to use a REST API as this is quicker turn around as there is no UI involved. Just requests and responses.
   * Additionally I just finished something similar to this in a Udemy Course so I had familiarity and could leverage things I already made previously from that course
   * The original REST API code is also in my GitHub, but I had to make several improvements to this one which are in this codebase (repo). Namely with authentication, and the fact that this version rate limits

## Core REST Design

* This REST API is created so that users can sign up, and create. update, read, or delete events.
* The core design of this API comes down to a few things, **Database**, **Models**, and **Routes**.

### Database

* The database module acts as the connector between the API and the Postgres Database.
   * This one also uses a manifest.json file like so

```json
{
    "database_server_host" : "localhost",
    "database_server_port": 5432,
    "database_user": "postgres",
    "database_password": "****",
    "database_name": "api"
}
```

 * This is loaded into memory and unmarshaled/serialized into object data that we pipe into the PostgresSql connector. It's how we manage our connection. We make use of the `defer` keyword to keep our connection open.

 ### Models

 * This is where we define what a User and what an Event is.

    * A User is at minimum an ID, a unique Email, and Password (Hashed on save to the DB)
    * An Event is at minimum an ID, Name, Description, Location, and DateTime

* It is here where we define control operations for the Database when we are manipulating the models information (CRUD ops)

### Routes

* Routes are setup so that we can call the Rest API appropriately for GET, PUT, POST, and DELETE commands. They allow us to by extension call the control operations in the models, but we have to handle those too. The handling of said operations happens in this module.

* Route Operations are handled by taking in the request information, binding it to JSON and determining if the information is valid or not before committing to the control action of the respective model.

   * This is also where for some actions that we request validation or authentication by JWT.
   * For Users, our Login command returns a JWT that should be used with any protected action against the Events Table.
   * Some methods of Event manipulation (Creation, Update, and Delete) require this authorization token. Read does not.
   * For User route operations such as "Sign Up", we pass the password parameter to our hashing function and as part of the User model control that gets encrypted and put into the Database.

## More on Authentication

* I created a "tools" module which includes the functions to Hash a Password and Validate Credentials, as well as the JWT generation and verification functions. At the time of writing there are some improvements to make for the JWT generation (such as the key selection)

## Rate Limiting

* Rate Limiting had several different options. Initially I was lazy and wanted to do time-out based limiting, but eventually I caved and decided to use IP-based rate limiting.
    * This is effectively Go's built-in rate limiter and applys the rate limits per client IP.
    * Internally it uses token bucket algorithm to only allow certain number of requests per second with a higher limit that can be achieved in burst succession.
    * This took a considerable amount of time to understand, and implement correctly. Thankfully Go's `defer` keyword helped in managing mutex locks ncessary for creation or determination of new limiters.

## Testing and Rate Testing

* In order to test all my calls effectively I used `REST Client` for VSCode. This allows you to write small tests that end with `.http` which you can call at will. Templates for REST calls if you will.

* They are located in the repository feel free to take a look.

* I also used `hey` to test the rate limiting capability of my solution.
   * This was available via `go install github.com/rakyll/hey@latest`
   * An example of my load test was something close to `hey -n 100 -c 10 http://localhost:8080/events`

   * The end result looks like the following where 200 indicates success, and 429 indicates requests blocked due to rate limiting:

```
Status code distribution:
  [200] 10 responses
  [429] 90 responses
```

## How do I run this?

* Simply run `go mod tidy` in the ProjectB directory and it should download all dependencies
* Then just run the application by using `go run .` and the server should be up in the local network.

## Final thoughts

* Go is pretty well setup as a language to create CLI's and REST API's. I even considered it for the Web API part of this project, but I deferred (haha, get it `defer`) to python as that is my more familiar language.

* Rate limiting is an interesting concept, and I'd like to get more into it in different scenarios and see which approach makes sense for what. Eager to learn