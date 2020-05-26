drop database IF EXISTS project_19200254;

create database project_19200254;

use project_19200254;

-- Table creations:

CREATE TABLE stream(
  stream_id int AUTO_INCREMENT, 
  stream_name varchar(60) not null, 
  stream_code varchar(30) not null, 
  stream_description longtext not null, 
  created_date datetime not null DEFAULT CURRENT_TIMESTAMP, 
  last_modified_date datetime not null DEFAULT CURRENT_TIMESTAMP, 
  primary key (stream_id)
);


CREATE TABLE user(
  user_id varchar(10), 
  first_name varchar(25) not null, 
  last_name varchar(25), 
  date_of_birth date, 
  stream_id int not null, 
  user_role varchar(10), 
  created_date  datetime not null DEFAULT CURRENT_TIMESTAMP, 
  last_modified_date datetime not null DEFAULT CURRENT_TIMESTAMP, 
  primary key (user_id), 
  foreign key (stream_id) references stream(stream_id),
  CHECK (user_role in ('student', 'staff'))
);


CREATE TABLE login(
  login_id int AUTO_INCREMENT, 
  user_id varchar(10), 
  login_username varchar(20), 
  login_password varchar(50), 
  created_date datetime not null DEFAULT CURRENT_TIMESTAMP,
  last_modified_date datetime not null DEFAULT CURRENT_TIMESTAMP,
  primary key (login_id), 
  foreign key (user_id) references user(user_id)
);


CREATE TABLE contact(
  contact_id int AUTO_INCREMENT, 
  user_id varchar(10), 
  email varchar(25) CHECK (email like '_%@_%'), 
  phone int, 
  address varchar(70), 
  created_date  datetime not null DEFAULT CURRENT_TIMESTAMP, 
  last_modified_date datetime not null DEFAULT CURRENT_TIMESTAMP, 
  primary key (contact_id), 
  foreign key (user_id) references user(user_id), 
  UNIQUE(email, phone)
);


CREATE TABLE student(
  student_id varchar(10), 
  current_sem int, 
  gpa float, 
  created_date datetime not null DEFAULT CURRENT_TIMESTAMP,
  last_modified_date datetime not null DEFAULT CURRENT_TIMESTAMP,
  primary key (student_id), 
  foreign key (student_id) references user(user_id)
);


CREATE TABLE project(
  project_id int AUTO_INCREMENT, 
  project_title varchar(50) UNIQUE, 
  stream_id int not null, 
  supervisor_id varchar(10), 
  project_proposer_id varchar(10), 
  project_descrption longtext, 
  created_date datetime not null DEFAULT CURRENT_TIMESTAMP,
  last_modified_date datetime not null DEFAULT CURRENT_TIMESTAMP,
  primary key (project_id), 
  foreign key (supervisor_id) references user(user_id), 
  foreign key (project_proposer_id) references user(user_id), 
  foreign key (stream_id) references stream(stream_id)
);


CREATE TABLE preference(
  student_id varchar(10), 
  preference_1 int, 
  preference_2 int, 
  preference_3 int, 
  preference_4 int, 
  preference_5 int, 
  preference_6 int, 
  preference_7 int, 
  preference_8 int, 
  preference_9 int, 
  preference_10 int, 
  preference_11 int, 
  preference_12 int, 
  preference_13 int, 
  preference_14 int, 
  preference_15 int, 
  preference_16 int, 
  preference_17 int, 
  preference_18 int, 
  preference_19 int, 
  preference_20 int, 
  created_date  datetime not null DEFAULT CURRENT_TIMESTAMP, 
  last_modified_date datetime not null DEFAULT CURRENT_TIMESTAMP, 
  primary key (student_id), 
  foreign key (student_id) references student(student_id), 
  FOREIGN KEY (PREFERENCE_1) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_2) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_3) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_4) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_5) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_6) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_7) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_8) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_9) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_10) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_11) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_12) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_13) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_14) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_15) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_16) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_17) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_18) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_19) REFERENCES project (project_id), 
  FOREIGN KEY (PREFERENCE_20) REFERENCES project (project_id)
);


CREATE TABLE project_allocations(
  student_id varchar(10) not null, 
  project_id int unique, 
  global_satisfaction_score int, 
  created_date  datetime not null DEFAULT CURRENT_TIMESTAMP, 
  last_modified_date datetime not null DEFAULT CURRENT_TIMESTAMP, 
  primary key (student_id), 
  foreign key (student_id) references student(student_id), 
  foreign key (project_id) references project(project_id)
);

