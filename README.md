# xtract
This is a work in progress training Bash script (CLI) which aims to facilitate archive extraction of various types.
**NOTICE**: Read comments and gain understaning before using the script. It **MAY** cause errors.
## About
This is a side-project which I use to learn Bash scripting and actually make my life easier when it comes to archive extraction.
It relies heavily on pre-installed programs such as:

* **tar**
* **unrar**
* **unzip** and some others...

*****NOTICE:** Currently the script supports only zip and rar.

Creates log files with details of the extraction process, timestamp and general info.
## Installation
Clone this repo `git clone https://github.com/fokditkak/xtract.git` in desired directory then `cd THE_DIR`.
If you wish to make it globally acessible simply put it in your $PATH.
## Usage
./xtract.sh [name-of-archive] - This will extract the archive in your current directory.
