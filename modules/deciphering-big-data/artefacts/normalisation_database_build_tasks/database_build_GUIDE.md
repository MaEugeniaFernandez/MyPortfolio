---
layout: page
title: "Unit 7 - Data Build Task"
---

For this exercise we were asked to build a relational database with linked tables from the results of the Normalisation Task, demonstrating primary and secondary keys, and to test the database to ensure referential integrity.

The database was built in SQLite using two scripts:

1. `create_database.sql`, which creates the tables, keys and indexes, and loads the data.
2. `test_referential_integrity.sql`, which tests that the links between tables cannot be broken.

```bash
sqlite3 school.db < create_database.sql
sqlite3 school.db < test_referential_integrity.sql
```

---

## Database design

The five tables come from the 3NF result of the Normalisation Task.

```
student ──< enrolment >── course >── teacher
                │
                v
           exam_board
```

| Table | Primary key | Foreign keys | Alternate keys (UNIQUE) |
|---|---|---|---|
| `student` | `student_number` | – | – |
| `teacher` | `teacher_id` | – | `teacher_name` |
| `exam_board` | `exam_board_id` | – | `exam_board_name` |
| `course` | `course_id` | `teacher_id` → `teacher` | `course_name` |
| `enrolment` | `student_number` + `course_id` | `student_number` → `student`<br>`course_id` → `course`<br>`exam_board_id` → `exam_board` | – |

Secondary indexes were added on the foreign key columns `course.teacher_id`, `enrolment.course_id` and `enrolment.exam_board_id`.

---

## Step 1: Creating the tables

Foreign key enforcement is switched on for the connection:

```sql
PRAGMA foreign_keys = ON;
```

Parent tables are created first, so that the tables referring to them can be created afterwards:

```sql
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
```

The linking table has a composite primary key and three foreign keys:

```sql
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
```

`ON DELETE RESTRICT` blocks the deletion of a row that other rows still refer to. `ON UPDATE CASCADE` copies a change of key value to every row that refers to it.

---

## Step 2: Creating the secondary indexes

```sql
CREATE INDEX idx_course_teacher       ON course (teacher_id);
CREATE INDEX idx_enrolment_course     ON enrolment (course_id);
CREATE INDEX idx_enrolment_exam_board ON enrolment (exam_board_id);
```

---

## Step 3: Loading the data

Parent tables are loaded before the tables that refer to them: `student`, `teacher`, `exam_board`, then `course`, then `enrolment`.

```sql
INSERT INTO student VALUES
    (1001, 'Bob Baker',    78, 'No',  '2001-08-25'),
    (1002, 'Sally Davies', 55, 'Yes', '1999-10-02'),
    ...

INSERT INTO enrolment VALUES
    (1001, 'C1', 'B1'),
    (1001, 'C2', 'B2'),
    ...
```
In the end, we have a total of 5 tables, as follows:

| Table | Rows |
|---|---|
| `student` | 5 |
| `teacher` | 5 |
| `exam_board` | 5 |
| `course` | 5 |
| `enrolment` | 15 |

---

## Step 4: Testing referential integrity

Tests 1–7 attempt changes that would break the database and should be rejected. Tests 8–10 should succeed. Tests 8 and 9 are wrapped in `BEGIN … ROLLBACK` so the database is left unchanged.

