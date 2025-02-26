package db

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"os"

	_ "github.com/lib/pq"
)

type Manifest struct {
	Host     string `json:"database_server_host"`
	Port     int    `json:"database_server_port"`
	Dbname   string `json:"database_name"`
	User     string `json:"database_user"`
	Password string `json:"database_password"`
}

var DB *sql.DB

func InitDB() {
	jsonFile, json_err := os.Open("manifest.json")
	if json_err != nil {
		fmt.Println(json_err)
	}
	defer jsonFile.Close()

	jsonBytes, _ := io.ReadAll(jsonFile)
	var manifest Manifest
	json.Unmarshal(jsonBytes, &manifest)

	psqlConnection := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", manifest.Host, manifest.Port, manifest.User, manifest.Password, manifest.Dbname)
	var err error
	DB, err = sql.Open("postgres", psqlConnection)
	if err != nil {
		panic("Could not connect to Database")
	}

	DB.SetMaxOpenConns(10)
	DB.SetMaxIdleConns(5)

}
