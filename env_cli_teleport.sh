#!/usr/bin/bash

tp()
{
  # --- Custom folder ---
  local APP_DIR="$HOME/.local/share/cli_teleport"
  local list_length=30

  if [ -z "$1" ]; then
    # display usage and exit when no args
    echo "No arguments given."
    $APP_DIR/cli_teleport.py -h | sed "s/cli_teleport.py/tp/" | sed 's/print/pathgo/' | sed 's/ Print to stdout/Go to/'
    return
  fi

  case "$1" in
    -h|--help)
      $APP_DIR/cli_teleport.py -h | sed "s/cli_teleport.py/tp/" | sed 's/print/pathgo/' | sed 's/ Print to stdout/Go to/'
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
          echo "Index missing. tp -S [index]"
          return
      else
        $APP_DIR/cli_teleport.py -s "$(pwd)" "$2"
        local mycommand="p$2=$(pwd)"
        eval $mycommand 
      fi
      ;;
    -d|--delete) 
      if [ -z "$2" ]; then
          echo "Index missing. tp -d [index]"
          return
      else
      $APP_DIR/cli_teleport.py -d "$2"
      local mycommand="$($APP_DIR/cli_teleport.py -e)"
      eval $mycommand
      fi
      ;;
    -p|--pathgo) 
      if [ -z "$2" ]; then
          echo "Index missing. tp -p [index]"
          return
      else
        cd "$($APP_DIR/cli_teleport.py -p $2)"
        local mycommand="p$2=$(pwd)"
        eval $mycommand 
      fi
      ;;
    -D|--deleteall) 
      $APP_DIR/cli_teleport.py -D
      for VAR in {1..$list_length}
      do
          local mycommand="unset p$VAR"
          eval $mycommand
      done
      ;;
    -c|--clean) 
      $APP_DIR/cli_teleport.py -c
      for VAR in {1..$list_length}
      do
          local mycommand="unset p$VAR"
          eval $mycommand
      done
      local mycommand="$($APP_DIR/cli_teleport.py -e)"
      eval $mycommand
      ;;
    -e|--export) 
      $APP_DIR/cli_teleport.py -e
      ;;
    *)
      echo "Invalid arguments."
      $APP_DIR/cli_teleport.py -h | sed "s/cli_teleport.py/tp/" | sed 's/print/pathgo/' | sed 's/ Print to stdout/Go to/'
      ;;
  esac
  return $?
}


# Now defining the aliases:
# lt -> list the paths saved
# s1 -> save the path of the current directory as bookmark #1
# s2 -> save the path of the current directory as bookmark #2
# ...
# p1 -> go to the path corresponding to bookmark #1
# p2 -> go to the path corresponding to bookmark #2
# ...

alias lt="tp -l"

for VAR in {1..30}
do
    command1="alias s$VAR=\"tp -S $VAR\""
    command2="alias p$VAR=\"tp -p $VAR\""
    eval $command1
    eval $command2
done


# Now exporting the paths as environment variables also. Examples:
# echo $p1          -> prints the path saved as bookmark #1
# cp myfile.txt $p2 -> copies myfile.txt into the path saved as bookmark #2

mycommand="$(tp -e)" 
eval $mycommand


# Cleaning the environment
unset mycommand
unset command1
unset command2