-- Stored Procedures creation;

--- Insert users into user table and create their login records in login table

DROP PROCEDURE IF EXISTS `insert_users`;
DELIMITER $$
CREATE PROCEDURE `insert_users`(
IN user_id varchar(10), 
IN first_name varchar(25) , 
IN last_name varchar(25), 
IN date_of_birth date, 
IN stream_id int , 
IN user_role varchar(10) )
BEGIN
SET  @pass = concat_ws('@',first_name,CAST(date_of_birth AS DATE));

IF stream_id > 2 
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Enter a valid stream id';
	END IF;
    
 IF (user_role != "staff" AND user_role !=  "student")
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Enter a valid user role';
	END IF;   
    
INSERT INTO user(user_id,first_name,last_name,date_of_birth,stream_id,user_role)
	values(user_id,first_name,last_name,date_of_birth,stream_id,user_role);
    
    INSERT INTO login(user_id,login_username,login_password) 
		values(user_id,user_id,@pass) ;
END$$

DELIMITER ;

-- Trigger creation:

-- User table trigger

DROP TRIGGER IF EXISTS user_bi_trig ;
DELIMITER $$
CREATE TRIGGER `user_bi_trig` BEFORE INSERT ON `user` FOR EACH ROW BEGIN
	IF EXISTS(select * from user where user_id=new.user_id)
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'User is already part of the system';
	END IF;
END$$
DELIMITER ;


-- Login table trigger (before insert and before update)

DROP TRIGGER IF EXISTS login_bi_trig ;
DELIMITER $$
CREATE  TRIGGER `login_bi_trig` BEFORE INSERT ON `login` FOR EACH ROW BEGIN
	IF NOT EXISTS(select * from user where user_id=new.user_id)
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'User is not part of the system';
	END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS login_bu_trig ;
DELIMITER $$
CREATE TRIGGER `login_bu_trig` BEFORE UPDATE ON `login` FOR EACH ROW BEGIN
	IF NOT EXISTS(select * from user where user_id=new.user_id)
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'User is not part of the system';
	END IF;
END$$
DELIMITER ;

-- Project table trigger (before insert and before update)
DROP TRIGGER IF EXISTS project_bi_trig;

DELIMITER $$
CREATE TRIGGER `project_bi_trig` BEFORE INSERT ON `project` FOR EACH ROW
BEGIN

IF  NOT EXISTS(SELECT * FROM user WHERE user_id=NEW.supervisor_id and user_role = "staff") 
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Supervisor id entered is not a staff member';
	ELSEIF NOT EXISTS(SELECT * FROM user WHERE user_id=NEW.project_proposer_id)
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Invalid project proposer ID';
	END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS project_bu_trig;

DELIMITER $$
CREATE TRIGGER `project_bu_trig` BEFORE UPDATE ON `project` FOR EACH ROW
BEGIN

IF  NOT EXISTS(SELECT * FROM user WHERE user_id=NEW.supervisor_id and user_role = "staff") 
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Supervisor id entered is not a staff member';
	ELSEIF NOT EXISTS(SELECT * FROM user WHERE user_id=NEW.project_proposer_id)
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Invalid project proposer ID';
	END IF;
END$$
DELIMITER ;

-- Contact table trigger (before insert and before update)
DROP TRIGGER IF EXISTS contact_bi_trig;

DELIMITER $$
CREATE TRIGGER `contact_bi_trig` BEFORE INSERT ON `contact` FOR EACH ROW
BEGIN

IF  NOT EXISTS(SELECT * FROM user WHERE user_id=NEW.user_id) 
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'User is not part of the system';
	END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS contact_bu_trig;

DELIMITER $$
CREATE TRIGGER `contact_bu_trig` BEFORE UPDATE ON `contact` FOR EACH ROW
BEGIN

IF  NOT EXISTS(SELECT * FROM user WHERE user_id=NEW.user_id) 
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'User is not part of the system';
	END IF;
END$$
DELIMITER ;

-- Student table trigger (before insert and before update)
DROP TRIGGER IF EXISTS student_bi_trig;

DELIMITER $$
CREATE TRIGGER `student_bi_trig` BEFORE INSERT ON `student` FOR EACH ROW
BEGIN

