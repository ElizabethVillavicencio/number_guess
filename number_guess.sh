#!/bin/bash

# Configurar la variable de conexión a la base de datos
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generar un número aleatorio entre 1 y 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Mostrar el número generado (solo para pruebas, eliminarlo en el script final)
echo "El número generado es: $SECRET_NUMBER"

# Pedir el nombre de usuario
echo "Enter your username:"
read USERNAME

# Validar que el nombre tenga como máximo 22 caracteres
if [[ ${#USERNAME} -gt 22 ]]; then
  echo "The username must be 22 characters or less. Please try again."
  exit 1
fi

# Verificar si el usuario ya existe en la base de datos
USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]; then
  # Si el usuario no existe, mostrar mensaje de bienvenida
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insertar el nuevo usuario en la base de datos
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)")
else
  # Si el usuario existe, extraer datos y dar la bienvenida
  IFS="|" read EXISTING_USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $EXISTING_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Inicializar variables para el juego
GUESSES=0
echo "Guess the secret number between 1 and 1000:"

# Bucle para manejar las conjeturas del usuario
while true; do
  read GUESS
  
  # Validar que la entrada sea un número
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  
  # Incrementar el contador de intentos
  GUESSES=$((GUESSES + 1))
  
  # Verificar si el número es correcto
  if [[ $GUESS -eq $SECRET_NUMBER ]]; then
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    
    # Actualizar los juegos jugados y el mejor juego
    if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]; then
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $GUESSES WHERE username='$USERNAME'")
    else
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")
    fi
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done
