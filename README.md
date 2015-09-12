# myfxbook Interface for R

A simple interface for R to access data from [myfxbook](http://www.myfxbook.com/).

Find out more about the [myfxbook API](http://www.myfxbook.com/api).

## Installation

    library(devtools)
    install_github("DataWookie/myfxbook-for-R")

## Usage

Have a look at the file in the `demo` directory. You'll need to set up a JSON file with your myfxbook login credentials. The file contents should look something like this:

    {
        "username" : "username@gmail.com",
        "password" : "2ed2e628a257"
    }