IF  NOT EXISTS(SELECT * FROM user WHERE user_id=NEW.student_id AND user_role="student") 
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Enter a valid student_id';
ELSEIF new.current_sem > 4
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Enter a valid semester';          
ELSEIF new.gpa < 0 or new.gpa > 4.2
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'GPA can only be between 0 to 4.2';        
	END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS student_bu_trig;

DELIMITER $$
CREATE TRIGGER `student_bu_trig` BEFORE UPDATE ON `student` FOR EACH ROW
BEGIN

IF  NOT EXISTS(SELECT * FROM user WHERE user_id=NEW.student_id AND user_role="student") 
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Enter a valid student_id';
ELSEIF new.current_sem > 4
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Enter a valid semester';          
ELSEIF new.gpa < 0 or new.gpa > 4.2
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'GPA can only be between 0 to 4.2';        
	END IF;
END$$
DELIMITER ;

-- Preference table trigger

DROP TRIGGER IF EXISTS `pref_bi_trig`;
DELIMITER $$
CREATE TRIGGER `pref_bi_trig` BEFORE INSERT ON `preference` FOR EACH ROW
BEGIN
    DECLARE std_stream INT;
    DECLARE std_sem int;
	SELECT stream_id INTO std_stream FROM user WHERE user_id=new.student_id;
	SELECT std.current_sem INTO std_sem FROM  student std Where student_id = new.student_id;
    
    DROP TEMPORARY TABLE IF EXISTS temp_pref;
    CREATE TEMPORARY TABLE temp_pref(Preference INT);
    
    INSERT INTO temp_pref VALUES (new.preference_1),(new.preference_2),(new.preference_3),(new.preference_4),(new.preference_5 ),
	(new.preference_6 ),(new.preference_7 ),(new.preference_8),(new.preference_9 ),(new.preference_10 ),(new.preference_11 ),(new.preference_12),
    (new.preference_13 ),(new.preference_14 ),(new.preference_15 ),(new.preference_16),(new.preference_17 ),(new.preference_18 ),(new.preference_19 ),(new.preference_20);
    
	IF  NOT EXISTS(SELECT * FROM student WHERE student_id=NEW.student_id) 
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Enter a valid student_id';
	ELSEIF (std_sem != 3)
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Only students from 3rd semester can give preference.';
	ELSEIF NEW.preference_1 IS NULL  
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Preference 1 is a must';  
	ELSEIF EXISTS(SELECT * FROM temp_pref tpf INNER JOIN project p ON tpf.Preference=p.project_id WHERE p.stream_id<>std_stream AND p.STREAM_ID <> 3)
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Entered project preference does not belong to students stream'; 
    
 	END IF;
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS `pref_bu_trig`;
DELIMITER $$
CREATE TRIGGER `pref_bu_trig` BEFORE UPDATE ON `preference` FOR EACH ROW
BEGIN
    DECLARE std_stream INT;
    DECLARE std_sem int;
	SELECT stream_id INTO std_stream FROM user WHERE user_id=new.student_id;
	SELECT std.current_sem INTO std_sem FROM  student std Where student_id = new.student_id;
    
    DROP TEMPORARY TABLE IF EXISTS temp_pref;
    CREATE TEMPORARY TABLE temp_pref(Preference INT);
    
    INSERT INTO temp_pref VALUES (new.preference_1),(new.preference_2),(new.preference_3),(new.preference_4),(new.preference_5 ),
	(new.preference_6 ),(new.preference_7 ),(new.preference_8),(new.preference_9 ),(new.preference_10 ),(new.preference_11 ),(new.preference_12),
    (new.preference_13 ),(new.preference_14 ),(new.preference_15 ),(new.preference_16),(new.preference_17 ),(new.preference_18 ),(new.preference_19 ),(new.preference_20);
    
	IF  NOT EXISTS(SELECT * FROM student WHERE student_id=NEW.student_id) 
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Enter a valid student_id';
	ELSEIF (std_sem != 3)
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Only students from 3rd semester can give preference.';
	ELSEIF NEW.preference_1 IS NULL  
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Preference 1 is a must';  
	ELSEIF EXISTS(SELECT * FROM temp_pref tpf INNER JOIN project p ON tpf.Preference=p.project_id WHERE p.stream_id<>std_stream AND p.STREAM_ID <> 3)
		THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Entered project preference does not belong to students stream'; 
    
 	END IF;
