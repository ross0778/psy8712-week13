# Script Settings and Resources
library(DBI)
library(RPostgres)
library(tidyverse)

# Data Import and Cleaning
con <- dbConnect(
  RPostgres::Postgres(), #using postgres as specified in lecture
  user = Sys.getenv("NEON_USER"), #user and password are not included explicitly as required, instead I used Sys.getenv() to retrieve them from the .Renviron file
  password = Sys.getenv("NEON_PW"), #retrieved using Sys.getenv() from the .Renviron file
  dbname = "neondb", #this is the database name taken from the connection string
  host = "ep-billowing-union-am14lcnh-pooler.c-5.us-east-1.aws.neon.tech", #took everything after the @ symbol and before the colon and port number (:5432) for the host, did not include the port as specified in lecture 
  port = 5432, #5432 is the port right after the host in the connection string
  sslmode = "require" #sslmode is specified at the end of the connection string with ?sslmode=require
)

dbListTables(con) #this checks what tables we have access to
#to download these tables, I used dbGetQuery since this is for any procedure that returns a table. Wrote using SQL standard formatting
employees_tbl <- dbGetQuery(con, " 
                            SELECT *
                            FROM datascience_employees;
                            ")
testscores_tbl <- dbGetQuery(con, "
                             SELECT *
                             FROM datascience_testscores;
                             ")
offices_tbl <- dbGetQuery(con, "
                          SELECT *
                          FROM datascience_offices;
                          ")


