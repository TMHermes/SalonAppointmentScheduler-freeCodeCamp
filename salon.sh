#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to Old Reece Salon ~~~~~\n"
echo -e "What can I book for you today:\n"

MAIN_MENU() {
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo -e "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[1-6]+$ ]]
    then
        MAIN_MENU "I could not find that service. What can I get you today?\n"
    else
        SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        if [[ -z $CUSTOMER_NAME ]]
        then 
            echo -e "\nI don't have a record with that number, what's your name?"
            read CUSTOMER_NAME

            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        fi

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        echo -e "\nWhat time would you like your$SERVICE_NAME_SELECTED, $(echo $CUSTOMER_NAME | sed 's/ |/"/')?"
        read  SERVICE_TIME

        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

        echo -e "\n I have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ |/"/')."
    fi
}

MAIN_MENU