END$$
DELIMITER ;

-- Project allocation table trigger (before insert and before update)

DROP TRIGGER IF EXISTS project_allocations_bi_trig ;
DELIMITER $$
CREATE TRIGGER `project_allocations_bi_trig` BEFORE INSERT ON `project_allocations` FOR EACH ROW BEGIN
DECLARE std_stream int;
DECLARE proj_stream int; 
     
SELECT stream_id INTO proj_stream FROM project where project_id = new.project_id; 
SELECT stream_id INTO std_stream FROM user where user_id=new.student_id; 	
 
IF EXISTS (select * from project_allocations WHERE project_id=new.project_id)
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Project has already been allotted to a different student.';
ELSEIF (proj_stream <> std_stream AND proj_stream <> 3)
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Students must be allocated a project of their stream.';

END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS project_allocations_bu_trig ;
DELIMITER $$
CREATE TRIGGER `project_allocations_bu_trig` BEFORE UPDATE ON `project_allocations` FOR EACH ROW BEGIN
DECLARE std_stream int;
DECLARE proj_stream int; 
     
SELECT stream_id INTO proj_stream FROM project where project_id = new.project_id; 
SELECT stream_id INTO std_stream FROM user where user_id=new.student_id; 	
 
IF EXISTS (select * from project_allocations WHERE project_id=new.project_id)
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Project has already been allotted to a different student.';
ELSEIF (proj_stream <> std_stream AND proj_stream <> 3)
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Students must be allocated a project of their stream.';

END IF;
END$$
DELIMITER ;


-- View creation

-- Creating view to see complete student details
DROP VIEW IF EXISTS vw_student_details;

CREATE 
VIEW `vw_student_details` AS 
select 
`sd`.`student_id` AS `student_id`,
concat(usr.first_name," ",usr.last_name) AS `name`,
`sd`.`current_sem` AS `current_sem`,
`str`.`stream_name` AS `stream`,
`sd`.`gpa` AS `GPA`,
`cnt`.`email` AS `email_id`,
`cnt`.`phone` AS `phone_number`
from (((
`student` `sd` 
join `user` `usr` on((`usr`.`user_id` = `sd`.`student_id`))) 
join `stream` `str` on((`str`.`stream_id` = `usr`.`stream_id`))) 
join `contact` `cnt` on((`cnt`.`user_id` = `sd`.`student_id`)));

---- Creating view to see complete staff details
DROP VIEW IF EXISTS vw_staff_details;

CREATE 
VIEW `vw_staff_details` AS 
select 
`usr`.`user_id` AS `staff_id`,
concat(usr.first_name," ",usr.last_name) AS `name`,
`str`.`stream_name` AS `stream`,
`cnt`.`email` AS `email_id`,
`cnt`.`phone` AS `phone_number`
 from ((
 `user` `usr` 
 join `contact` `cnt` on((`cnt`.`user_id` = `usr`.`user_id`))) 
 join `stream` `str` on((`str`.`stream_id` = `usr`.`stream_id`))) 
 where (`usr`.`user_role` = 'staff');

---- Project belonging to stream 1 (CS) or stream 3(CS and/or CS+DS)

DROP VIEW IF EXISTS cs_projects;

CREATE 
VIEW `cs_projects` AS 
select 
`project`.`project_id` AS `project_id`,
`project`.`project_title` AS `project_title`,
`project`.`stream_id` AS `stream_id`,
`str`.`stream_name` AS `stream_name`,
`project`.`project_descrption` AS `project_descrption`,
concat(usr.first_name," ",usr.last_name) AS  `supervisor` 
from ((
`project` 
join `user` `usr` on((`usr`.`user_id` = `project`.`supervisor_id`))) 
join `stream` `str` on((`str`.`stream_id` = `project`.`stream_id`))) 
where (`project`.`stream_id` = 1 or `project`.`stream_id` = 3);


---- Project belonging to stream 2 (CS + DS) or stream 3(CS and/or CS+DS)
DROP VIEW IF EXISTS cs_ds_projects;

