#! /usr/bin/bash
shopt -s extglob

echo Hello to MOHA Database

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
            case $dbname in
            +([A-Za-z]))
                mkdir $dbname
                ;;
             *)
                echo "Not valid name for database"
                ;;
            esac
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
            select opt in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table"
            do
            case $opt in
                "Create Table")
                    read -p "Please enter table name: " tbname
                    if [[ $tbname =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]
                    then
                        if [ -e $tbname ]
                        then
                            echo "Table $tbname already exist"
                        else
                            read -p "Please enter the table columns number: " clnum
                            pk=true
                            datatype=""
                            name=""
                            case $clnum in
                                +([0-9]))
                                    for ((i=1;i<=$clnum;i++))
                                    do
                                        pkvalue=false
                                        validCn=true
                                        while $validCn = true
                                        do
                                            read -p "Please enter column name: " clname
                                            if [[ $clname =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]
                                            then
                                                validDt=true
                                                while $validDt = true 
                                                do
                                                    read -p "Please enter column datatype: " cldata
                                                    if [[ $cldata =~ [Ss][Tt][Rr][Ii][Nn][Gg] || $cldata =~ [Ii][Nn][Tt] ]]
                                                    then
                                                        if [ $pk = true ]
                                                        then 
                                                            read -p "Is it primary key: " pkanswer
                                                            if [[ $pkanswer =~ [yY][eE][sS] || $pkanswer =~ [yY] ]]
                                                            then
                                                                pk=false
                                                                pkvalue=true
                                                            fi
                                                        fi
                                                        if [ $pkvalue = true ]
                                                        then
                                                            name+=#$clname:
                                                        else
                                                            name+=$clname:
                                                        fi
                                                        if [[ $cldata =~ [Ss][Tt][Rr][Ii][Nn][Gg] ]]
                                                        then
                                                            datatype+=string:
                                                        elif [[ $cldata =~ [Ii][Nn][Tt] ]]
                                                        then
                                                            datatype+=int:
                                                        fi
                                                        validDt=false
                                                    else
                                                        echo "Invalid datatype"
                                                    fi
                                                done
                                                validCn=false
                                            else
                                                echo "Invalid column name"
                                            fi
                                        done
                                    done 
                                    touch $tbname
                                    (echo $datatype >> $tbname)
                                    (echo $name >> $tbname)
                                    ;;
                                *)
                                    echo "Not valid number"
                                    ;;
                            esac
                        fi
                    else
                        echo "Not valid table name"
                    fi
                    ;;
                "List Tables")
                    ls
                    ;;
                "Drop Table")
                    read -p "Please enter table name: " tbname
                    if [ -e $tbname ]
                    then
                        rm $tbname
                    else
                        echo "Table $tbname doesn't exist"
                    fi
                    ;;
                *)
                    echo "Not valid command"
            esac
            done
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
        echo "Not valid command"
        ;;
    esac
done