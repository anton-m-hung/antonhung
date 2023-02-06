-- build the database
SHOW databases;
DROP DATABASE IF EXISTS ahung44assign2db;
CREATE DATABASE ahung44assign2db;
USE ahung44assign2db;

GRANT USAGE ON *.* TO 'ta'@'localhost';
DROP USER 'ta'@'localhost';
CREATE USER 'ta'@'localhost' IDENTIFIED BY 'cs3319';
GRANT ALL PRIVILEGES ON yourwesternuseridassign2db.* TO 'ta'@'localhost';
FLUSH PRIVILEGES;

SHOW TABLES;
CREATE TABLE westernCSCourse (
	courseName VARCHAR(50) NOT NULL, 
	courseCode CHAR(6) PRIMARY KEY, 
	weight FLOAT NOT NULL, 
	suffix VARCHAR(3)
); 

CREATE TABLE university (
	UName VARCHAR(50) NOT NULL, 
	UID INT NOT NULL, 
	city VARCHAR NOT NULL, 
	province VARCHAR NOT NULL, 
	nickname VARCHAR(20) NOT NULL, 
	PRIMARY KEY (UID)
);

CREATE TABLE outsideCourse (
	courseName VARCHAR(50) NOT NULL, 
	courseCode CHAR(10) NOT NULL, 
	studentYearOffered INT NOT NULL, 
	weight FLOAT NOT NULL, 
	UID INT NOT NULL, 
	FOREIGN KEY (UID) 
		REFERENCES university(UID)
		ON DELETE CASCADE
);

CREATE TABLE equivalentTo (
	courseCode CHAR(6) NOT NULL, 
	courseCode CHAR(10) NOT NULL,
	UID INT NOT NULL, 
	dateDecided DATE
);

SHOW TABLES;
