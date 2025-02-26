package main

import (
	"github.com/gin-gonic/gin"
	"www.example.com/rest-api-proj/db"
	"www.example.com/rest-api-proj/routes"
)

func main() {
	db.InitDB()
	/*

		var user models.User
		user.ID = 0
		user.Email = "test5@gmail.com"
		user.Password = "password"
		user.Save()
	*/
	server := gin.Default()
	routes.RegisterRoutes(server)
	server.Run(":8080")
}
