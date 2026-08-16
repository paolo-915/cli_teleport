#!/usr/bin/env python3

import sys
import os
from pathlib import Path


class teleporter:

    def __init__( self ):

        # --- Custom APP name and folder ---
        APP_NAME = "cli_teleport"
        APP_DIR = "$HOME/.local/share/$APP_NAME"

        path_data_dir = Path(os.path.expandvars(APP_DIR))
        self.shortcuts_file = path_data_dir / "cli_teleport_list"


    def _valid_index( self, index ):
        try:
            ind = int(index)
            if ind < 1:
                raise ValueError("Index must be 1 or greater.")
            else:
                return True
        except (ValueError, TypeError) as e:
            print(f"ERROR: Invalid index '{index}'. {e}", file=sys.stderr)
            return False


    def _convert_index( self, index ):
        return int(index) - 1


    def _read_shortcuts_file( self, create_file = False ):

        if not self.shortcuts_file.exists():

            if not create_file:
                #print(f"The file '{self.shortcuts_file}' does not exist yet.", file=sys.stderr)
                return []
            else:
                try:
                    # Ensure parent directories exist before creating the file
                    self.shortcuts_file.parent.mkdir(parents=True, exist_ok=True)
                    self.shortcuts_file.touch()
                except OSError as e:
                    print(f"ERROR: Failed to create '{self.shortcuts_file}': {e}", file=sys.stderr)
                    return ['I/O error']

        try:
            shortcuts = self.shortcuts_file.read_text(encoding="utf-8").splitlines()
            if shortcuts == ['']: shortcuts = []

        except (OSError, UnicodeDecodeError) as e:
            print(f"ERROR: Failed to read '{self.shortcuts_file}': {e}", file=sys.stderr)
            return ['I/O error']

        return shortcuts


    def _write_shortcuts_file( self, shortcuts ):

        try:
            # Rejoin with newlines and ensure a trailing newline
            content = "\n".join(shortcuts) + "\n"
            self.shortcuts_file.write_text(content, encoding="utf-8")
        except OSError as e:
            print(f"ERROR: Failed to write to '{self.shortcuts_file}': {e}", file=sys.stderr)


    #./cli_teleport.py --help
    def print_help( self ):
        print()
        print("usage: cli_teleport.py [option] [argument(s)]")
        print("Options and arguments:")
        print("-h, --help                                Show this message and quit.")
        print("-l, --list                                Show the paths saved and their corresponding indices.")
        print("-s [Path] [index], --save [Path] [index]  Save the [Path] and bookmark it with [index].")
        print("-d [index], --delete [index]              Delete the [Path] corresponding to [index].")
        print("-p [index], --print [index]               Print to stdout the [Path] correponding to [index].")
        print("-D, --deleteall                           Delete all paths previously saved.")
        print("-c, --clean                               Delete paths to locations that no longer exist.")
        print()


    #./cli_teleport.py --list
    def list_shortcuts( self ):

        shortcuts = self._read_shortcuts_file()
        if shortcuts == ['I/O error']:
            return

        if shortcuts == []:
            print("Empty list.")
            return

        print()

        for index in range(0, len(shortcuts)):

            string_to_print = str(index+1) + "\t" + shortcuts[index]
            print( string_to_print, end='\n' ) 

        print()


    #./cli_teleport.py --save [path] [index]
    def save_shortcut(self, path_tosave = Path.cwd(), index = 999):

        if not self._valid_index( index ):
            return

        # Resolve Path to Save
        try:
            string_to_save = Path(path_tosave).resolve().as_posix()
        except Exception as e:
            print(f"ERROR: Failed to resolve path '{path_tosave}': {e}", file=sys.stderr)
            return

        shortcuts = self._read_shortcuts_file( create_file = True )
        if shortcuts == ['I/O error']:
            return

        # Update or Append
        idx_0 = self._convert_index( index )

        if idx_0 >= len(shortcuts):
            shortcuts.append(string_to_save)
            print(f"Path saved at index n° {len(shortcuts)}.")
        else:
            shortcuts[idx_0] = string_to_save
            print(f"Path saved at index n° {index}.")

        self._write_shortcuts_file( shortcuts )


    #./teleport.py --print [index]
    def print_shortcut( self, index ):

        if not self._valid_index( index ):
            return

        shortcuts = self._read_shortcuts_file()
        if shortcuts == ['I/O error']:
            return


        idx_0 = self._convert_index( index )
        number_of_shortcuts = len(shortcuts)

        if idx_0 < 0 or idx_0 > (number_of_shortcuts-1):
            print(f"ERROR. Path n° {index} is unset.", file=sys.stderr)
            return
        else :
            place_to_go = shortcuts[ idx_0 ]

        print(place_to_go)



    #./cli_teleport.py --delete [index]
    def delete_shortcut( self, index ):

        if not self._valid_index( index ):
            return

        shortcuts = self._read_shortcuts_file()
        if shortcuts == ['I/O error']:
            return

        idx_0 = self._convert_index( index )
        number_of_shortcuts = len(shortcuts)

        if idx_0 < 0 or idx_0 > (number_of_shortcuts-1) :
            print(f"ERROR. Path n° {index} is unset.", file=sys.stderr)
            return
        else :
            shortcuts.pop( idx_0 )
            self._write_shortcuts_file( shortcuts )
            print(f"Path n° {index} deleted.")


    #./cli_teleport.py --deleteall
    def deleteall( self ):

        self.shortcuts_file.unlink( missing_ok = True )
        print("All Paths have been deleted.")


    #./cli_teleport.py --clean
    def clean( self ):

        shortcuts = self._read_shortcuts_file()
        if shortcuts == ['I/O error']:
            return

        new_shortcuts = []
        for element in shortcuts:
            if Path(element).exists():
                new_shortcuts.append(element)

        self._write_shortcuts_file( new_shortcuts )
        print("Paths cleanup completed.")


    def _export_shortcuts_in_bash ( self ):

        shortcuts = self._read_shortcuts_file()
        if shortcuts == ['I/O error']:
            return

        mycommand = ""

        for index in range(0, len(shortcuts)):
            ii = index + 1
            mycommand+= "p" + str(ii) + "=" + shortcuts[index] + ";"

        print(mycommand)



if __name__ == "__main__":

    tp = teleporter()

    arguments = len(sys.argv)

    if arguments > 1:

        if sys.argv[1] in ("--list", "-l"):
            tp.list_shortcuts()

        elif sys.argv[1] in( "--help", "-h"):
            tp.print_help()

        elif sys.argv[1] in( "--deleteall", "-D"):
            tp.deleteall()

        elif sys.argv[1] in( "--clean", "-c"):
            tp.clean()

        elif sys.argv[1] in( "--export", "-e"):
            tp._export_shortcuts_in_bash()

        elif sys.argv[1] in ("--save", "-s"):

            if arguments >= 4:
                tp.save_shortcut( sys.argv[2], sys.argv[3] )
            elif arguments == 3:
                tp.save_shortcut( path_tosave = sys.argv[2] )
            else:
                tp.save_shortcut()

        elif sys.argv[1] in ("--print", "-p"):

            if len(sys.argv) >= 3:
                tp.print_shortcut( sys.argv[2] )
            else:
                print("Index missing. cli_teleport.py -p [index]")
        

        elif sys.argv[1] in ("--delete", "-d"):

            if len(sys.argv) >= 3:
                tp.delete_shortcut( sys.argv[2] )
            else:
                print("Index missing. cli_teleport.py -d [index]")

        else:
            print("\nInvalid arguments.")
            tp.print_help()

    else:
        print("\nNo arguments given.")
        tp.print_help()
