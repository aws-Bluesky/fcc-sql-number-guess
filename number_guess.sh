#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

TAKE_CHECK_NUMBER() {
  read NUMBER_INPUT
  COUNT=$(( $COUNT + 1 ))
  while [[ ! $NUMBER_INPUT =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read NUMBER_INPUT
    COUNT=$(( $COUNT + 1 ))
  done
}

echo "Enter your username: "
read USER_NAME_INPUT

# find id from users to check exist
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME_INPUT'")
echo $USER_ID

# if not found
if [[ -z $USER_ID ]]
then
  # print notice first time
  echo "Welcome, $USER_NAME_INPUT! It looks like this is your first time here."
  #insert into users
  INSERT_INTO_USERS_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME_INPUT')")
  # get new user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME_INPUT'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guess) FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $USER_NAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


# ----------play game
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo -e "\nGuess the secret number between 1 and 1000:"
COUNT=0
TAKE_CHECK_NUMBER

while [[ $NUMBER_INPUT != $SECRET_NUMBER ]]
do
  # guess wrong
  if [[ $NUMBER_INPUT > $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    TAKE_CHECK_NUMBER
  else
    echo "It's higher than that, guess again:"
    TAKE_CHECK_NUMBER
  fi
done

echo -e "\nYou guessed it in $COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
# insert into games
INSERT_INTO_GAMES=$($PSQL "INSERT INTO games(user_id, number_of_guess) VALUES($USER_ID, $COUNT)")
