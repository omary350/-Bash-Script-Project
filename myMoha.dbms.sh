#! /usr/bin/bash
shopt -s extglob

echo Hello

if [ -e "Database" ]
then
cd "Database"
else
mkdir "Database"
cd "Database"
fi

select var in 'Create Database' 'List Database' 'Connect Database' 'Drop Database' 'Exit'
do
case $var in
"Create Database")
    read -p "Please enter database name: " dbname
    if [ -e $dbname ]
    then           
        echo "Database $dbname already exist"
    else
        mkdir $dbname
    fi
    ;;
"List Database")
    echo $(ls)
    ;;
"Connect Database")
    read -p "Please enter database name: " dbname
    if [ -e $dbname ]
        then
            cd $dbname
            pwd
        else
            echo "Database $dbname doesn't exist"
        fi
    ;;
"Drop Database")
    read -p "Please enter database name: " dbname
    if [ -e $dbname ]
        then
            rm -r $dbname
            echo "Database $dbname has been deleted"
            ls 
        else
            echo "Database $dbname doesn't exist"
        fi
    ;;
"Exit")
    break
    ;;
*)
    echo "No Valid Choice"
    ;;
esac

done