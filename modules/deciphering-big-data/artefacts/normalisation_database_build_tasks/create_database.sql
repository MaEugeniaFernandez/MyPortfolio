-- Builds the school database from the 3NF tables of the Normalisation Task.
-- Run with: sqlite3 school.db < create_database.sql

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS enrolment;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS exam_board;
DROP TABLE IF EXISTS teacher;
DROP TABLE IF EXISTS student;

-- Parent tables

CREATE TABLE student (
    student_number INTEGER PRIMARY KEY,
    student_name   TEXT    NOT NULL,
    exam_score     INTEGER NOT NULL CHECK (exam_score BETWEEN 0 AND 100),
    support        TEXT    NOT NULL CHECK (support IN ('Yes', 'No')),
    date_of_birth  TEXT    NOT NULL
);

CREATE TABLE teacher (
    teacher_id   TEXT PRIMARY KEY,
    teacher_name TEXT NOT NULL UNIQUE
);

CREATE TABLE exam_board (
    exam_board_id   TEXT PRIMARY KEY,
    exam_board_name TEXT NOT NULL UNIQUE
);

CREATE TABLE course (
    course_id   TEXT PRIMARY KEY,
    course_name TEXT NOT NULL UNIQUE,
    teacher_id  TEXT NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teacher (teacher_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Linking table

CREATE TABLE enrolment (
    student_number INTEGER NOT NULL,
    course_id      TEXT    NOT NULL,
    exam_board_id  TEXT    NOT NULL,
    PRIMARY KEY (student_number, course_id),
    FOREIGN KEY (student_number) REFERENCES student (student_number)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (course_id) REFERENCES course (course_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (exam_board_id) REFERENCES exam_board (exam_board_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Secondary indexes on foreign key columns

CREATE INDEX idx_course_teacher       ON course (teacher_id);
CREATE INDEX idx_enrolment_course     ON enrolment (course_id);
CREATE INDEX idx_enrolment_exam_board ON enrolment (exam_board_id);

-- Data

INSERT INTO student VALUES
    (1001, 'Bob Baker',    78, 'No',  '2001-08-25'),
    (1002, 'Sally Davies', 55, 'Yes', '1999-10-02'),
    (1003, 'Mark Hanmill', 90, 'No',  '1995-06-05'),
    (1004, 'Anas Ali',     70, 'No',  '1980-08-03'),
    (1005, 'Cheuk Yin',    45, 'Yes', '2002-05-01');

INSERT INTO teacher VALUES
    ('T1', 'Mr Jones'),
    ('T2', 'Ms Parker'),
    ('T3', 'Mr Peters'),
    ('T4', 'Mrs Patel'),
    ('T5', 'Ms Daniels');

INSERT INTO exam_board VALUES
    ('B1', 'BCS'),
    ('B2', 'EdExcel'),
    ('B3', 'OCR'),
    ('B4', 'AQA'),
    ('B5', 'WJEC');

INSERT INTO course VALUES
    ('C1', 'Computer Science', 'T1'),
    ('C2', 'Maths',            'T2'),
    ('C3', 'Physics',          'T3'),
    ('C4', 'Biology',          'T4'),
    ('C5', 'Music',            'T5');

INSERT INTO enrolment VALUES
    (1001, 'C1', 'B1'),
    (1001, 'C2', 'B2'),
    (1001, 'C3', 'B3'),
    (1002, 'C2', 'B4'),
    (1002, 'C4', 'B5'),
    (1002, 'C5', 'B4'),
    (1003, 'C1', 'B1'),
    (1003, 'C2', 'B2'),
    (1003, 'C3', 'B3'),
    (1004, 'C2', 'B4'),
    (1004, 'C3', 'B3'),
    (1004, 'C4', 'B5'),
    (1005, 'C1', 'B1'),
    (1005, 'C2', 'B2'),
    (1005, 'C5', 'B4');
