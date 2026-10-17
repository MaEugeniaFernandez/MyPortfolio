-- Referential integrity tests for school.db.
-- Run with: sqlite3 school.db < test_referential_integrity.sql
-- Tests 1-7 should be rejected with an error. Tests 8-10 should succeed.
-- Every change is rolled back, so the database is left unchanged.

PRAGMA foreign_keys = ON;
.headers on
.mode table

SELECT 'Test 1: enrol a student who does not exist (9999)' AS test;
INSERT INTO enrolment VALUES (9999, 'C1', 'B1');

SELECT 'Test 2: enrol a student on a course that does not exist (C9)' AS test;
INSERT INTO enrolment VALUES (1001, 'C9', 'B1');

SELECT 'Test 3: use an exam board that does not exist (B9)' AS test;
INSERT INTO enrolment VALUES (1001, 'C4', 'B9');

SELECT 'Test 4: assign a course to a teacher who does not exist (T9)' AS test;
INSERT INTO course VALUES ('C6', 'Chemistry', 'T9');

SELECT 'Test 5: delete a student who still has enrolments (1001)' AS test;
DELETE FROM student WHERE student_number = 1001;

SELECT 'Test 6: delete a teacher who still teaches a course (T2)' AS test;
DELETE FROM teacher WHERE teacher_id = 'T2';

SELECT 'Test 7: enrol the same student on the same course twice (1001, C1)' AS test;
INSERT INTO enrolment VALUES (1001, 'C1', 'B1');

SELECT 'Test 8: valid enrolment (1001 on Biology with WJEC)' AS test;
BEGIN;
INSERT INTO enrolment VALUES (1001, 'C4', 'B5');
SELECT * FROM enrolment WHERE student_number = 1001;
ROLLBACK;

SELECT 'Test 9: change a teacher ID (T5 to T6) cascades to the course table' AS test;
BEGIN;
UPDATE teacher SET teacher_id = 'T6' WHERE teacher_id = 'T5';
SELECT * FROM course WHERE course_id = 'C5';
ROLLBACK;

SELECT 'Test 10: check the whole database for broken links (no rows = no orphans)' AS test;
PRAGMA foreign_key_check;

SELECT 'Final check: rebuild the original table with JOINs' AS test;
SELECT s.student_number, s.student_name, c.course_name, b.exam_board_name, t.teacher_name
FROM enrolment e
JOIN student    s ON s.student_number = e.student_number
JOIN course     c ON c.course_id      = e.course_id
JOIN teacher    t ON t.teacher_id     = c.teacher_id
JOIN exam_board b ON b.exam_board_id  = e.exam_board_id
ORDER BY s.student_number, c.course_id;
