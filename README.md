# cli_teleport
A command line tool to bookmark directories and easily navigate through them. Works in Bash and Zsh shells.


## How it works
The basic commands are:

`s1`  -> saves current directory as bookmark #1

`s2`  -> saves current directory as bookmark #2

...etc.

`p1`  -> goes to directory #1

`p2`  -> goes to directory #2

...etc.

`lt`  -> lists all bookmarks saved

The bookmarks are also saved as environment variables: 
- `$p1` contains the path to directory #1
- `$p2` contains the path to directory #2

...etc.

This means that the command `p1` is functionally equivalent to `cd $p1`.
The environment variables are always up to date with the bookmark list. They can be useful for operations like:
`mv $p1/myfile.txt $p2`  -> moves myfile.txt from path `$p1` to path `$p2`.

More details about this tool (including bookmarks deletion/cleanup) are provided in section "Usage details"

## Installation
Clone the repository anywhere in your filesystem and run the install.sh script.

```bash
git clone https://github.com/paolo-915/cli_teleport.git
cd cli_teleport
./install.sh
```
The default installation folder is indicated by the `APP_DIR` variable in the install.sh script.

```bash
APP_DIR="$HOME/.local/share/cli_teleport"
```

To change the installation folder, modify the `APP_DIR` variable before running the install.sh script. You can run `./install.sh` without sudo privileges as long as `APP_DIR` points to a location inside your `$HOME`.


To uninstall the program, run:
```bash
./install.sh -u
```

## Usage details
Once the installation is completed, restart your terminal or open a new one. A new function called `tp` will be available.

```bash
Usage: tp [option] [argument(s)]
Options and arguments:
-h, --help                     Show this message and quit
-l, --list                     Show the paths saved and their corresponding indices
-s, --save [path] [index]      Save the [path] and bookmark it with [index]
-p, --pathgo <index>           Go to the path correponding to <index>
-d, --delete <index>           Delete the path corresponding to <index>
-D, --deleteall                Delete all paths previously saved
-c, --clean                    Delete paths to directories that no longer exist
```

Since the most useful commands are those to list, save and go to a path, aliases have been created for such commands, as shown previously:

 |  alias  |  Target command  |
 |---------|------------------|
 |  `lt`   |  `tp --list`     |
 |  `s1`   |  `tp --save . 1` |
 |  `s2`   |  `tp --save . 2` |
 |   ...   |   ...            |
 |  `p1`   |  `tp --pathgo 1` |
 |  `p2`   |  `tp --pathgo 2` |
 |   ...   |   ...            |


## Usage example

```bash
user@debian:~$ lt

1       /home/user/Documents/work2025
2       /home/user/Documents/newproject
3       /home/user/Download

user@debian:~$ p1
user@debian:~/Documents/work2025$ cp myfile.txt $p2
user@debian:~/Documents/work2025$ p2
user@debian:~/Documents/newproject$ 
```
