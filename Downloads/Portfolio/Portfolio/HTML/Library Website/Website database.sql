DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
Student_ID INT UNSIGNED,
Student_FName 	VARCHAR(255) NOT NULL,
Student_LName 	VARCHAR(255) NOT NULL,
Student_Gender 	ENUM('M', 'F'),
Student_Phone 	VARCHAR(12),
Student_Email 	VARCHAR(255) NOT NULL,
PRIMARY KEY (Student_ID)
);

INSERT INTO Student VALUES
(1, 'John', 'Smith', 'M', '07813345536', 'johns@gmail.com'),
(2, 'April', 'Roberson', 'F', '07704832054', 'aprilr@gmail.com'),
(3, 'Reginald', 'Peters', 'M', '07832177758', 'reginaldp@gmail.com'),
(4, 'Mamie', 'Baker', 'F', '07717269930', 'mamieb@gmail.com'),
(5, 'Laurence', 'Logan', 'M', '07806202809', 'laurencel@gmail.com'),
(6, 'Courtney', 'Mason', 'F', '07036160711', 'courtneym@gmail.com'),
(7, 'Simon', 'Jensen', 'M', '07711372109', 'simonj@gmail.com'),
(8, 'Samantha', 'Jordan', 'F', '07903939083', 'samanthaj@gmail.com'),
(9, 'Bobbie ', 'Shelton', 'M', '07725752760','bobbbies@gmail.com'),
(10, 'Angel', 'Singleton', 'F', '07751298050', 'angels@gmail.com');

DROP TABLE IF EXISTS StudentAddresses;

CREATE TABLE StudentAddresses (
Student_ID INT UNSIGNED,
Student_Address VARCHAR(255) NOT NULL,
PRIMARY KEY (Student_ID,Student_Address)
);

INSERT INTO StudentAddresses VALUES
(1, '32 Brigstock Road'),
(2, '61 Neptune Street'),
(3, '57 Cleeve Covert'),
(4, '12 Colton Avenue'),
(5, '86 Felln Hen Road'),
(6, '94 King Moorings'),
(7, '65 Hampton Highway'),
(8, '16 Shackleton Isaf'),
(9, '64 Montpelier Hollow'),
(10, '77 Neptune Ridings'),
(2, '52 Elmspire Road');

DROP TABLE IF EXISTS Librarians;

CREATE TABLE Librarians (
Librarian_ID INT UNSIGNED,	
Librarian_FName 	VARCHAR(255) NOT NULL,
Librarian_LName 	VARCHAR(255) NOT NULL,
Librarian_Gender 	ENUM('M', 'F'),
Librarian_Phone 	VARCHAR(12),
Librarian_Address 	VARCHAR(255) NOT NULL,
Librarian_Email 	VARCHAR(255) NOT NULL,
Librarian_Manager INT UNSIGNED,
PRIMARY KEY (Librarian_ID)
);

INSERT INTO Librarians VALUES
(1, 'Roger', 'Mann', 'M', '07732306560', "41 Priory Gardens", 'rogerm@gmail.com',1),
(2, 'Tabitha', 'Hines', 'F', '07925281567', "65 Primrose Hill", 'tabithah@gmail.com',1),
(3, 'Dennis', 'Ray', 'M', '07778041710', "72 East Street", 'dennisr@gmail.com',1),
(4, 'Joanne', 'Vaughn', 'F', '07989173582', "84 The Orchards", 'joannav@gmail.com',1),
(5, 'Rudolph', 'Nash', 'M', '07909251137', "61 Woodland View", 'rudolphn@gmail.com',1);

DROP TABLE IF EXISTS Borrows;

CREATE TABLE Borrows (
Borrow_ID 	INT UNSIGNED NOT NULL,
Student_ID INT UNSIGNED,
Resource_ID INT UNSIGNED,
Issued_Date 	DATE,
Return_Date 	DATE,
Librarian_ID INT UNSIGNED,
PRIMARY KEY (Borrow_ID),
FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
FOREIGN KEY (Resource_ID) REFERENCES Resources(Resource_ID),
FOREIGN KEY (Resource_ID) REFERENCES Librarians(Librarian_ID)
ON DELETE CASCADE);

INSERT INTO Borrows VALUES
(1, 1, 5, '2002-01-20', '2002-08-20',5),
(2, 1, 6, '2002-02-20', '2002-09-20',3),
(3, 2, 2, '2002-03-20', '2002-10-20',5),
(4, 3, 3, '2002-04-20', '2002-11-20',7),
(5, 3, 3, '2002-05-20', '2002-12-20',3),
(6, 4, 4, '2002-06-20', '2002-13-20',5),
(7, 5, 4, '2002-07-20', '2002-14-20',2),
(8, 7, 8, '2002-08-20', '2002-15-20',8),
(9, 9, 9, '2002-09-20', '2002-16-20',8),
(10, 8, 10, '2002-10-20', '2002-17-20',9);

DROP TABLE IF EXISTS Resources;

