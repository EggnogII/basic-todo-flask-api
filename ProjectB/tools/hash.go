package tools

import "golang.org/x/crypto/bcrypt"

func HashPassword(password string) (string, error) {
	cost_value := 14
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), cost_value)
	return string(bytes), err
}

func CheckPasswordHash(password, hashedPassword string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
	return err == nil
}
