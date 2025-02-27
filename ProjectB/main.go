package main

import (
	"time"

	"github.com/gin-contrib/timeout"
	"github.com/gin-gonic/gin"
	"www.example.com/rest-api-proj/db"
	"www.example.com/rest-api-proj/routes"
)

func main() {
	db.InitDB()

	server := gin.Default()
	server.Use(timeout.New(timeout.WithTimeout(5 * time.Second)))
	routes.RegisterRoutes(server)
	server.Run(":8080")
}
