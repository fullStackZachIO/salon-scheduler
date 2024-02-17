#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nWelcome to my salon, how can I help you?\n"
  #display services
  SERVICES_LIST=$($PSQL "select service_id, name from services order by service_id")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  # ask for service
    read SERVICE_ID_SELECTED
    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
    then
      # send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
    # get service name
      SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    # get customer info
      if [[ -z $SERVICE ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi
        # get service_time
        echo -e "\nWhat time would you like your $(echo $SERVICE | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
        read SERVICE_TIME;
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        # insert service appointment
        INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        # get appointment info
        APPOINTMENT_INFO=$($PSQL "")
        echo -e "\nI have put you down for a $(echo $SERVICE | sed -r 's/^ *| *$//g') at "$SERVICE_TIME", $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g').\n"
      fi    
    fi
}
MAIN_MENU
