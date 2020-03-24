# xtract.sh
This is a work in progress training Bash script (CLI) which aims to facilitate archive extraction of various types.
It supports multiple archive formats and also more than one archive can be passed as arguments (space separated).

**NOTE**: Read comments and gain understaning before using the script. It **MAY** cause damage.
## About
This is a side-project which I use to learn Bash scripting and actually make my life easier when it comes to archive extraction.
Programs the script depends on and supports:
* **tar**
* **unrar**
* **unzip**
* **7z**

Also creates log files with details of the extraction process and general info.
## Installation
Clone this repo `git clone https://github.com/fokditkak/xtract.sh.git` in desired directory then `cd THE_DIR`.
If you wish to make it globally acessible simply put it in your $PATH.
## Usage
`./xtract.sh [name-of-archive(s)]` - This will extract the archive/s in your current directory.
`./xtract.sh -t|--target=PATH-TO-DIR [name-of-archive(s)]` - This will extract the archive/s in $DESTINATION directory. 
The `--target=` option is optional and sets the $DESTINATION variable. If no such option is given the dir in which the script is run will be the target.

### Examples
#### Single archive
`./xtract.sh archive.tar` Will extract archive "archive.tar" in the current directory.
#### Multiple archives
`./xtract.sh archive1.tar archive2.zip archive3.7z` Will extract all archives in the current directory.
#### Multiple archives with a target directory
`./xtract.sh -t=/home/user/extracted archive1.tar archive2.zip archive3.7z` Will set the $DESTINATION variable to "/home/user/extracted" and then proceed to extract all in said dir.
#### Multiple archives with multiple target directories
`./xtract.sh -t=target1 archive1.tar -t=target2 archive2.zip -t=target3 archive3.7z` Will set the $DESTINATION differently for each of the archives.


