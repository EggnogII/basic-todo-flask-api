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

	// Here is where we create tables
	createTables()
}

func createTables() {
	createUsersTable()
	createEventsTable()
}

func createUsersTable() {
	createUsersTable := `
	CREATE TABLE IF NOT EXISTS users (
	 id SERIAL PRIMARY KEY,
	 email TEXT NOT NULL UNIQUE,
	 password TEXT NOT NULL
	 )
	 `
	_, err := DB.Exec(createUsersTable)

	if err != nil {
		fmt.Print(err)
		panic("Could not create users table")
	}
}

func createEventsTable() {
	createEventsTable := `
	CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    location TEXT NOT NULL,
    datetime TIMESTAMP NOT NULL,
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users (id)
);
`
	_, err := DB.Exec(createEventsTable)

	if err != nil {
		fmt.Print(err)
		panic("Could not create events table")
	}

}
