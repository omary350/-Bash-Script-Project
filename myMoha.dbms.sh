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
        read -p "Please enter database name using small letters only "a-z": " dbname
        if [ -e $dbname ]
        then           
            echo "Database $dbname already exist"
        else
            case $dbname in
            +([a-z]))
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
        read -p "Please enter database name to connect to: " dbname
        if [ -e $dbname ]
        then
            cd $dbname
            select opt in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Exit Database"
            do
            case $opt in
                "Create Table")
                    read -p "Please enter table name to create: " tbname
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
                                    echo "$tbname created successfully"
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
                    echo "WARNING CANNOT ROLLBACK FROM THIS ACTION"
                    read -p "Please enter table name to delete: " tbname
                    if [ -e $tbname ]
                    then
                        rm $tbname
                    else
                        echo "Table $tbname doesn't exist"
                    fi
                    ;;
                "Insert into Table")
                    read -p "Please enter table name to insert into: " tbname
                    if [ -e $tbname ]
                    then
                        loops=$(awk 'BEGIN{FS=":"}
                        {
                            if(NR == 2){
                                print NF
                            }
                        }' $tbname)
                        row=""
                        for ((i=1;i<$loops;i++))
                        do
                            clname=$(sed -n '2p' $tbname| cut -f $i -d ":")
                            cldata=$(sed -n '1p' $tbname| cut -f $i -d ":")
                            validInput=true

                            while $validInput = true 
                            do
                                read -p "Please enter value for $clname: " value
                                if [[ ${clname:0:1} == "#" ]]
                                then
                                    checkExistance=$(awk -v value="$value" 'BEGIN{FS=":"}{
                                                            if(value == $1){
                                                                print "exist"
                                                            }
                                                        }' $tbname)
                                    if [[ $checkExistance == "exist" ]]
                                    then
                                        echo "Not valid duplication for primary key"
                                        continue
                                    fi
                                fi

                                if [[ $cldata = "string" ]]
                                then
                                    if [[ $value =~ ^[a-zA-Z0-9_\ ]+$ ]]
                                    then
                                        row+=$value:
                                        validInput=false
                                    else
                                        echo "Invalid value for data type of $cldata"
                                    fi

                                elif [[ $cldata = "int" ]]
                                then
                                    if [[ $value =~ ^[0-9]+$ ]]
                                    then
                                        row+=$value:
                                        validInput=false
                                    else
                                        echo "Invalid value for data type of $cldata"
                                    fi
                                fi
                            done
                        done
                        (echo $row >> $tbname)
                    else
                        echo "Table $tbname doesn't exist"
                    fi
                    ;;
                "Select From Table")
                    read -p "Please enter table name to select from: " tbname
                    if [ -e $tbname ]
                    then
                        select scopt in "Display Table" "Display By Columns" "Display By Row" "Exit Command"
                        do
                            case $scopt in
                                "Display Table")
                                    sed -n '2,$p' $tbname
                                    ;;
                                "Display By Columns")
                                    read -p "Please enter column names seprated by space ' ': " -a columns
                                    arr_size=${#columns[@]}
                                    field_num=""
                                    loops=$(awk 'BEGIN{FS=":"}{
                                                if(NR == 2){
                                                    print NF
                                                }
                                            }' $tbname)
                                    for ((j=0;j<arr_size;j++))
                                    do
                                        clflag=false
                                        for ((i=1;i<=loops;i++))
                                        do
                                            clname=$(sed -n '2p' $tbname| cut -f $i -d ":")
                                            if [[ ${columns[j]} == $clname || "#${columns[j]}" == $clname ]]
                                            then
                                                clflag=true
                                                field_num+=$i","
                                            fi
                                        done
                                        if [[ $clflag == "false" ]]
                                        then
                                            echo "${columns[j]} column doesn't exist"
                                            break
                                        fi
                                    done
                                    if [[ $clflag == "true" ]]
                                    then
                                        #To remove the last letter ","
                                        field_num=${field_num%?}
                                        sed -n '2,$p' $tbname | cut -d ":" -f $field_num
                                    fi
                                        ;;
                                # "Display By Row")
                                #     #
                                    # ;;
                                "Exit Command")
                                    break
                                    ;;
                                *)
                                    echo "Not valid command"
                                    ;;
                            esac
                        done
                    else
                        echo "Table $tbname doesn't exist"
                    fi
                    ;;
                "Exit Database")
                    cd ..
                    echo "$dbname exited"
                    break
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
        echo "WARNING CANNOT ROLLBACK FROM THIS ACTION"
        read -p "Please enter database name to be deleted: " dbname
        if [ -e $dbname ]
        then
            rm -r $dbname
            echo "Database $dbname has been deleted"
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