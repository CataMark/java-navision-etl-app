# ETL console utility for syncronizing data between Microsoft Navision SQL Server and PostgreSQL server

## Status
- Minimal Viable Product
- used in production by a big production company for more tnan 2 years, as of now

## Features
- all ETL steps are maintained in queries.xml file as SQL code (steps can be added/ removed)
- queries.xml file is validated by schema file
- steps are performed synchronously, one after the other
- all steps can have callbacks before/ after data transfer
- each run is logged to file
- finalization/ errors notified by mail
- on server, the utility is started by a cron job
- CI/CD based on Jenkins