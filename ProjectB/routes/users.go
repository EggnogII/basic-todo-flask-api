package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"www.example.com/rest-api-proj/models"
)

func signup(context *gin.Context) {
	var user models.User
	err := context.BindJSON(&user)
	if err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"message": "Could not parse request data"})
		return
	}

	err = user.Save()
	if err != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"message": "Could not create user"})
	}
	context.JSON(http.StatusCreated, gin.H{"message": "User created", "user": user})
}
