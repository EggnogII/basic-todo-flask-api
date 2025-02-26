package models

import (
	"time"

	"www.example.com/rest-api-proj/db"
)

type Event struct {
	ID          int64
	Name        string    `binding:required`
	Description string    `binding:required`
	Location    string    `binding:required`
	DateTime    time.Time `binding:required`
	UserID      int64
}

func (e *Event) Save() error {
	// Safely inject values
	query := `INSERT INTO events(name, description, location, datetime, user_id)
	VALUES ($1, $2, $3, $4, $5)
	RETURNING id;`
	statement, statement_err := db.DB.Prepare(query)
	if statement_err != nil {
		return statement_err
	}
	defer statement.Close()

	var id_num int
	result_err := statement.QueryRow(e.Name, e.Description, e.Location, e.DateTime, 1).Scan(&id_num)
	if result_err != nil {
		return result_err
	}

	e.ID = int64(id_num)

	return nil
}

func GetAllEvents() ([]Event, error) {
	query := "SELECT * FROM events"
	rows, rows_err := db.DB.Query(query)
	if rows_err != nil {
		return nil, rows_err
	}
	defer rows.Close()

	var events []Event
	for rows.Next() {
		var event Event
		scan_err := rows.Scan(&event.ID, &event.Name, &event.Description, &event.Location, &event.DateTime, &event.UserID)

		if scan_err != nil {
			return nil, scan_err
		}
		events = append(events, event)
	}

	return events, nil

}
