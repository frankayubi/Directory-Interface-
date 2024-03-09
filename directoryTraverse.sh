#!/bin/bash


traverse_modified() {
if [ ! -d "$1" ]; then
        file=$(find "$1" -mtime -1)
        if [ ! -z "$file" ];then
                files+=("$file")
        fi
    return
fi
if [ `ls "$1" | wc -l` -eq 0 ]; then
   return
fi
local entries=("$1"/*)
local entry
for entry in "${entries[@]}"
do
    traverse_modified "$entry"
done
}

traverse() {
        a=$(echo "$1" | cut -d '/' -f 2- )
        if [ -n "$a" ] && [ "$a" != "$dname" ] ;then
                origfiles+=("$a")
        fi

if [ ! -d "$1" ]; then
    return
fi
if [ `ls "$1" | wc -l` -eq 0 ]; then
   return
fi
local entries=("$1"/*)
local entry
for entry in "${entries[@]}"
do
    traverse "$entry"
done
}




fileAction(){
        local choice="Y"

        if [ ! -s "$1" ];then
                echo "the file is empty ....returning to menu "
                echo
                choice="N"
        else

        local lines=$( wc -l < "$1" )
        local linesread=10
        head -n 10 "$1"
        local count=10
        fi

        while [ "$choice" = "Y" ];do
                echo -n "Would you like to display more? (Y/N) "
                read response
                echo
                if [ "$response" = "Y" ];then
                        if [ "$linesread" -lt "$lines" ];then
                                if (( lines - linesread < 10 ));then
                                        ((count = lines - linesread))
                                fi
                                ((linesread += 10))
                                
				head -n "$linesread" "$1" | tail -n "$count"  
  			else
                                echo " You have reached end of file ...returning to menu "
				echo 
                                choice="N"
                        fi
                else
                        choice="$response"
                        echo
                        echo " Returning to menu... "

                        sleep 2
                fi
        done




}

displaymodified(){
        files=()
        traverse_modified $1

        local -A modified_files
        if [ ${#files[@]} -gt 0 ];then
                    local count=0
                for file in "${files[@]}";do
                     modified_files["$count"]="$file"
                        ((count+=1))
                done
                local loop="Y"
                while [ "$loop" = "Y" ];do
                        echo "All files modified in the past 24 hours in directory $1 "
                        echo "-------------------------------------------------------"
                        
                        for key in "${!modified_files[@]}";do
                                echo " $key : Read file ${modified_files[$key]}"
                                
                        done
                        local num
			echo -n "PLease enter the number of the file you want to read?(E to exit) "
                        read num
                        echo
                        if [ "$num" = "E" ];then
                                echo "exiting"
                                loop="N"
                        else
                                local value_to_pass="${modified_files[$num]}"
                                echo "$value_to_pass"
                                fileAction "$value_to_pass"
                        fi
                done
        else
                echo "No files were modified in laast 24 hours in the directory $1"
        fi

}

displaycontent(){
        origfiles=()
        traverse $1

        local -A original_files
        if [ ${#origfiles[@]} -gt 0 ];then
                    local count=0
                for file in "${origfiles[@]}";do
                     original_files["$count"]="$file"
                        ((count+=1))
                done

                local loop="Y"
		cd $1
                while [ "$loop" = "Y" ];do
                        echo "All files and subdirectories in directory $1 "
                        echo "-------------------------------------------------------"
               
			

			echo "     DIRECTORIES   "
                        echo
                        for key in "${!original_files[@]}";do
                                if [ -d "${original_files[$key]}" ];then
                                         echo " $key : Navigate to  ${original_files[$key]}"
                                         
                                fi
                        done
			echo
			echo "       FILES         "
			echo
                        for key in "${!original_files[@]}";do 
                                if [ -f "${original_files[$key]}" ];then
                                echo " $key : Read   ${original_files[$key]}"
                                
                                fi
			done
                               
                        
                        local num
			echo -n "PLease enter the number of the file you want to read or directory you want to enter? (E to exit) : "
                        read num
                        echo
                        if [ "$num" = "E" ];then
                                echo "exiting"
                                loop="N"
                        else
                                local value_to_pass="${original_files[$num]}"
                           
                                if [ -f "$value_to_pass" ];then
                                fileAction "$value_to_pass"
                                fi
                                if [ -d "$value_to_pass" ];then
                                        displaymodified "$value_to_pass"
                                fi

                        fi
                done
        else
                echo "No files or subdirectories in the directory $1"
        fi

}
  
action(){
	echo -n " Enter a directory :"
read dname
echo


if [ ! -d "$dname" ];then
        echo " $dname does not exist "
        echo " would you like to create one (Y/N)"
        read input

        if [ "$input" = Y ];then
        mkdir "$dname"
        else
        echo "Bye...terminating script"
        exit 1
        fi
else
        if [ -d "$dname" ];then
                if [ ! -r "$dname" ];then
                      
                        echo "Error: You dont have reading permissions"
                        exit 1
                fi
        else
                echo "Error: You dont have execute permissions"
                exit 1
        fi

fi

displaycontent $dname



}
action 

