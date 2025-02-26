package main

import (
	"fmt"

	"www.example.com/rest-api-proj/db"
)

func main() {
	fmt.Println("Dummy Printline while I figure stuff out")
	db.InitDB()
	/*

		var user models.User
		user.ID = 0
		user.Email = "test5@gmail.com"
		user.Password = "password"
		user.Save()
	*/
}