CREATE TABLE Resources (
Resource_ID 	INT UNSIGNED NOT NULL,
Resource_Title 	VARCHAR(255) NOT NULL,
Resource_CreationDate	DATE,
Author_ID INT UNSIGNED,
Resource_Availiability 	ENUM('Y', 'N'),
Subject_ID INT UNSIGNED,
ResourceType_ID INT UNSIGNED,
Resource_Classification 	ENUM('RP', 'NRP'),
PRIMARY KEY (Resource_ID),
UNIQUE (Resource_Title),
FULLTEXT(Resource_Title),
FOREIGN KEY (Author_ID) REFERENCES Authors(Author_ID),
FOREIGN KEY (Subject_ID) REFERENCES Subjects(Subject_ID),
FOREIGN KEY (Resource_ID) REFERENCES ResourceTypes(ResourceType_ID)
ON DELETE CASCADE);

DROP TABLE IF EXISTS ResearchPublication;

CREATE TABLE ResearchPublication (
ResearchPublication_Resource_ID	INT UNSIGNED NOT NULL,
Resource_Description 	VARCHAR(255) NOT NULL,
PRIMARY KEY (ResearchPublication_Resource_ID),
FOREIGN KEY (ResearchPublication_Resource_ID) REFERENCES Resources(Resource_ID)
ON DELETE CASCADE);

DROP TABLE IF EXISTS NonResearchPublication;

CREATE TABLE NonResearchPublication (
NonResearchPublication_Resource_ID	INT UNSIGNED NOT NULL,
Resource_Description 	VARCHAR(255) NOT NULL,
PRIMARY KEY (NonResearchPublication_Resource_ID),
FOREIGN KEY (NonResearchPublication_Resource_ID) REFERENCES Resources(Resource_ID)
ON DELETE CASCADE);

INSERT INTO Resources VALUES
(1, 'Harry Potter and the Order of the Phoenix', '2005-11-13', 2,'Y',null,1,'NRP'),
(2, 'Troubled Blood', '2007-01-20', 2,'N',null,1,'NRP'),
(3, 'Percy Jackson and the Lightning Thief', '2015-09-25', 1,'Y',null,1,'NRP'),
(4, 'Applications of proteomics to osteoarthritis, a musculoskeletal disease characterized by aging.', '2021-02-15', 4,'Y',2,2,'NRP'),
(5, 'A proteomics study of the response of North Ronaldsay sheep to copper challenge.', '2001-08-20', 4,'N',2,2,'NRP'),
(6, 'IEEE microwave and guided wave letters', '2015-01-17', 6,'Y',1,3,'NRP'),
(7, 'IEEE transactions on evolutionary computation', '2005-06-20', 6,'Y',1,3,'NRP'),
(8, 'Digital Natives: A Myth? A POLIS Paper', '2009-01-20', 3,'N',4,4,'NRP'),
(9, 'Specifying authentication using signal events in CSP', '2011-05-12', null,'Y',3,3,'RP'),
(10, 'Dying for a drink: The role of the Accident and Emergency Department', '2019-01-07', null,'Y',2,2,'RP');

DROP TABLE IF EXISTS Authors;

CREATE TABLE Authors (
Author_ID INT UNSIGNED,
Author_FName 	VARCHAR(255) NOT NULL,
Author_LName 	VARCHAR(255),
FULLTEXT(Author_FName),
FULLTEXT(Author_LName),
PRIMARY KEY (Author_ID)
);

INSERT INTO Authors VALUES
(1, 'Rick', 'Riordan'),
(2, 'J. K.', 'Rowling'),
(3, 'Das', 'Ranjana'),
(4, 'Mobasheri', 'A'),
(5, 'Afifi', 'H'),
(6, 'Institute of Electrical and Electronics Engineers', null);

DROP TABLE IF EXISTS Subjects;

CREATE TABLE Subjects (
Subject_ID INT UNSIGNED,
Subject_Name 	VARCHAR(255) NOT NULL,
PRIMARY KEY (Subject_ID)
);

INSERT INTO Subjects VALUES
(1, 'Engineering'),
(2, 'Medicine/public Health, General'),
(3, 'Computer Science');

DROP TABLE IF EXISTS ResourceTypes;

CREATE TABLE ResourceTypes (
ResourceType_ID INT UNSIGNED,
ResourceType_Name 	VARCHAR(255) NOT NULL,
PRIMARY KEY (ResourceType_ID)
);

INSERT INTO ResourceTypes VALUES
(1, 'Novel'),
(2, 'Article'),
(3, 'Journal'),
(4, 'Reports');

SELECT Resource_Title,Resource_CreationDate
FROM Resources
WHERE Resource_Availiability = 'Y'
GROUP BY Resource_CreationDate;

SELECT Resource_Title
FROM Resources
WHERE Author_ID IN (SELECT Author_ID FROM Authors WHERE CONCAT_WS(" ", Author_FName, Author_LName) = 'J. K. Rowling');

SELECT Borrows.Borrow_ID, Resources.Resource_Title AS Borrowing, CONCAT_WS(" ", Student_FName, Student_LName) AS Student_Name
FROM Borrows
INNER JOIN Resources ON Borrows.Resource_ID=Resources.Resource_ID
INNER JOIN Student ON Borrows.Student_ID=Student.Student_ID;
