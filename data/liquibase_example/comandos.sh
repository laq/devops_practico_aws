#! /bin/bash

liquibase --driver=org.sqlite.JDBC --changeLogFile=db.changelog-master.xml --url="jdbc:sqlite:./banana_corp.sqlite" --classpath="/opt/flyway/flyway-5.0.7/drivers/sqlite-jdbc-3.20.1.jar" migrate
