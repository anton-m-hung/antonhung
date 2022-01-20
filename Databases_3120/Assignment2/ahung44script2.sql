
USE ahung44assign2db;
DELETE FROM equivalentTo;
DELETE FROM outsideCourse;
DELETE FROM university;
DELETE FROM westernCSCourse;
 
SELECT * FROM university;
LOAD DATA LOCAL INFILE 'loaddatafall2020.txt' INTO TABLE university
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	(UID, UName, city, province, nickname);
SELECT * FROM university;

SELECT * FROM westernCourse;
INSERT INTO westernCourse (westernNum, westernName, weight, suffix) VALUES ('cs1026', 'Computer Science Fundamentals I', 0.5, 'A/B');
INSERT INTO westernCourse (westernNum, westernName, weight, suffix) VALUES ('cs1027', 'Computer Science Fundamentals II', 0.5, 'A/B');
INSERT INTO westernCourse (westernNum, westernName, weight, suffix) VALUES ('cs2210', 'Algorithms and Data Structures', 1.0, "A/B");
INSERT INTO westernCourse (westernNum, westernName, weight, suffix) VALUES ('cs3319', 'Databases I', 0.5, "A/B");
INSERT INTO westernCourse (westernNum, westernName, weight, suffix) VALUES ('cs2120', 'Modern Survival Skills I: Coding Essentials', 0.5, "A/B");
INSERT INTO westernCourse (westernNum, westernName, weight, suffix) VALUES ('cs4490', 'Thesis', 0.5, "Z");
INSERT INTO westernCourse (westernNum, westernName, weight, suffix) VALUES ('cs0020', 'Intro to Coding using Pascal and Fortran', 1.0, '');
INSERT INTO westernCourse (westernNum, westernName, weight, suffix) VALUES ('cs3000', 'Steve Jobs: A Survey', 0.5, "A/B");
SELECT * FROM westernCourse;

SELECT * FROM university;
INSERT INTO university VALUES ('Oakville University', 72, 'Oakville', 'Ontario', 'Oak');
SELECT * FROM university;

SELECT * FROM outsideCourse;
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci022', 'Introduction to Programming', 1, 0.5, 2);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci033', 'Intro to Programming for Med students', 3, 0.5, 2);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci021', 'Packages', 1, 0.5, 2);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci222', 'Introduction to Databases', 2, 1.0, 2);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci023', 'Advanced Programming', 1, 0.5, 2);

INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci011', 'Intro to Computer Science', 2, 0.5, 4);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci123', 'Using UNIX', 2, 0.5, 4);

INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci021', 'Intro Programming', 1, 1.0, 66);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci022', 'Advanced Programming', 1, 0.5, 66);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci319', 'Intro Programming', 1, 1.0, 66);

INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci333', 'Graphics', 3, 0.5, 55);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci444', 'Networks', 4, 0.5, 55);

INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci022', 'Using Packages', 1, 0.5, 77);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci101', 'Introduction to Using Data Structures', 2, 0.5, 77);

INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci555', 'Music AI', 3, 0.5, 72);
INSERT INTO outsideCourse (outsideNum, outsideName, yearOffered, weight, UID) VALUES ('CompSci777', 'Computers Playing Sports', 3, 0.5, 72);
SELECT * FROM outsideCourse;

SELECT * FROM equivalentTo;
INSERT INTO equivalentTo VALUES ('cs1026', 'CompSci022', 2, '2015-05-12');
INSERT INTO equivalentTo VALUES ('cs1026', 'CompSci033', 2, '2013-01-02');
INSERT INTO equivalentTo VALUES ('cs1026', 'CompSci011', 4, '1997-02-09');
INSERT INTO equivalentTo VALUES ('cs1026', 'CompSci021', 66, '2010-01-12');
INSERT INTO equivalentTo VALUES ('cs1027', 'CompSci023', 2, '2017-06-22');
INSERT INTO equivalentTo VALUES ('cs1027', 'CompSci022', 66, '2019-09-01');
INSERT INTO equivalentTo VALUES ('cs2210', 'CompSci101', 77, '1998-07-12');
INSERT INTO equivalentTo VALUES ('cs3319', 'CompSci222', 2, '1990-09-13');
INSERT INTO equivalentTo VALUES ('cs3319', 'CompSci319', 66, '1987-09-21');
INSERT INTO equivalentTo VALUES ('cs2120', 'CompSci022', 2, '2018-12-10');
INSERT INTO equivalentTo VALUES ('cs0020', 'CompSci022', 2, '1999-09-17');
SELECT * FROM equivalentTo;

UPDATE equivalentTo SET dateDecided = '2018-09-19' WHERE westernNum = 'cs0020';
SELECT * from equivalentTo;

SELECT * FROM outsideCourse;
UPDATE outsideCourse SET yearOffered = 1 WHERE outsideName LIKE 'Intro%';
SELECT * FROM outsideCourse;
