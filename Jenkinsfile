pipeline {
    agent any
    environment {
        PSQL_LHOST_ADMIN_CRED = credentials('PSQL_LHOST_ADMIN_CRED')
        APPS_KEY = credentials('APPS_KEY')
    }
    stages {
        stage ('update production database ddl'){
            steps{
                bat "echo update table ddl"
                bat 'psql -f ./src/main/resources/pgresql/create_tables.sql "postgres://%PSQL_LHOST_ADMIN_CRED_USR%:%PSQL_LHOST_ADMIN_CRED_PSW%@localhost:5432/any"'
                bat "echo update routines ddl"
                bat 'psql -f ./src/main/resources/pgresql/create_routines.sql "postgres://%PSQL_LHOST_ADMIN_CRED_USR%:%PSQL_LHOST_ADMIN_CRED_PSW%@localhost:5432/any"'
                bat "echo update users"
                bat 'psql -f ./src/main/resources/pgresql/create_users.sql "postgres://%PSQL_LHOST_ADMIN_CRED_USR%:%PSQL_LHOST_ADMIN_CRED_PSW%@localhost:5432/any"'
            }
        }
        stage ('clean') {
            steps {
                bat "mvn clean"
            }
        }
        stage ('test') {
            steps {
                bat "mvn test"
            }
        }
        stage ('package') {
            steps {
                bat "mvn package -DskipTests"
            }
        }
        stage ('deploy'){
            steps {
                script {
                    if(fileExists("..\\..\\..\\Servers\\navetl")){
                        bat 'echo Folder-ul deja exista. Acesta va fi sters!'
                        bat 'rmdir /S /Q ..\\..\\..\\Servers\\navetl'
                    }
                }
                bat 'echo creare folder lansare'
                bat 'mkdir ..\\..\\..\\Servers\\navetl'
                script {
                    bat 'echo copiere program in noul folder'
                    def fisiere = findFiles(glob: 'target/*jar-with-dependencies.jar')
                    bat "copy /Y .\\${fisiere[0].path} ..\\..\\..\\Servers\\navetl\\navetl.jar"
                }
            }
        }
    }
}
