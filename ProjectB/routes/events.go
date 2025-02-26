package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"www.example.com/rest-api-proj/models"
	"www.example.com/rest-api-proj/tools"
)

func createEvent(context *gin.Context) {
	token := context.Request.Header.Get("Authorization")
	if token == "" {
		context.JSON(http.StatusUnauthorized, gin.H{"message": "unauthorized"})
		return
	}

	userId, err := tools.VerifyToken(token)
	if err != nil {
		context.JSON(http.StatusUnauthorized, gin.H{"message": "unauthorized"})
		return
	}

	var event models.Event
	err = context.BindJSON(&event)
	if err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"message": "Could not parse request data"})
		return
	}

	// Initialize Event Data
	event.UserID = userId
	err = event.Save()

	if err != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"message": "Could not create event"})
	}

	context.JSON(http.StatusCreated, gin.H{"message": "Event created", "event": event})
}

func getEvents(context *gin.Context) {
	events, err := models.GetAllEvents()
	if err != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"message": "Could not get events"})
	}
	context.JSON(http.StatusOK, events)
}
