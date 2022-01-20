USE ahung44assign2db;

-- 1
SELECT westernName FROM westernCourse;

-- 2
SELECT DISTINCT outsideNum FROM outsideCourse;

-- 3
SELECT * FROM westernCourse ORDER BY westernName;

-- 4
SELECT westernNum, westernName FROM westernCourse WHERE weight = 0.5;

-- 5
SELECT outsideNum, outsideName FROM outsideCourse, university WHERE outsideCourse.UID = university.UID AND UName = 'University of Toronto';

-- 6
SELECT outsideNum, nickname FROM outsideCourse, university WHERE outsideCourse.UID = university.UID AND outsideName LIKE '%Intro%';

-- 7
SELECT 
	outsideCourse.outsideName, 
	Uname, 
	westernCourse.westernName
	dateDecided 
FROM 
	westernCourse, 
	outsideCourse, 
	equivalentTo, 
	university
WHERE 
	equivalentTo.westernNum = westernCourse.westernNum 
AND equivalentTo.outsideNum = outsideCourse.outsideNum
AND equivalentTo.UID = university.UID 
AND outsideCourse.UID = university.UID
AND dateDecided < DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- 8
SELECT 
	outsideName, 
	nickname 
FROM 
	outsideCourse, 
	university,
    equivalentTo
WHERE 
	outsideCourse.UID = university.UID
AND outsideCourse.outsideNum = equivalentTo.outsideNum
AND equivalentTo.UID = university.UID
AND westernNum = 'cs1026';

-- 9
SELECT COUNT(outsideNum) 
FROM equivalentTo 
WHERE westernNum = 'cs1026' 
GROUP BY westernNum;

-- 10
SELECT 
 	westernCourse.westernName, 
 	outsideCourse.outsideName, 
 	nickname 
FROM 
 	westernCourse, 
 	outsideCourse, 
 	university, 
 	equivalentTo
WHERE 
	equivalentTo.westernNum = westernCourse.westernNum 
AND equivalentTo.outsideNum = outsideCourse.outsideNum
AND equivalentTo.UID = university.UID 
AND outsideCourse.UID = university.UID
AND outsideCourse.outsideNum IN
	(SELECT outsideNum FROM equivalentTo, university
	WHERE equivalentTo.UID = university.UID
	AND city = 'Waterloo');

-- 11
SELECT UName 
FROM university
WHERE NOT university.UID IN 
  	(SELECT UID FROM equivalentTo);

-- 12
SELECT westernName, westernNum
FROM westernCourse
WHERE westernNum IN
(SELECT westernNum 
	FROM equivalentTo JOIN outsideCourse
	ON equivalentTo.outsideNum = outsideCourse.outsideNum
    AND (yearOffered = 3 OR yearOffered = 4))

-- 13
SELECT
	westernName
FROM
	westernCourse JOIN equivalentTo
ON
	westernCourse.westernNum = equivalentTo.westernNum
GROUP BY equivalentTo.westernNum 
HAVING COUNT(equivalentTo.westernNum) >1;

-- 14
SELECT
	westernCourse.westernNum AS 'Western Course Number',
	westernCourse.westernName AS 'Western Course Name',
	westernCourse.weight AS 'Course Weight',
	outsideCourse.outsideName AS 'Other University Course Name',
	UName AS 'University Name',
	outsideCourse.weight AS 'Other Course Weight'
FROM
	westernCourse, 
 	outsideCourse, 
 	university, 
 	equivalentTo
WHERE
	equivalentTo.westernNum = westernCourse.westernNum 
AND equivalentTo.outsideNum = outsideCourse.outsideNum
AND equivalentTo.UID = university.UID 
AND outsideCourse.UID = university.UID
AND NOT westernCourse.weight = outsideCourse.weight;

	
	




	