CREATE VIEW `cs_ds_projects` AS 
select 
`project`.`project_id` AS `project_id`,
`project`.`project_title` AS `project_title`,
`project`.`stream_id` AS `stream_id`,
`str`.`stream_name` AS `stream_name`,
`project`.`project_descrption` AS `project_descrption`,
concat(usr.first_name," ",usr.last_name) AS  `supervisor` 
from ((
`project` 
join `user` `usr` on((`usr`.`user_id` = `project`.`supervisor_id`))) 
join `stream` `str` on((`str`.`stream_id` = `project`.`stream_id`))) 
where (`project`.`stream_id` = 2 or `project`.`stream_id` = 3);

-- Record inserts:

-- Inserting values into stream table

INSERT INTO stream (stream_name, stream_code, stream_description)
VALUES ("Cthulhu Studies","CS","Cthulhu Studies deals with study about various sports in the world"),
("Cthulhu Studies with specialisation in Dagon Studies","CS+DS","This stream deals with study of various sports in the world with specialisation in football"),
 ("Cthulhu Studies and/or Dagon studies","CS and/or CS+DS","Projects suitable for both the streams");
-- Inserting student details into user table


CALL insert_users("20STD001","Mike","Pence","2001-10-12",1,"student"); 
CALL insert_users("20STD002","James","Robert","2001-11-25",1,"student"); 
CALL insert_users("20STD003","Audrey","Jack","2002-01-15",2,"student"); 
CALL insert_users("20STD004","Georgia","Juliet","2002-09-12",2,"student"); 
CALL insert_users("20STD005","Lily","Olive","2002-12-01",1,"student"); 
CALL insert_users("20STD006","Alfie","Edward","2002-06-02",2,"student"); 
CALL insert_users("20STD007","Ella","Garcia","2001-08-15",1,"student"); 
CALL insert_users("20STD008","Kendall","Sutton","2001-07-09",1,"student"); 
CALL insert_users("20STD009","Madison","Willow","2001-09-17",1,"student"); 
CALL insert_users("20STD010","Kinsley","Winter","2003-08-12",2,"student"); 
CALL insert_users("20STD011","Marley","Garcia","2003-07-12",2,"student"); 
CALL insert_users("20STD012","Peyton","Presley","2003-08-08",2,"student"); 
CALL insert_users("20STD013","Abella","Wren","2003-02-25",1,"student"); 
CALL insert_users("20STD014","Araminta","Birch","2002-03-30",1,"student"); 
CALL insert_users("20STD015","Arden","Booker","2001-05-21",2,"student"); 
CALL insert_users("20STD016","Blythe","Clover","2003-09-19",1,"student");
CALL insert_users("20STD017","Jack","Benning","2002-03-22",1,"student");
CALL insert_users("20STD018","Mike","Ryan","2002-05-01",1,"student");
CALL insert_users("20STD019","Paul","Mark","2001-04-25",1,"student");
CALL insert_users("20STD020","Chris","Sutter","2001-06-11",1,"student");
CALL insert_users("20STD222","Jack","Micharney","2003-05-11",1,"student");
CALL insert_users("20STD225","Jack","Micharney","2003-05-11",1,"student");
CALL insert_users("20STD226","Jack","Micharney","2003-05-11",1,"student");
-- Inserting staff details into user table


CALL insert_users("01STF001","Mike","Lancaster","1987-05-12",1,"staff"); 
CALL insert_users("01STF002","Hendrix","Huffington","1985-06-02",1,"staff"); 
CALL insert_users("01STF003","Maverick","River","1986-11-25",2,"staff"); 
CALL insert_users("01STF004","Dakota","Marigold","1987-04-08",1,"staff"); 
CALL insert_users("01STF005","Drake","Booker","1985-12-22",2,"staff"); 
CALL insert_users("01STF006","Holden","Huck","1988-04-25",1,"staff");



-- Inserting contact details into contact table

