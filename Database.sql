-- child tablomuz
CREATE TABLE child(
	id INT PRIMARY KEY,
	fname VARCHAR(20),
	lname VARCHAR(20),
	birthDate DATE,
	CONSTRAINT check_age CHECK(EXTRACT(YEAR FROM age(current_date, birthDate)) BETWEEN 2 AND 5) 
);

-- 2 yaşına girmemiş, 5 yaşında büyük
-- INSERT INTO child VALUES(1, 'X', 'Y', '06-01-2021');
-- INSERT INTO child VALUES(2, 'Z', 'Y', '05-01-2017');

-- parent tablomuz
CREATE TABLE parent(
	childId INT PRIMARY KEY,
	fname VARCHAR(20),
	lname VARCHAR(20),
	relationship CHAR(4),
	gender CHAR(5),
	phone CHAR(14),
	CONSTRAINT fkey_childId FOREIGN KEY(childId) REFERENCES child(id) ON DELETE CASCADE
);

-- class tablomuz
CREATE TABLE class(
	id INT PRIMARY KEY,
	name CHAR(7),
	size INT DEFAULT 0,
	CONSTRAINT check_size CHECK(size < 26) 
);

-- enrollmentPrice tablomuz
CREATE TABLE enrollmentPrice(
	type VARCHAR(9) PRIMARY KEY,
	timeInterval CHAR(13),
	price NUMERIC(7,2)
);

-- enrollment tablomuz
CREATE TABLE enrollment(
	childId INT PRIMARY KEY,
	paymentType VARCHAR(6),
	enrollmentType VARCHAR(9),
	classId INT,
	CONSTRAINT fkey_childId FOREIGN KEY(childId) REFERENCES child(id) ON DELETE CASCADE,
	CONSTRAINT fkey_enrollmentType FOREIGN KEY(enrollmentType) REFERENCES enrollmentPrice(type),
	CONSTRAINT fkey_classId_Enrollment FOREIGN KEY(classId) REFERENCES class(id)
);

-- teacher tablomuz
CREATE TABLE teacher(
	id SERIAL PRIMARY KEY,
	fname VARCHAR(20),
	lname VARCHAR(20),
	salary NUMERIC(7,2),
	classId INT,
	CONSTRAINT fkey_classId_Teacher FOREIGN KEY(classId) REFERENCES class(id) 
);


-- trigger (1) - Cinsiyete göre yakınlık derecesi trigger ile eklenir
CREATE OR REPLACE FUNCTION funcRelationshipType() RETURNS TRIGGER AS $$
BEGIN
	IF (new.gender = 'Kadın') THEN
		UPDATE parent SET relationship = 'Anne' WHERE childId = new.childId;
	ELSE
		UPDATE parent SET relationship = 'Baba' WHERE childId = new.childId;
	END IF;
	RAISE INFO 'Evebeynin ilişki türü trigger ile eklendi';
	RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggerRelationshipType
AFTER INSERT 
ON parent
FOR EACH ROW EXECUTE PROCEDURE funcRelationshipType();

-- trigger (2) - Yeni eklenen çocuğun yaşına göre sınıfın size bilgisi arttırılır
CREATE OR REPLACE FUNCTION funcIncreaseSizeOfClass() RETURNS TRIGGER AS $$
BEGIN
	UPDATE class
	SET size = size + 1
	WHERE id = new.classId;
	RAISE INFO '%. sınıfın sınıf mevcudu bir arttırıldı', new.classId;
	RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggerIncreaseSizeOfClass
AFTER INSERT 
ON enrollment
FOR EACH ROW EXECUTE PROCEDURE funcIncreaseSizeOfClass();

--trigger (3) - Silinen çocuğun yaşına göre sınıfın size bilgisini azaltır
CREATE OR REPLACE FUNCTION funcDecreaseSizeOfClass() RETURNS TRIGGER AS $$
BEGIN
	UPDATE class
	SET size = size - 1
	WHERE id = old.classId;
	RAISE INFO '%. sınıfın sınıf mevcudu bir azaltıldı', old.classId;
	RETURN old;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggerDecreaseSizeOfClass
AFTER DELETE 
ON enrollment
FOR EACH ROW EXECUTE PROCEDURE funcDecreaseSizeOfClass();

-- Child tablosuna eklerken id bu sequence'den gelir
CREATE SEQUENCE childSeq
START WITH 1
INCREMENT BY 1
MAXVALUE 100;

