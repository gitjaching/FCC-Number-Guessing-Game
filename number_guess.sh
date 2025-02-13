#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESSING_GAME(){
  echo -e "\nNumber Guess Game\n"
  echo "Enter your username:"
  read USERNAME
  USERNAME=$(echo $USERNAME | sed 's/ //g')
  USER_ID=$($PSQL "SELECT user_id FROM user_data WHERE username='$USERNAME';")
  if [[ -z $USER_ID ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO user_data(username,games_played,best_game) VALUES('$USERNAME',0,999);")
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_data WHERE username='$USERNAME';")
    BEST_GAME=$($PSQL "SELECT best_game FROM user_data WHERE username='$USERNAME';")
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_data WHERE username='$USERNAME';")
    BEST_GAME=$($PSQL "SELECT best_game FROM user_data WHERE username='$USERNAME';")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  SECRET_NUMBER=$((RANDOM%1000+1))
  echo "Guess the secret number between 1 and 1000:"

  read GUESS_NUMBER
  while [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS_NUMBER
  done

  TRIAL=1
  while [[ $SECRET_NUMBER != $GUESS_NUMBER ]]
  do
    if [[ $SECRET_NUMBER < $GUESS_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    read GUESS_NUMBER
    ((TRIAL++))
  done
  ((GAMES_PLAYED++))

  echo "You guessed it in $TRIAL tries. The secret number was $SECRET_NUMBER. Nice job!"
  if [[ $TRIAL < $BEST_GAME ]]
  then
    UPDATE_USER_TRIAL=$($PSQL "UPDATE user_data SET best_game=$TRIAL WHERE username='$USERNAME';")
  fi
  UPDATE_USER_TRIAL=$($PSQL "UPDATE user_data SET games_played=$GAMES_PLAYED WHERE username='$USERNAME';")
  
}

GUESSING_GAME