INSERT INTO contact(user_id,email,phone,address)
VALUES("20STD001","20STD001@cds.ie",0874569321,"341,Abbey Street,Fingal,Dublin"),
("20STD002","20STD002@cds.ie",0858746986,"88,Ailesbury Road,South Dublin,Dublin"),
("20STD003","20STD003@cds.ie",0896325478,"03,Baggot Street,Dun Laoghaire–Rathdown,Dublin"),
("20STD004","20STD004@cds.ie",0863257456,"05,Bayside Boulevard,Dun Laoghaire–Rathdown,Dublin"),
("20STD005","20STD005@cds.ie",0832547862,"88,Bridge Street,South Dublin,Dublin"),
("20STD006","20STD006@cds.ie",0893254778,"87,Capel Street,Dun Laoghaire–Rathdown,Dublin"),
("20STD007","20STD007@cds.ie",0887445213,"36,Dame Street,Fingal,Dublin"),
("20STD008","20STD008@cds.ie",0899654213,"12,Dorset Street,South Dublin,Dublin"),
("20STD009","20STD009@cds.ie",0896541236,"68,Gilford Road,Dun Laoghaire–Rathdown,Dublin"),
("20STD010","20STD010@cds.ie",0855478227,"35,Leeson Street,South Dublin,Dublin"),
("20STD011","20STD011@cds.ie",0866321546,"74,Capel Street,Fingal,Dublin"),
("20STD012","20STD012@cds.ie",0899546325,"36,Merrion Square,South Dublin,Dublin"),
("20STD013","20STD013@cds.ie",0832546956,"99,Dame Street,Fingal,Dublin"),
("20STD014","20STD014@cds.ie",0863254566,"32,North Circular Road,,Dublin"),
("20STD015","20STD015@cds.ie",0846963588,"77,Merrion Street,South Dublin,Dublin"),
("20STD016","20STD016@cds.ie",0896545645,"50,Capel Street,Dun Laoghaire–Rathdown,Dublin"),
("20STD017","20STD017@cds.ie",0899655412,"82,Merrion Square,Dun Laoghaire–Rathdown,Dublin"),
("20STD018","20STD018@cds.ie",0899655689,"32,Dorset Street,South Dublin,Dublin"),
("20STD019","20STD019@cds.ie",0895874412,"22,Merrion Square,Dun Laoghaire–Rathdown,Dublin"),
("20STD020","20STD020@cds.ie",0893221689,"89,Dorset Street,South Dublin,Dublin"),
("01STF001","01STF001@cds.ie",0855213252,"12,Dame Street,Fingal,Dublin"),
("01STF002","01STF002@cds.ie",0826565482,"22,Capel Street,Dun Laoghaire–Rathdown,Dublin"),
("01STF003","01STF003@cds.ie",0833221452,"66,Leeson Street,South Dublin,Dublin"),
("01STF004","01STF004@cds.ie",0866221456,"99,Gilford Road,Dun Laoghaire–Rathdown,Dublin"),
("01STF005","01STF005@cds.ie",0833245567,"33,Dorset Street,Fingal,Dublin"),
("01STF006","01STF006@cds.ie",0833214568,"11,Capel Street,South Dublin,Dublin"),
("20STD222","20STD022@cds.ie",0833214568,"21,Dorset Street,South Dublin,Dublin");

-- Inserting student details into student table

INSERT INTO student(student_id,current_sem,gpa) 
VALUES ("20STD001",3,3.5),
("20STD002","3",3.7),
("20STD003",3,3.8),
("20STD004",3,3.9),
("20STD005",3,4.1),
("20STD006",3,4.0),
("20STD007",3,3.8),
("20STD008",3,3.5),
("20STD009",3,3.3),
("20STD010",3,3.8),
("20STD011",3,3.6),
("20STD012",3,3.3),
("20STD013",3,3.1),
("20STD014",3,3.8),
("20STD015",3,3.4),
("20STD016",3,3.1),
("20STD017",3,3.3),
("20STD018",3,3.8),
("20STD019",3,1.3),
("20STD020",3,2.8),
("20STD225",3,3.5),
("20STD226",2,3.5);


-- Inserting project details into project table

