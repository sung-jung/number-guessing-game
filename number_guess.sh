#!/bin/bash
# variable to query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"

# generate random number between 1 and 1000
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

# prompt for username
echo -e "\nEnter your username:"
read USERNAME

# optional: enforce 22-character limit
if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Username too long. Maximum 22 characters."
  exit 1
fi

# check if username exists
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME';")

if [[ -z $USERNAME_RESULT ]]
then 
  # New user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

  # insert new user into database
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"

  # get new user's ID
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # Returning user: get games played and best game
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=(SELECT user_id FROM users WHERE username='$USERNAME')")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=(SELECT user_id FROM users WHERE username='$USERNAME')")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

  # get existing user's ID
  #USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
fi

# prompt to guess the secret number
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1

# guessing loop
while [[ $GUESS -ne $RANDOM_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]] || [[ $GUESS -lt 1 ]] || [[ $GUESS -gt 1000 ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  ((NUMBER_OF_GUESSES++))
done

# insert completed game into database
$PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)"

# success message
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"