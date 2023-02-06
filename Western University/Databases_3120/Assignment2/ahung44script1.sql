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
CREATE TABLE westernCourse (
	westernNum CHAR(6) PRIMARY KEY,
  	westernName VARCHAR(50) NOT NULL, 
	weight REAL(2,1) NOT NULL, 
	suffix VARCHAR(3)
); 

CREATE TABLE university (
	UName VARCHAR(50) NOT NULL, 
	UID TINYINT PRIMARY KEY NOT NULL, 
	city VARCHAR(50) NOT NULL, 
	province VARCHAR(50) NOT NULL, 
	nickname VARCHAR(20) NOT NULL
);

CREATE TABLE outsideCourse (
	outsideNum CHAR(10) NOT NULL, 
	outsideName VARCHAR(50) NOT NULL, 
    yearOffered INT NOT NULL, 
	weight REAL(2,1) NOT NULL, 
	UID TINYINT NOT NULL, 
	FOREIGN KEY (UID) 
		REFERENCES university(UID),
	PRIMARY KEY (outsideNum, UID)
);

CREATE TABLE equivalentTo (
	westernNum CHAR(6) NOT NULL,
	FOREIGN KEY(westernNum)
		REFERENCES westernCourse(westernNum)
		ON DELETE CASCADE,
	outsideNum CHAR(10) NOT NULL,
	UID TINYINT NOT NULL, 
	FOREIGN KEY (outsideNum, UID)
		REFERENCES outsideCourse(outsideNum, UID)
		ON DELETE CASCADE,
	dateDecided DATE NOT NULL,
	PRIMARY KEY (westernNum , outsideNum, UID)
);

SHOW TABLES;
