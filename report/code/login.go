func (a *App) Login(email, password string) (*User, error) {
    normalizedEmail := normalizeEmail(email)
    var user User
    result := a.db.Where("email = ?", normalizedEmail).First(&user)
    if result.Error != nil {
        return nil, result.Error
    }

    if isBcryptHash(user.Password) {
        if err := bcrypt.CompareHashAndPassword(
            []byte(user.Password), []byte(password)); err != nil {
            return nil, errors.New("invalid email or password")
        }
        return &user, nil
    }

    hashedPassword, err := hashPassword(password)
    if err == nil {
        user.Password = hashedPassword
        _ = a.db.Save(&user)
    }
    return &user, nil
}

func hashPassword(password string) (string, error) {
    hashedPassword, err := bcrypt.GenerateFromPassword(
        []byte(password), bcrypt.DefaultCost)
    if err != nil {
        return "", err
    }
    return string(hashedPassword), nil
}
