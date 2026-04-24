# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(DBI)
library(RPostgres)

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

print(dbGetQuery(con, "
                 SELECT COUNT(*) AS total_managers
                 FROM datascience_employees
                 INNER JOIN datascience_testscores
                 USING (employee_id);
                 ")) #SELECT COUNT(*) counts the total number of rows, * is the wildcard. FROM datascience_employees is specifying from that table, INNER JOIN specifies only employees that have a test score, and USING is to join tables that have the same column name. 
print(dbGetQuery(con, "
                 SELECT COUNT(DISTINCT employee_id) AS unique_managers
                 FROM datascience_employees
                 INNER JOIN datascience_testscores
                 USING (employee_id);
                 ")) #SELECT COUNT(DISTINCT employee_id) counts the total number of only the unique values in employee_id, FROM specifies the table, INNER JOIN specifies only employees that have a test score, and USING is to join tables that have the same column name.
print(dbGetQuery(con, "
                 SELECT city, COUNT(*) AS n
                 FROM datascience_employees
                 INNER JOIN datascience_testscores
                 USING (employee_id)
                 WHERE manager_hire = 'N'
                 GROUP BY city
                 ORDER BY city ASC;
                 ")) #Selected city for location, INNER JOIN specifies only employees that have a test score, WHERE selects only people not hired as a manager, GROUP by groups by the city/location, and I ordered by ASC so that it matched the table in week13-dplyr.R
print(dbGetQuery(con, "
                 SELECT performance_group,
                 AVG(yrs_employed) AS mean_years,
                 STDDEV(yrs_employed) AS sd_years
                 FROM datascience_employees
                 INNER JOIN datascience_testscores
                 USING (employee_id)
                 GROUP BY performance_group;
                 ")) #AVG to find the mean, STDDEV to find the sd, grouped by performance group
print(dbGetQuery(con, "
                 SELECT office_type, employee_id, test_score
                 FROM datascience_employees
                 INNER JOIN datascience_testscores
                 USING (employee_id)
                 INNER JOIN datascience_offices
                  ON datascience_employees.city = datascience_offices.office
                 ORDER BY office_type ASC, test_score DESC;
                 ")) #joined for both test scores and offices, used ON since offices and office_type have different column names. Ordered by office_type ascending first and then test_score descending

dbDisconnect(con) #this closes the databases connection