-- INSERT Kısmı
INSERT INTO class VALUES (2, '2.sınıf'),
						 (3, '3.sınıf'),
						 (4, '4.sınıf'),
						 (5, '5.sınıf');
						 
INSERT INTO enrollmentPrice VALUES ('Tam Gün', '08:00 - 17:00', 36000),
								   ('Yarım Gün', '08:00 - 13:00', 24000);
								
									
INSERT INTO child VALUES
			(nextval('childSeq'),'Hande','Camaş','09.02.2018'),
			(nextval('childSeq'),'Mehmet','Çakır','15.09.2017'),
			(nextval('childSeq'),'Cansu','Aydeniz','05.06.2020'),
			(nextval('childSeq'),'Buğra','Sarıoğlu','16.07.2018'),
			(nextval('childSeq'),'Canan','Balcı','03.02.2018'),
			(nextval('childSeq'),'Ayşe','Cesur','04.04.2019'),
			(nextval('childSeq'),'Fatma','Candan','15.08.2019'),
			(nextval('childSeq'),'Mert','İri','05.05.2019'),
			(nextval('childSeq'),'Ali','Çağdaş','06.01.2018'),
			(nextval('childSeq'),'Kamil','Baytar','13.07.2019'),
			(nextval('childSeq'),'İlkim','Erdem','07.05.2020'),
			(nextval('childSeq'),'Nadir','Mertoğlu','27.08.2020'),
			(nextval('childSeq'),'Ece','Kastamonu','03.04.2020'),
			(nextval('childSeq'),'Melih','Bilir','23.10.2020'),
			(nextval('childSeq'),'Ahmet','Bekçi','09.09.2020'),
			(nextval('childSeq'),'Serdar','Durgun','06.12.2017'),
			(nextval('childSeq'),'Salih','Köse','10.11.2020'),
			(nextval('childSeq'),'Büşra','Sadık','03.05.2019'),
			(nextval('childSeq'),'Züheyla','Beşer','12.12.2017'),
			(nextval('childSeq'),'Berke','Çoban','01.02.2018');
			
INSERT INTO parent VALUES
			(1,'Zeynel','Camaş','Baba','Erkek','0531-562-75-58'),
			(2,'Salih','Çakır','Baba','Erkek','0532-467-98-76'),
			(3,'Ferit','Aydeniz','Baba','Erkek','0535-472-85-46'),
			(4,'Ceren','Sarıoğlu','Anne','Kadın','0534-534-94-74'),
			(5,'Nurhan','Balcı','Anne','Kadın','0532-632-62-42'),
			(6,'Selim','Cesur','Baba','Erkek','0505-606-76-96'),
			(7,'Reyhan','Candan','Anne','Kadın','0530-454-89-65'),
			(8,'Hasan','İri','Baba','Erkek','0535-635-4- 85'),
			(9,'Muhammed','Çağdaş','Baba','Erkek','0534-691-71-82'),
			(10,'Hatice','Baytar','Anne','Kadın','0530-982-75-45'),
			(11,'Şenol','Erdem','Baba','Erkek','0530-975-65-75'),
			(12,'Fatih','Mertoğlu','Baba','Erkek','0505-987-67-05'),
			(13,'Ali','Kastamonu','Baba','Erkek','0505-613-29-34'),
			(14,'Zeynep','Bilir','Anne','Kadın','0530-542-89-65'),
			(15,'Hülya','Bekçi','Anne','Kadın','0534-672-85-45'),
			(16,'Fırat','Durgun','Baba','Erkek','0536-536-87-96'),
			(17,'Saliha','Köse','Anne','Kadın','0530-678-12-34'),
			(18,'Kemal','Sadık','Baba','Erkek','0535-765-89-45'),
			(19,'Melih','Beşer','Baba','Erkek','0530-981-67-45'),
			(20,'Meral','Çoban','Anne','Kadın','0534-913-87-65');