| # | Test | SQL | Expected | Result |
|---|---|---|---|---|
| 1 | Enrol a student who does not exist | `INSERT INTO enrolment VALUES (9999, 'C1', 'B1');` | Rejected | ✅ `FOREIGN KEY constraint failed` |
| 2 | Enrol on a course that does not exist | `INSERT INTO enrolment VALUES (1001, 'C9', 'B1');` | Rejected | ✅ `FOREIGN KEY constraint failed` |
| 3 | Use an exam board that does not exist | `INSERT INTO enrolment VALUES (1001, 'C4', 'B9');` | Rejected | ✅ `FOREIGN KEY constraint failed` |
| 4 | Assign a course to a teacher who does not exist | `INSERT INTO course VALUES ('C6', 'Chemistry', 'T9');` | Rejected | ✅ `FOREIGN KEY constraint failed` |
| 5 | Delete a student who has enrolments | `DELETE FROM student WHERE student_number = 1001;` | Rejected | ✅ `FOREIGN KEY constraint failed` |
| 6 | Delete a teacher who teaches a course | `DELETE FROM teacher WHERE teacher_id = 'T2';` | Rejected | ✅ `FOREIGN KEY constraint failed` |
| 7 | Enrol the same student on the same course twice | `INSERT INTO enrolment VALUES (1001, 'C1', 'B1');` | Rejected | ✅ `UNIQUE constraint failed: enrolment.student_number, enrolment.course_id` |
| 8 | Valid enrolment | `INSERT INTO enrolment VALUES (1001, 'C4', 'B5');` | Accepted | ✅ Row added |
| 9 | Change a teacher ID | `UPDATE teacher SET teacher_id = 'T6' WHERE teacher_id = 'T5';` | Cascades to `course` | ✅ Music now linked to `T6` |
| 10 | Check the whole database for broken links | `PRAGMA foreign_key_check;` | No rows | ✅ No rows returned |


---

## Step 5: Rebuilding the original table

The linked tables were joined back together through their keys to confirm that no data was lost:

```sql
SELECT s.student_number, s.student_name, c.course_name, b.exam_board_name, t.teacher_name
FROM enrolment e
JOIN student    s ON s.student_number = e.student_number
JOIN course     c ON c.course_id      = e.course_id
JOIN teacher    t ON t.teacher_id     = c.teacher_id
JOIN exam_board b ON b.exam_board_id  = e.exam_board_id
ORDER BY s.student_number, c.course_id;
```

```
+----------------+--------------+------------------+-----------------+--------------+
| student_number | student_name |   course_name    | exam_board_name | teacher_name |
+----------------+--------------+------------------+-----------------+--------------+
| 1001           | Bob Baker    | Computer Science | BCS             | Mr Jones     |
| 1001           | Bob Baker    | Maths            | EdExcel         | Ms Parker    |
| 1001           | Bob Baker    | Physics          | OCR             | Mr Peters    |
| 1002           | Sally Davies | Maths            | AQA             | Ms Parker    |
| 1002           | Sally Davies | Biology          | WJEC            | Mrs Patel    |
| 1002           | Sally Davies | Music            | AQA             | Ms Daniels   |
| 1003           | Mark Hanmill | Computer Science | BCS             | Mr Jones     |
| 1003           | Mark Hanmill | Maths            | EdExcel         | Ms Parker    |
| 1003           | Mark Hanmill | Physics          | OCR             | Mr Peters    |
| 1004           | Anas Ali     | Maths            | AQA             | Ms Parker    |
| 1004           | Anas Ali     | Physics          | OCR             | Mr Peters    |
| 1004           | Anas Ali     | Biology          | WJEC            | Mrs Patel    |
| 1005           | Cheuk Yin    | Computer Science | BCS             | Mr Jones     |
| 1005           | Cheuk Yin    | Maths            | EdExcel         | Ms Parker    |
| 1005           | Cheuk Yin    | Music            | AQA             | Ms Daniels   |
+----------------+--------------+------------------+-----------------+--------------+
```

The 15 rows match the 1NF table from the Normalisation Task.

---

### Files

- [DBD_PCOM7E Table.xlsx]({{ '/modules/deciphering-big-data/artefacts/normalisation_database_build_tasks/DBD_PCOM7E%20Table.xlsx' | relative_url }}) – un-normalised student data table
- [create_database.sql]({{ '/modules/deciphering-big-data/artefacts/normalisation_database_build_tasks/create_database.sql' | relative_url }}) – script that builds the database
- [school.db]({{ '/modules/deciphering-big-data/artefacts/normalisation_database_build_tasks/school.db' | relative_url }}) – the resulting SQLite database
- [test_referential_integrity.sql]({{ '/modules/deciphering-big-data/artefacts/normalisation_database_build_tasks/test_referential_integrity.sql' | relative_url }}) – referential integrity tests

<ul class="actions">
	<li><a href="{{ '/modules/deciphering-big-data/module-contents/unit-7/' | relative_url }}" class="button">Back to Unit 7</a></li>
</ul>
