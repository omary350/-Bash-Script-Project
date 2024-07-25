#! /usr/bin/bash
shopt -s extglob

echo Hello to MOHA Database

if [ -e "Database" ]; then
    cd "Database"
else
    mkdir "Database"
    cd "Database"
fi

select var in 'Create Database' 'List Database' 'Connect Database' 'Drop Database' 'Exit'; do

    case $var in
    "Create Database")
        read -p "Please enter database name using small letters only "a-z": " dbname
        if [ -e $dbname ]; then
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
        if [ -e $dbname ]; then
            cd $dbname
            select opt in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Update Table" "Delete From Table" "Exit Database"; do
                case $opt in
                "Create Table")
                    read -p "Please enter table name to create: " tbname
                    if [[ $tbname =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
                        if [ -e $tbname ]; then
                            echo "Table $tbname already exist"
                        else
                            read -p "Please enter the table columns number: " clnum
                            pk=true
                            datatype=""
                            name=""
                            case $clnum in
                            +([0-9]))
                                for ((i = 1; i <= $clnum; i++)); do
                                    pkvalue=false
                                    validCn=true
                                    while $validCn = true; do
                                        read -p "Please enter column name: " clname
                                        if [[ $clname =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
                                            validDt=true
                                            while $validDt = true; do
                                                read -p "Please enter column datatype: " cldata
                                                if [[ $cldata =~ [Ss][Tt][Rr][Ii][Nn][Gg] || $cldata =~ [Ii][Nn][Tt] ]]; then
                                                    if [ $pk = true ]; then
                                                        read -p "Is it primary key: " pkanswer
                                                        if [[ $pkanswer =~ [yY][eE][sS] || $pkanswer =~ [yY] ]]; then
                                                            pk=false
                                                            pkvalue=true
                                                        fi
                                                    fi
                                                    if [ $pkvalue = true ]; then
                                                        name+=#$clname:
                                                    else
                                                        name+=$clname:
                                                    fi
                                                    if [[ $cldata =~ [Ss][Tt][Rr][Ii][Nn][Gg] ]]; then
                                                        datatype+=string:
                                                    elif [[ $cldata =~ [Ii][Nn][Tt] ]]; then
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
                                (echo $datatype >>$tbname)
                                (echo $name >>$tbname)
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
                    if [ -e $tbname ]; then
                        rm $tbname
                    else
                        echo "Table $tbname doesn't exist"
                    fi
                    ;;
                "Insert into Table")
                    read -p "Please enter table name to insert into: " tbname
                    if [ -e $tbname ]; then
                        loops=$(awk 'BEGIN{FS=":"}
                        {
                            if(NR == 2){
                                print NF
                            }
                        }' $tbname)
                        row=""
                        for ((i = 1; i < $loops; i++)); do
                            clname=$(sed -n '2p' $tbname | cut -f $i -d ":")
                            cldata=$(sed -n '1p' $tbname | cut -f $i -d ":")
                            validInput=true

                            while $validInput = true; do
                                read -p "Please enter value for $clname: " value
                                if [[ ${clname:0:1} == "#" ]]; then
                                    checkExistance=$(awk -v value="$value" -v i=$i 'BEGIN{FS=":"}{
                                                            if(value == $i){
                                                                print "exist"
                                                            }
                                                        }' $tbname)
                                    if [[ $checkExistance == "exist" ]]; then
                                        echo "Not valid duplication for primary key"
                                        continue
                                    fi
                                fi

                                if [[ $cldata = "string" ]]; then
                                    if [[ $value =~ ^[a-zA-Z0-9_]+$ ]]; then
                                        row+=$value:
                                        validInput=false
                                    else
                                        echo "Invalid value for data type of $cldata"
                                    fi

                                elif [[ $cldata = "int" ]]; then
                                    if [[ $value =~ ^[0-9]+$ ]]; then
                                        row+=$value:
                                        validInput=false
                                    else
                                        echo "Invalid value for data type of $cldata"
                                    fi
                                fi
                            done
                        done
                        (echo $row >>$tbname)
                    else
                        echo "Table $tbname doesn't exist"
                    fi
                    ;;
                "Select From Table")
                    read -p "Please enter table name to select from: " tbname
                    if [ -e $tbname ]; then
                        select scopt in "Display Table" "Display By Columns" "Display By Row" "Display specific columns for specific rows" "Exit Command"; do
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
                                for ((j = 0; j < arr_size; j++)); do
                                    clflag=false
                                    for ((i = 1; i <= loops; i++)); do
                                        clname=$(sed -n '2p' $tbname | cut -f $i -d ":")
                                        if [[ ${columns[j]} == $clname || "#${columns[j]}" == $clname ]]; then
                                            clflag=true
                                            field_num+=$i","
                                        fi
                                    done
                                    if [[ $clflag == "false" ]]; then
                                        echo "${columns[j]} column doesn't exist"
                                        break
                                    fi
                                done
                                if [[ $clflag == "true" ]]; then
                                    #To remove the last letter ","
                                    field_num=${field_num%?}
                                    sed -n '2,$p' $tbname | cut -d ":" -f $field_num
                                fi
                                ;;
                            "Display By Row")
                                clexistflag=true
                                clnum=""
                                while $clexistflag = true; do
                                    read -p "Enter column name for value targeting: " clname
                                    read -p "Enter the value required: " valuerq
                                    loops=$(awk 'BEGIN{FS=":"}{
                                        if(NR == 2){
                                            print NF
                                            }
                                        }' $tbname)
                                    for ((i = 1; i <= loops; i++)); do
                                        column=$(sed -n '2p' $tbname | cut -f $i -d ":")
                                        if [[ $clname == $column || "#$clname" == $column ]]; then
                                            clexistflag=false
                                            clnum="$i"
                                        fi
                                    done
                                    if [[ $clexistflag == "false" ]]; then
                                        awk -v value="$valuerq" -v num="$clnum" 'BEGIN{FS=":";OFS=":"}{
                                                    if(NR == 2){
                                                        print $0
                                                    }
                                                    if(value == $num){
                                                        print $0
                                                    }
                                                }' $tbname
                                    else
                                        echo "$clname doesn't exist"
                                    fi
                                done
                                ;;

                            "Display specific columns for specific rows")

                                clexistflag=true
                                clnum=""
                                read -p "Enter column name for value targeting: " clname
                                read -p "Enter the value required: " valuerq
                                loops=$(awk 'BEGIN{FS=":"}{
                                    if(NR == 2){
                                        print NF
                                        }
                                    }' $tbname)
                                for ((i = 1; i <= loops; i++)); do
                                    column=$(sed -n '2p' $tbname | cut -f $i -d ":")
                                    if [[ $clname == $column || "#$clname" == $column ]]; then
                                        clexistflag=false
                                        clnum="$i"
                                    fi
                                done
                                if [[ $clexistflag == "false" ]]; then
                                    rows=$(awk -v value="$valuerq" -v num="$clnum" 'BEGIN{FS=":";OFS=":"}{
                                                if(NR == 2){
                                                    print $0
                                                }
                                                if(value == $num){
                                                    print $0
                                                }
                                            }' $tbname)
                                else
                                    echo "$clname doesn't exist"
                                    break
                                fi
                                echo "$rows" | tr ' ' '\n' >>temp
                                read -p "Please enter column names seprated by space ' ': " -a columns
                                arr_size=${#columns[@]}
                                field_num=""
                                loops=$(awk 'BEGIN{FS=":"}{
                                                if(NR == 2){
                                                    print NF
                                                }
                                            }' temp)
                                for ((j = 0; j < arr_size; j++)); do
                                    clflag=false
                                    for ((i = 1; i <= loops; i++)); do
                                        clname=$(sed -n '1p' temp | cut -f $i -d ":")
                                        if [[ ${columns[j]} == $clname || "#${columns[j]}" == $clname ]]; then
                                            clflag=true
                                            field_num+=$i","
                                        fi
                                    done
                                    if [[ $clflag == "false" ]]; then
                                        echo "${columns[j]} column doesn't exist"
                                        break
                                    fi
                                done
                                if [[ $clflag == "true" ]]; then
                                    field_num=${field_num%?}
                                    sed -n 'p' temp | cut -d ":" -f $field_num
                                fi
                                rm temp
                                ;;
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
                "Update Table")
                    read -p "please Enter table name: " ubdateTable
                    if [[ $ubdateTable =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
                        if [[ -e $ubdateTable ]]; then
                            firstLine=$(head -n 1 $ubdateTable)
                            secondLine=$(head -n 2 $ubdateTable | tail -n 1)
                            declare -i numOfFields=$(echo "$firstLine" | awk -F':' '{print NF}')
                            for ((i = 1; i < $numOfFields; i++)); do
                                dataTypes[$i - 1]=$(echo "$firstLine" | cut -d ':' -f "$i")
                                colsNames[$i - 1]=$(echo "$secondLine" | cut -d ':' -f "$i")
                            done

                            select option in "Update column in table" "Update row in table" "exit"; do
                                case $option in
                                "Update column in table")
                                    read -p "Enter Column name you want to change: " nameOfCol
                                    if [[ $nameOfCol =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
                                        ifColExist=0
                                        declare -i columnIndex=0
                                        for ((i = 1; i < numOfFields; i++)); do
                                            if [[ $nameOfCol == ${colsNames[$i - 1]} || '#'$nameOfCol == ${colsNames[$i - 1]} ]]; then
                                                ifColExist=1
                                                columnIndex=$i-1
                                                break
                                            fi
                                        done

                                        if [[ $ifColExist -eq 1 ]]; then
                                            ifColPK=0
                                            for ((i = 1; i < numOfFields; i++)); do
                                                if [[ '#'$nameOfCol == ${colsNames[$i - 1]} ]]; then
                                                    ifColPK=1 #check if column is primary key
                                                    break
                                                fi
                                            done

                                            if [[ ifColPK -eq 1 ]]; then
                                                echo "cann't change primary key column to be same value"
                                            else
                                                read -p "enter new column value: " newColValue
                                                columnDataType=${dataTypes[$columnIndex]}
                                                if [[ $columnDataType == 'string' ]]; then
                                                    if [[ $newColValue =~ ^[a-zA-Z0-9_]+$ ]]; then
                                                        fieldNum=$((columnIndex + 1))
                                                        awk -F':' -v newValue="$newColValue" -v colfieldNum="$fieldNum" -v OFS=':' '{
                                                                                        # print $colfieldNum;
                                                                                        if(NR >= 3){
                                                                                            $colfieldNum=newValue;
                                                                                        }
                                                                                        print $0;
                                                                                }' "$ubdateTable" >temp_file && mv temp_file "$ubdateTable"
                                                    else
                                                        echo "invalid input for column with string datatype"
                                                    fi
                                                elif [[ $columnDataType == 'int' ]]; then
                                                    if [[ $newColValue =~ ^[0-9]+$ ]]; then
                                                        fieldNum=$((columnIndex + 1))
                                                        awk -F':' -v newValue="$newColValue" -v colfieldNum="$fieldNum" -v OFS=':' '{
                                                                                        # print $colfieldNum;
                                                                                        if(NR >= 3){
                                                                                            $colfieldNum=newValue;
                                                                                        }
                                                                                        print $0;
                                                                                }' "$ubdateTable" >temp_file && mv temp_file "$ubdateTable"
                                                    else
                                                        echo "invalid input for integer datatype"
                                                    fi

                                                fi

                                            fi
                                        else
                                            echo "Column dosen't exist"
                                        fi
                                    else
                                        echo "invalid column name"
                                    fi

                                    ;;
                                "Update row in table")
                                    read -p "enter column name that you want to change it's value: " newColName
                                    read -p "Enter the column name that determines which rows to change: " basedOnCol

                                    if [[ $newColName =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ && $basedOnCol =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
                                        ifNewColNameExisted=0
                                        ifBasedOnColExist=0
                                        declare -i newColValueIndex=0
                                        declare -i basedOnColIndex=0
                                        for ((i = 1; i < numOfFields; i++)); do
                                            if [[ $newColName == ${colsNames[$i - 1]} || '#'$newColName == ${colsNames[$i - 1]} ]]; then
                                                ifNewColNameExisted=1
                                                newColValueIndex=$i-1
                                            fi

                                            if [[ $basedOnCol == ${colsNames[$i - 1]} || '#'$basedOnCol == ${colsNames[$i - 1]} ]]; then
                                                ifBasedOnColExist=1
                                                basedOnColIndex=$i-1
                                            fi
                                        done

                                        if [[ $ifNewColNameExisted -eq 1 && $ifBasedOnColExist -eq 1 ]]; then
                                            read -p "enter new value that you want to update: " newColValue
                                            newColValueDataType=${dataTypes[newColValueIndex]}
                                            validNewColValue=0
                                            if [[ $newColValueDataType == 'string' ]]; then
                                                if [[ $newColValue =~ ^[a-zA-Z0-9_]+$ ]]; then
                                                    validNewColValue=1
                                                else
                                                    echo "new value input not valid for string datatype"
                                                    continue
                                                fi

                                            elif [[ $newColValueDataType == 'int' ]]; then
                                                if [[ $newColValue =~ ^[0-9]+$ ]]; then
                                                    validNewColValue=1
                                                else
                                                    echo "new value input not valid for integer datatype"
                                                    continue
                                                fi
                                            fi

                                            read -p "enter column value that determines which row to change: " basedOnColValue
                                            basedOnColValueDataType=${dataTypes[basedOnColIndex]}
                                            validBasedOnColValue=0

                                            if [[ $basedOnColValueDataType == 'string' ]]; then
                                                if [[ $basedOnColValue =~ ^[a-zA-Z0-9_]+$ ]]; then
                                                    validBasedOnColValue=1
                                                else
                                                    echo "basedOn value input not valid for string datatype"
                                                    continue
                                                fi

                                            elif [[ $basedOnColValueDataType == 'int' ]]; then
                                                if [[ $basedOnColValue =~ ^[0-9]+$ ]]; then
                                                    validBasedOnColValue=1
                                                else
                                                    echo "basedOn value input not valid for integer datatype"
                                                    continue
                                                fi
                                            fi

                                            if [[ $validNewColValue -eq 1 && $validBasedOnColValue -eq 1 ]]; then
                                                ifNewColNamePK=0
                                                for ((i = 1; i < numOfFields; i++)); do
                                                    if [[ '#'$newColName == ${colsNames[$i - 1]} ]]; then
                                                        ifNewColNamePK=1
                                                        break
                                                    fi
                                                done

                                                if [[ $ifNewColNamePK -eq 1 ]]; then
                                                    basedOnColField=$((basedOnColIndex + 1))
                                                    ifBasedOnColOucc=$(awk -v basedOnCol="$basedOnColValue" -v filedNum="$basedOnColField" 'BEGIN{oucc = 0; FS=":"}
                                                                                                {
                                                                                                    if($filedNum == basedOnCol){
                                                                                                        oucc++;
                                                                                                    }
                                                                                                } END{print oucc}' $ubdateTable)

                                                    if [[ $ifBasedOnColOucc -eq 1 ]]; then
                                                        newcolValuefield=$(($newColValueIndex + 1))
                                                        ifnewPKValueExist=$(awk -v pkValue="$newColValue" -v filedNum="$newcolValuefield" 'BEGIN{oucc = 0; FS=":"}
                                                                                                {
                                                                                                    if($filedNum == pkValue){
                                                                                                    oucc++
                                                                                                    }
                                                                                                } END{print oucc}' $ubdateTable)
                                                        if [[ $ifnewPKValueExist -ge 1 ]]; then
                                                            echo "primary key value already exist"
                                                        elif [[ $ifnewPKValueExist -eq 0 ]]; then
                                                            awk -F':' -v newValue="$newColValue" -v newColField="$newcolValuefield" -v basedOnValue="$basedOnColValue" -v basedOnField="$basedOnColField" -v OFS=':' '{
                                                                                                if($basedOnField == basedOnValue){
                                                                                                    $newColField = newValue
                                                                                                }
                                                                                                print $0
                                                                                            }' "$ubdateTable" >temp_file && mv temp_file "$ubdateTable"
                                                        fi
                                                    elif [[ $ifBasedOnColOucc -gt 1 ]]; then
                                                        echo "cann't change primary key value to be same value for multiple column"
                                                    elif [[ $ifBasedOnColOucc -eq 0 ]]; then
                                                        echo "value that determine row doesn't exist"
                                                    fi
                                                else
                                                    newcolValuefield=$(($newColValueIndex + 1))
                                                    basedOnColField=$((basedOnColIndex + 1))
                                                    awk -F':' -v newValue="$newColValue" -v newColField="$newcolValuefield" -v basedOnValue="$basedOnColValue" -v basedOnField="$basedOnColField" -v OFS=':' '{
                                                                            if($basedOnField == basedOnValue){
                                                                                $newColField = newValue
                                                                            }
                                                                            print $0
                                                                        }' "$ubdateTable" >temp_file && mv temp_file "$ubdateTable"
                                                fi
                                            else
                                                echo "one or both inputs doesn't match datatype, please enter valid input"
                                            fi
                                        else
                                            echo "check columns one of them or both doesn't exist"
                                        fi

                                    else
                                        echo "columns names not valid, please enter valid columns names"
                                    fi
                                    ;;
                                "exit")
                                    break
                                    ;;
                                *)
                                    echo "invalid option"
                                    ;;
                                esac
                            done
                        else
                            echo "table not exist"
                        fi
                    else
                        echo "Enter Valid table name"
                    fi
                    ;;
                "Delete From Table")
                    read -p "please Enter table name: " deleteTable
                    if [[ $deleteTable =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
                        if [[ -e $deleteTable ]]; then
                            firstLine=$(
                                head -n 1 $deleteTable
                            )
                            secondLine=$(head -n 2 $deleteTable | tail -n 1)
                            declare -i numOfFields=$(echo "$firstLine" | awk -F':' '{print NF}')
                            for ((i = 1; i < $numOfFields; i++)); do
                                dataTypes[$i - 1]=$(echo "$firstLine" | cut -d ':' -f "$i")
                                colsNames[$i - 1]=$(echo "$secondLine" | cut -d ':' -f "$i")
                            done

                            select option in "Delete column from table" "Delete row from table" "Delete Column Value" "Delete table data" "exit"; do
                                case $option in
                                "Delete column from table")
                                    read -p "Enter Column name you want to delete: " nameOfCol
                                    if [[ $nameOfCol =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
                                        ifColExist=0
                                        declare -i columnIndex=0
                                        for ((i = 1; i < numOfFields; i++)); do
                                            if [[ $nameOfCol == ${colsNames[$i - 1]} || '#'$nameOfCol == ${colsNames[$i - 1]} ]]; then
                                                ifColExist=1
                                                columnIndex=$i-1
                                                break
                                            fi
                                        done

                                        if [[ $ifColExist -eq 1 ]]; then
                                            ifColPK=0
                                            for ((i = 1; i < numOfFields; i++)); do
                                                if [[ '#'$nameOfCol == ${colsNames[$i - 1]} ]]; then
                                                    ifColPK=1 #check if column is primary key
                                                    break
                                                fi
                                            done

                                            if [[ ifColPK -eq 1 ]]; then
                                                echo "cann't delete primary key column"
                                            else
                                                fieldNum=$((columnIndex + 1))
                                                awk -F':' -v colfieldNum="$fieldNum" -v OFS=':' '{
                                                                        # print $colfieldNum;
                                                                        if(NR >= 3){
                                                                            $colfieldNum=" ";
                                                                        }
                                                                        print $0;
                                                                        }' "$deleteTable" >temp_file && mv temp_file "$deleteTable"
                                            fi
                                        else
                                            echo "Column dosen't exist"
                                        fi
                                    else
                                        echo "invalid column name"
                                    fi
                                    ;;
                                "Delete row from table")
                                    read -p "Enter the column name that determines which row to delete: " basedOnCol

                                    if [[ $basedOnCol =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
                                        ifBasedOnColExist=0
                                        declare -i basedOnColIndex=0
                                        for ((i = 1; i < numOfFields; i++)); do
                                            if [[ $basedOnCol == ${colsNames[$i - 1]} || '#'$basedOnCol == ${colsNames[$i - 1]} ]]; then
                                                ifBasedOnColExist=1
                                                basedOnColIndex=$i-1
                                            fi
                                        done

                                        if [[ $ifBasedOnColExist -eq 1 ]]; then
                                            read -p "enter column value that determines which row to delete: " basedOnColValue
                                            basedOnColValueDataType=${dataTypes[basedOnColIndex]}
                                            validBasedOnColValue=0

                                            if [[ $basedOnColValueDataType == 'string' ]]; then
                                                if [[ $basedOnColValue =~ ^[a-zA-Z0-9_]+$ ]]; then
                                                    validBasedOnColValue=1
                                                else
                                                    echo "basedOn value input not valid for string datatype"
                                                    continue
                                                fi

                                            elif [[ $basedOnColValueDataType == 'int' ]]; then
                                                if [[ $basedOnColValue =~ ^[0-9]+$ ]]; then
                                                    validBasedOnColValue=1
                                                else
                                                    echo "basedOn value input not valid for integer datatype"
                                                    continue
                                                fi
                                            fi

                                            if [[ $validBasedOnColValue -eq 1 ]]; then
                                                basedOnColField=$((basedOnColIndex + 1))
                                                ifBasedOnColOucc=$(
                                                    awk -v basedOnCol="$basedOnColValue" -v filedNum="$basedOnColField" 'BEGIN{oucc = 0; FS=":"}
                                                                                        {
                                                                                            if($filedNum == basedOnCol){
                                                                                                oucc++;
                                                                                            }
                                                                                        } END{print oucc}' $deleteTable
                                                )

                                                if [[ $ifBasedOnColOucc -ge 1 ]]; then
                                                    fieldNum=$((basedOnColIndex + 1))
                                                    awk -F':' -v basedOnColVal="$basedOnColValue" -v colfieldNum="$fieldNum" -v OFS=':' '{
                                                                                if(NR>=3 && $colfieldNum == basedOnColVal){
                                                                                    next;
                                                                                }
                                                                                print $0;
                                                                            }' "$deleteTable" >temp_file && mv temp_file "$deleteTable"
                                                elif [[ $ifBasedOnColOucc -eq 0 ]]; then
                                                    echo "value that determine row doesn't exist"
                                                fi
                                            fi
                                        else
                                            echo "check column name, column doesn't exist"
                                        fi

                                    else
                                        echo "column names not valid, please enter valid column name"
                                    fi
                                    ;;
                                "Delete Column Value")
                                    read -p "enter column name that you want to delete it's value: " newColName
                                    read -p "Enter the column name that determines which field to delete: " basedOnCol

                                    if [[ $newColName =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ && $basedOnCol =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
                                        ifNewColNameExisted=0
                                        ifBasedOnColExist=0
                                        declare -i newColValueIndex=0
                                        declare -i basedOnColIndex=0
                                        for ((i = 1; i < numOfFields; i++)); do
                                            if [[ $newColName == ${colsNames[$i - 1]} || '#'$newColName == ${colsNames[$i - 1]} ]]; then
                                                ifNewColNameExisted=1
                                                newColValueIndex=$i-1
                                            fi

                                            if [[ $basedOnCol == ${colsNames[$i - 1]} || '#'$basedOnCol == ${colsNames[$i - 1]} ]]; then
                                                ifBasedOnColExist=1
                                                basedOnColIndex=$i-1
                                            fi
                                        done

                                        if [[ $ifNewColNameExisted -eq 1 && $ifBasedOnColExist -eq 1 ]]; then
                                            read -p "enter column value that determines which field to delete: " basedOnColValue
                                            basedOnColValueDataType=${dataTypes[basedOnColIndex]}
                                            validBasedOnColValue=0

                                            if [[ $basedOnColValueDataType == 'string' ]]; then
                                                if [[ $basedOnColValue =~ ^[a-zA-Z0-9_]+$ ]]; then

                                                    validBasedOnColValue=1
                                                else
                                                    echo "basedOn value input not valid for string datatype"
                                                    continue
                                                fi

                                            elif [[ $basedOnColValueDataType == 'int' ]]; then
                                                if [[ $basedOnColValue =~ ^[0-9]+$ ]]; then
                                                    validBasedOnColValue=1
                                                else
                                                    echo "basedOn value input not valid for integer datatype"
                                                    continue
                                                fi
                                            fi

                                            if [[ $validBasedOnColValue -eq 1 ]]; then

                                                ifNewColNamePK=0
                                                for ((i = 1; i < numOfFields; i++)); do
                                                    if [[ '#'$newColName == ${colsNames[$i - 1]} ]]; then
                                                        ifNewColNamePK=1
                                                        break
                                                    fi
                                                done
                                                if [[ $ifNewColNamePK -eq 1 ]]; then
                                                    echo "cann't delete primary key value of row"
                                                else
                                                    newcolValuefield=$(($newColValueIndex + 1))
                                                    basedOnColField=$((basedOnColIndex + 1))
                                                    awk -F':' -v newColField="$newcolValuefield" -v basedOnValue="$basedOnColValue" -v basedOnField="$basedOnColField" -v OFS=':' '{
                                                                                if(NR>=3 && $basedOnField == basedOnValue){
                                                                                    $newColField = " "
                                                                                }
                                                                                print $0
                                                                            }' "$deleteTable" >temp_file && mv temp_file "$deleteTable"
                                                fi
                                            fi
                                        else
                                            echo "check columns one of them or both doesn't exist"
                                        fi

                                    else
                                        echo "columns names not valid, please enter valid columns names"
                                    fi
                                    ;;
                                "Delete table data")
                                    awk '{
                                                        print $0;
                                                        if(NR > 1){
                                                            exit;
                                                        }
                                                    }' "$deleteTable" >temp_file && mv temp_file "$deleteTable"
                                    ;;
                                "exit")
                                    break
                                    ;;
                                *)
                                    echo "invalid option"
                                    ;;
                                esac
                            done
                        else
                            echo "table not exist"
                        fi
                    else
                        echo "Enter Valid table name"
                    fi
                    ;;
                "Exit Database")
                    cd ..
                    echo "$dbname exited"
                    break
                    ;;
                *)
                    echo "Not valid command"
                    ;;
                esac
            done
        else
            echo "Database $dbname doesn't exist"
        fi
        ;;
    "Drop Database")
        echo "WARNING CANNOT ROLLBACK FROM THIS ACTION"
        read -p "Please enter database name to be deleted: " dbname
        if [ -e $dbname ]; then
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
