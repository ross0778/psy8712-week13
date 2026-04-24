# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
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

dbDisconnect(con) #this closes the databases connection now that we have the necessary data

week13_tbl <- employees_tbl %>% 
  inner_join(testscores_tbl, by = "employee_id") %>% #because we're using inner_join(), this will remove any employee without a test score
  inner_join(offices_tbl, by = c("city" = "office")) #there isn't an id column in offices_tbl, I used city from employees_tbl since this matches office (which gives the city the office is located in) in offices_tbl

write_csv(week13_tbl, "../out/week13.csv")

# Analysis
print(nrow(week13_tbl)) #total number of managers

week13_tbl %>% 
  summarize(unique_managers = n_distinct(employee_id)) %>% 
  print() #n_distinct() gives the number of unique values in a column. This actually gives the same number, 549, so this means there are 549 unique managers

week13_tbl %>% 
  filter(manager_hire == "N") %>% #filters for only employees no hired as managers
  group_by(city) %>% #groups by location
  summarize(n = n()) %>% #counts the number of managers in each city group
  print()

week13_tbl %>% 
  mutate(
    performance_level = factor( #creates levels
      performance_group, #specifies the column we're using
      levels = c("Bottom", "Middle", "Top") #specifies the three performance factors
    )
  ) %>% 
  group_by(performance_level) %>% #groups by the performance level we just created
  summarize( 
    avg_years = mean(yrs_employed), #finds the average years of years employed
    sd_years = sd(yrs_employed) #finds the standard deviation of years employed
  ) %>% 
  print()

week13_tbl %>% 
  select(office_type, employee_id, test_score) %>% #selects the appropriate rows
  arrange(office_type, desc(test_score)) %>% #arrange sorts first by office type alphabetically, then desc() for test_scores which goes from highest to lowest
  print()