INSERT INTO project
VALUES(null,"Sports and games in europe",1,"01STF001","01STF001"," Study about sports and games in europe",curdate(),curdate()),
(null,"Sports and games in asia",1,"01STF002","01STF002"," Study about sports and games in asia",curdate(),curdate()), 
(null,"Sports and games in africa",1,"01STF006","01STF006"," Study about sports and games in africa",curdate(),curdate()), 
(null,"Sports and games in north america",1,"01STF004","01STF004"," Study about sports and games in north america",curdate(),curdate()), 
(null,"Sports and games in south america",1,"01STF001","01STF001"," Study about sports and games in south america",curdate(),curdate()), 
(null,"Sports and games in antartica",1,"01STF002","01STF002"," Study about sports and games in antartica",curdate(),curdate()), 
(null,"Sports and games in australia",1,"01STF006","01STF006"," Study about sports and games in australia",curdate(),curdate()), 
(null,"Sports and games in ireland",3,"01STF001","01STF001"," Study about sports and games in ireland",curdate(),curdate()), 
(null,"Sports and games in USA",1,"01STF002","01STF002"," Study about sports and games in USA",curdate(),curdate()), 
(null,"Sports and games in Germany",1,"01STF004","01STF004"," Study about sports and games in Germany",curdate(),curdate()), 
(null,"Sports and games in UK",3,"01STF006","01STF006"," Study about sports and games in UK",curdate(),curdate()), 
(null,"Football in europe",2,"01STF003","01STF003"," Study about football in europe",curdate(),curdate()), 
(null,"Football in ireland",2,"01STF003","01STF003"," Study about football in ireland",curdate(),curdate()), 
(null,"Football in africa",2,"01STF005","01STF005"," Study about football in africa",curdate(),curdate()), 
-- project proposed by student
(null,"Football in antartica",2,"01STF005","20STD003"," Study about football in antartica",curdate(),curdate()), 
(null,"Football in asia",2,"01STF005","20STD012"," Study about football in asia",curdate(),curdate()),
--
(null,"Football in sweden",2,"01STF001","01STF001"," Study about football in sweden",curdate(),curdate()),
(null,"Sports and games in russia",1,"01STF005","01STF005"," Study about sports and games in russia",curdate(),curdate()),
(null,"Football in olympics",2,"01STF005","01STF005"," Study about football in olympics",curdate(),curdate()),
(null,"Football in asian games",2,"01STF005","01STF005"," Study about football in asian games",curdate(),curdate()),

(null,"Sports and games in Denmark",1,"01STF006","01STF006"," Study about sports and games in Denmark",curdate(),curdate()),
(null,"Sports and games in LA",1,"01STF006","01STF006","Study about sports and games in LA",curdate(),curdate());


-- Inserting project preference details into preference table
 
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4,preference_5,preference_6,preference_7) values ("20STD001",1,5,3,6,9,11,18);
INSERT INTO preference (student_id,preference_1,preference_2) values ("20STD002",3,6);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4) values ("20STD003",15,13,14,12);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4) values ("20STD004",17,12,13,14);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4,preference_5) values ("20STD005",1,2,11,7,9);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3) values ("20STD006",16,14,8);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4) values ("20STD007",9,18,4,11);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4) values ("20STD008",10,11,1,3);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4,preference_5) values ("20STD009",11,3,4,5,6);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4,preference_5,preference_6) values ("20STD010",8,16,11,12,15,13);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4,preference_5,preference_6) values ("20STD011",12,13,14,15,16,17);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4,preference_5) values ("20STD012",16,12,13,17,14);
INSERT INTO preference (student_id,preference_1,preference_2) values ("20STD013",11,18);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4) values ("20STD014",3,6,9,18);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4,preference_5,preference_6) values ("20STD015",15,14,13,12,16,17);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4) values ("20STD016",7,8,18,5);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4) values ("20STD017",1,3,5,7);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4,preference_5) values ("20STD018",2,4,6,8,10);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3) values ("20STD019",21,1,2);
INSERT INTO preference (student_id,preference_1,preference_2,preference_3,preference_4) values ("20STD020",22,3,5,7);

-- Inserting alloted project details details into project allocations table

INSERT INTO project_allocations(student_id,project_id,global_satisfaction_score) VALUES
("20STD001",1,6), 
("20STD002",3,1),
("20STD003",15,2), 
("20STD004",17,4), 
("20STD005",2,6),
("20STD006",14,3),
("20STD007",9,6), 
("20STD008",10,9), 
("20STD009",11,6), 
("20STD010",12,6), 
("20STD011",13,2), 
("20STD012",16,8), 
("20STD013",18,2), 
("20STD014",6,7), 
("20STD015",19,6), 
("20STD016",7,2), 
("20STD017",4,9), 
("20STD018",8,3),
("20STD019",21,6), 
("20STD020",22,4); 

-- Queries

-- Final projects alloted

