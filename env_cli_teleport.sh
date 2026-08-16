#!/usr/bin/bash

teleport()
{
  # --- Custom APP name and folder ---
  local APP_NAME="cli_teleport"
  local APP_DIR="$HOME/.local/share/$APP_NAME"

  if [ -z "$1" ]; then
    # display usage and exit when no args
    echo "No arguments given."
    $APP_DIR/cli_teleport.py -h | sed "s/cli_teleport.py/teleport/" | sed 's/print/pathgo/' | sed 's/ Print to stdout/Go to/'
    return
  fi

  case "$1" in
    -h|--help)
      $APP_DIR/cli_teleport.py -h | sed "s/cli_teleport.py/teleport/" | sed 's/print/pathgo/' | sed 's/ Print to stdout/Go to/'
      ;;
    -l|--list)
      $APP_DIR/cli_teleport.py -l
      ;;
    -s|--save) 
      $APP_DIR/cli_teleport.py -s "${@:2}"
      local mycommand="$($APP_DIR/cli_teleport.py -e)"
      eval $mycommand
      ;;
    -S|--save_with_index)
      if [ -z "$2" ]; then
          echo "Index missing. teleport -S [index]"
          return
      else
        $APP_DIR/cli_teleport.py -s "$(pwd)" "$2"
        local mycommand="p$2=$(pwd)"
        eval $mycommand 
      fi
      ;;
    -d|--delete) 
      if [ -z "$2" ]; then
          echo "Index missing. teleport -d [index]"
          return
      else
      $APP_DIR/cli_teleport.py -d "$2"
      local mycommand="$($APP_DIR/cli_teleport.py -e)"
      eval $mycommand
      fi
      ;;
    -p|--pathgo) 
      if [ -z "$2" ]; then
          echo "Index missing. teleport -p [index]"
          return
      else
        cd "$($APP_DIR/cli_teleport.py -p $2)"
        local mycommand="p$2=$(pwd)"
        eval $mycommand 
      fi
      ;;
    -D|--deleteall) 
      $APP_DIR/cli_teleport.py -D
      ;;
    -c|--clean) 
      $APP_DIR/cli_teleport.py -c
      local mycommand="$($APP_DIR/cli_teleport.py -e)"
      eval $mycommand
      ;;
    -e|--export) 
      $APP_DIR/cli_teleport.py -e
      ;;
    *)
      echo "Invalid arguments."
      $APP_DIR/cli_teleport.py -h | sed "s/cli_teleport.py/teleport/" | sed 's/print/pathgo/' | sed 's/ Print to stdout/Go to/'
      ;;
  esac
  return $?
}


# Now defining the aliases:
# lt -> list the shortcuts saved
# s1 -> save the path of the current directory at index 1 in the list
# s2 -> save the path of the current directory at index 2 in the list
# ...
# p1 -> go to the path stored at index 1
# p2 -> go to the path stored at index 2
# ...

alias lt="teleport -l"

for VAR in {1..30}
do
    command1="alias s$VAR=\"teleport -S $VAR\""
    command2="alias p$VAR=\"teleport -p $VAR\""
    eval $command1
    eval $command2
done


# Now exporting the paths as Bash variables also. Examples:
# echo $p1          -> prints the path stored at index 1
# cp myfile.txt $p2 -> copies myfile.txt into the path stored at index 2

mycommand="$(teleport -e)" 
eval $mycommand


# Cleaning the environment
unset mycommand
unset command1
unset command2
