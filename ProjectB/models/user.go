package models

import (
	"www.example.com/rest-api-proj/tools"

	"www.example.com/rest-api-proj/db"
)

type User struct {
	ID       int64
	Email    string `binding:required`
	Password string `binding:required`
}

func (u User) Save() error {
	query := `INSERT INTO users(email, password)
	VALUES ($1, $2)
	RETURNING id;
	`

	statement, statement_err := db.DB.Prepare(query)
	if statement_err != nil {
		return statement_err
	}
	defer statement.Close()

	// Hash password
	hashedPassword, err := tools.HashPassword(u.Password)
	if err != nil {
		return err
	}

	var id_num int
	result_err := statement.QueryRow(u.Email, hashedPassword).Scan(&id_num)

	if result_err != nil {
		return result_err
	}

	u.ID = int64(id_num)

	return nil
}
