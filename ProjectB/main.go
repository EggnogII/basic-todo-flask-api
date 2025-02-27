package main

import (
	"github.com/gin-gonic/gin"
	"www.example.com/rest-api-proj/db"
	"www.example.com/rest-api-proj/middleware"
	"www.example.com/rest-api-proj/routes"
)

func main() {
	db.InitDB()

	server := gin.Default()
	rateLimiter := middleware.NewRateLimiter(5, 10)
	server.Use(rateLimiter.GinMiddleware())
	routes.RegisterRoutes(server)
	server.Run(":8080")
}
