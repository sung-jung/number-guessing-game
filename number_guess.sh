#!/bin/bash
# variable to query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))


echo -e "\nEnter your username:"
read USERNAME

USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

#If that username has been used before, it should print Welcome back, <username>! You have played <games_played> 
#games, and your best game took <best_game> guesses., with <username> being a users name from the database, 
#<games_played> being the total number of games that user has played, and <best_game> being the fewest 
#number of guesses it took that user to win the game
if [[ -z $USERNAME_RESULT ]]
then 
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  # add player to database
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=(SELECT user_id FROM users WHERE username='$USERNAME')")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=(SELECT user_id FROM users WHERE username='$USERNAME')")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#next line printed should be Guess the secret number between 1 and 1000:
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1
