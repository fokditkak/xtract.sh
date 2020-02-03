# xtract.sh
This is a work in progress training Bash script (CLI) which aims to facilitate archive extraction of various types.

**NOTICE**: Read comments and gain understaning before using the script. It **MAY** cause errors.
## About
This is a side-project which I use to learn Bash scripting and actually make my life easier when it comes to archive extraction.
Programs the script depends on and supports:
* **tar**
* **unrar**
* **unzip**
* 7z

Also creates log files with details of the extraction process and general info.
## Installation
Clone this repo `git clone https://github.com/fokditkak/xtract.sh.git` in desired directory then `cd THE_DIR`.
If you wish to make it globally acessible simply put it in your $PATH.
## Usage
./xtract.sh [name-of-archive] - This will extract the archive in your current directory.
