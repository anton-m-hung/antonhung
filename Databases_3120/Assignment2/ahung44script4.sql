USE ahung44assign2db;

--
CREATE VIEW myview AS
SELECT 
    outsideCourse.outsideName, 
    UName, 
    nickname, 
    city, 
    westernCourse.westernName
FROM 
    outsideCourse, 
    westernCourse, 
    university, 
    equivalentTo
WHERE 
	equivalentTo.westernNum = westernCourse.westernNum 
AND equivalentTo.outsideNum = outsideCourse.outsideNum
AND equivalentTo.UID = university.UID 
AND outsideCourse.UID = university.UID
AND yearOffered = 1;

--
SELECT * FROM myview;

--
SELECT * FROM myview 
WHERE nickname = 'UofT'
ORDER BY westernName;

--
SELECT * FROM university;

--
DELETE FROM university WHERE nickname LIKE '%cord%';

--
SELECT * FROM university;

--
DELETE FROM university WHERE province = 'Ontario';

-- Ontario universities cannot be deleted because there are courses in the outsideCourse table and the equivalentTo table that are taught in these Ontario universities. We cannot delete the universities without first deleting the courses.

--
SELECT * FROM university;

--
SELECT * FROM outsideCourse INNER JOIN university ON outsideCourse.UID = university.UID;

--
DELETE FROM outsideCourse
WHERE outsideNum IN
(SELECT outsideNum
  	FROM (SELECT * FROM outsideCourse) AS tmpOutsideCourse, university
   	WHERE outsideCourse.UID = university.UID
   	AND city = 'Waterloo');

--
SELECT * FROM outsideCourse INNER JOIN university ON outsideCourse.UID = university.UID;

--
SELECT * FROM myview;