SELECT
  pa.`student_id`,
  concat(usr.first_name," ",usr.last_name) AS `Student Name`,
  pa.project_id,
  `p`.`project_title`,
  `pa`.`global_satisfaction_score`,
  stf.name as supervisor,
  str.stream_name as 'project stream'
  FROM project_allocations as pa
  join project p on p.project_id = pa.project_id
  inner join user usr on usr.user_id = pa.student_id
  join stream str on str.stream_id = p.stream_id
  join vw_staff_details stf on stf.staff_id = p.supervisor_id
  order by student_id;

-- Number of projects owned by each supervisor

SELECT 
p.supervisor_id,
concat(usr.first_name," ",usr.last_name)  as supervisor_name,
count(*) as total_no_of_projects
FROM Project as p
join user usr on usr.user_id = p.supervisor_id
GROUP BY p.supervisor_id;

-- Projects proposed by students

SELECT `project_id`,
    `project_title`,
    p.stream_id,
    `supervisor_id`,
    `project_proposer_id`,
    `project_descrption`
 FROM `project` p
 inner join user usr on usr.user_id = p.project_proposer_id
 Where usr.user_role = "student";

-- Students who are not aloted a project
SELECT std.student_id,concat(usr.first_name," ",usr.last_name)  as 'student name',std.current_sem,stream_id as 'student stream' from student std
join user usr on usr.user_id=std.student_id
WHERE student_id NOT IN (
SELECT student_id from project_allocations);

-- Projects which are not allotted
SELECT project_id,project_title,stream_name AS 'project stream' from project p 
inner join stream str on str.stream_id=p.stream_id
WHERE project_id NOT IN (
SELECT project_id from project_allocations);

-- Records for testing triggers, queries to test have been commented

-- Test for Procedure (insert_users)

	-- procedure checks for invalid stream 
	-- CALL insert_users("20STD023","Jack","Micharney","2003-05-11",3,"student"); 

	-- procedure checks for invalid user_role 
	-- CALL insert_users("20STD023","Jack","Micharney","2003-05-11",2,"stand");

-- test for user table trigger (user_bi_trig)

    -- if user is already present
	-- CALL insert_users("20STD001","Mike","Pence","2001-10-12",1,"student");

-- test for login table trigger (login_bi_trig)

	-- checks if user is present or not
	-- INSERT INTO login(user_id,login_username,login_password) values("20STD111","username","pass") ; 
 
-- test for project table trigger (project_bi_trig)

	-- supervisor ID not a staff member
	-- INSERT INTO project VALUES(null,"Sports and games in europe",1,"20STD001","01STF001"," Study about  and games in europe",curdate(),curdate()); 

	-- invalid project proposer id
	-- INSERT INTO project VALUES(null,"Sports and games in europe",1,"01STF001","05fff001"," Study about  and games in europe",curdate(),curdate()); 

-- test for contact table trigger (contact_bu_trig)

	-- valid user id or not
	-- INSERT INTO contact(user_id,email,phone,address) VALUES("20STD111","20STD001@cds.ie",0874569321,"341,Abbey Street,Fingal,Dublin"); 

-- test for student table trigger (student_bi_trig)

	-- checks for valid student ID
	-- INSERT INTO student(student_id,current_sem,gpa) VALUES ("20STD111",3,3.5); 

	-- checks for valid semester
	-- INSERT INTO student(student_id,current_sem,gpa) VALUES ("20STD222",5,3.5); 

	-- checks for valid gpa
	-- INSERT INTO student(student_id,current_sem,gpa) VALUES ("20STD222",3,4.8); 

-- test for preference table trigger (pref_bi_trig)
	
    -- checks for valid student ID
	-- INSERT INTO preference (student_id,preference_1,preference_2) values ("20STD112",3,6); 

	-- only 3rd sem students can give preference
	-- INSERT INTO preference (student_id,preference_1,preference_2) values ("20STD226",3,6); 
 
	-- check for mimimum of one preference
	-- INSERT INTO preference (student_id) values ("20STD225");

	-- check if project entered belongs to students stream
	-- INSERT INTO preference (student_id,preference_1,preference_2) values ("20STD225",3,14); 

-- test for project allocation table trigger (project_allocations_bi_trig)
	
    -- checks if project is already allotted or not
	-- INSERT INTO project_allocations(student_id,project_id,global_satisfaction_score) VALUES ("20STD225",1,6); 

	-- checks if project alloted belongs to student stream
	-- INSERT INTO project_allocations(student_id,project_id,global_satisfaction_score) VALUES ("20STD225",20,6); 