INSERT INTO enrollment VALUES
			(1, 'Peşin', 'Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 1)),		
			(2,'Taksit','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 2)),
			(3,'Peşin','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 3)),
			(4,'Taksit','Yarım Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 4)),
			(5, 'Peşin','Yarım Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 5)),		
			(6,'Taksit','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 6)),
			(7,'Peşin','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 7)),
			(8,'Taksit','Yarım Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 8)),
			(9, 'Peşin','Yarım Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 9)),		
			(10,'Taksit','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 10)),
			(11,'Peşin','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 11)),
			(12,'Taksit','Yarım Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 12)),
			(13, 'Peşin','Yarım Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 13)),		
			(14,'Taksit','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 14)),
			(15,'Peşin','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 15)),
			(16,'Taksit','Yarım Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 16)),
			(17, 'Peşin','Yarım Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 17)),		
			(18,'Taksit','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 18)),
			(19,'Peşin','Tam Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 19)),
			(20,'Taksit','Yarım Gün', (SELECT EXTRACT(YEAR FROM age(current_date, birthdate)) FROM child WHERE id = 20));


INSERT INTO teacher(fname,lname,salary,classID)
VALUES
	('Nazan','Güçlü',10650,2),
	('Uğur','Güzel',11250,2),
	('Rüya','Eren',10540,2),
	('Ayşe','Meşhur',10440,3),
	('Çınar','Masum',9600,3),
	('Narin','Hasanoğlu',11200,3),
	('Melek','Çalhanoğlu',12150,4),
	('Pare','Kılıç',10330,4),
	('Zehra','Sevinç',12250,5),
	('Sevgi','Topal',11500,5);

-- delete -  eğer bulunduğu sınıfta başka öğretmen varsa sil 
CREATE OR REPLACE FUNCTION deleteTeacher(teacherId int) RETURNS text AS $$
DECLARE
msg text;
teacherCount INT;
class_id INT;
BEGIN
	SELECT classId INTO class_id
	FROM teacher
	WHERE id = teacherId;

	SELECT COUNT(*) INTO teacherCount
	FROM teacher
	WHERE classId = class_id;
	
	IF (teacherCount = 0) THEN
		msg = 'Böyle bir öğretmen bulunumadı';
	ELSIF (teacherCount = 1) THEN
		msg = 'Bu sınıfı yöneten başka hoca olmadığı için silemezsiniz';
	ELSE 
		DELETE FROM teacher WHERE id = teacherId;
		msg = 'Öğretmen başarılı bir şekilde silindi';
	END IF;
	RETURN msg;
END;
$$ LANGUAGE plpgsql;

-- çalıştırmak için -> SELECT deleteTeacher(2);

-- toplam kayıt parası - cursor
CREATE OR REPLACE FUNCTION sumEnrollmentPrice(OUT totalEnrollmentPrice NUMERIC) AS $$
DECLARE
priceCursor CURSOR FOR SELECT price FROM enrollment, enrollmentPrice WHERE type = enrollmentType;
BEGIN
	totalEnrollmentPrice = 0;
	FOR tmpPrice IN priceCursor LOOP
		totalEnrollmentPrice = totalEnrollmentPrice + tmpPrice.price;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

-- çalıştırmak için -> SELECT sumEnrollmentPrice();

-- toplam maas miktarı - cursor
CREATE OR REPLACE FUNCTION sumTeacherSalary(OUT totalTeacherSalary NUMERIC) AS $$
DECLARE
salaryCursor CURSOR FOR SELECT salary FROM teacher;
BEGIN
	totalTeacherSalary = 0;
	FOR tmpSalary IN salaryCursor LOOP
		totalTeacherSalary = totalTeacherSalary + tmpSalary.salary;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

-- çalıştırmak için -> SELECT sumTeacherSalary();

-- record
CREATE TYPE numberOfMeals AS (breakfast INT, lunch INT);

CREATE OR REPLACE FUNCTION findNumberOfMeals(OUT meals numberOfMeals) AS $$
DECLARE
fullDayStudents INT;
halfDayStudents INT;
BEGIN
	SELECT COUNT(*) INTO fullDayStudents
	FROM enrollment
	WHERE enrollmentType = 'Tam Gün';
	
	SELECT COUNT(*) INTO halfDayStudents 
	FROM enrollment
	WHERE enrollmentType = 'Yarım Gün';
	
	meals.breakfast = fullDayStudents + halfDayStudents;
	meals.lunch = fullDayStudents;
END;
$$ LANGUAGE plpgsql;
SELECT findNumberOfMeals();

-- çalıştırmak için -> SELECT findNumberOfMeals();

-- 6. madde
CREATE VIEW childInformation AS
SELECT id, fname, lname, EXTRACT(YEAR FROM age(current_date, birthdate)) AS age, enrollmentType, price, paymentType
FROM child, enrollment, enrollmentPrice
WHERE child.id = childId AND enrollmentType = type
ORDER BY age; 







