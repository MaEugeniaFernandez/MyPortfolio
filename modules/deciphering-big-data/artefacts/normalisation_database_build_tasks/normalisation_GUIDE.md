# Normalisation Task

For this exercise we were given a table of student data in un-normalised form (`DBD_PCOM7E Table.xlsx`) and asked to normalise it to Third Normal Form (3NF), showing each step of the process: 1NF, 2NF and 3NF.

---

## Un-normalised form (UNF)

| Student Number | Student Name | Exam Score | Support | Date of Birth | Course Name | Exam Board | Teacher Name |
|---|---|---|---|---|---|---|---|
| 1001 | Bob Baker | 78 | No | 2001-08-25 | Computer Science | BCS | Mr Jones |
| | | | | | Maths | EdExcel | Ms Parker |
| | | | | | Physics | OCR | Mr Peters |
| 1002 | Sally Davies | 55 | Yes | 1999-10-02 | Maths | AQA | Ms Parker |
| | | | | | Biology | WJEC | Mrs Patel |
| | | | | | Music | AQA | Ms Daniels |
| 1003 | Mark Hanmill | 90 | No | 1995-06-05 | Computer Science | BCS | Mr Jones |
| | | | | | Maths | EdExcel | Ms Parker |
| | | | | | Physics | OCR | Mr Peters |
| 1004 | Anas Ali | 70 | No | 1980-08-03 | Maths | AQA | Ms Parker |
| | | | | | Physics | OCR | Mr Peters |
| | | | | | Biology | WJEC | Mrs Patel |
| 1005 | Cheuk Yin | 45 | Yes | 2002-05-01 | Computer Science | BCS | Mr Jones |
| | | | | | Maths | EdExcel | Ms Parker |
| | | | | | Music | AQA | Ms Daniels |

The course details (`Course Name`, `Exam Board`, `Teacher Name`) form a repeating group for each student.

---

## First Normal Form (1NF)

The repeating group was removed by filling the student details down into every row, so that each cell holds a single value and each row is complete. The primary key is the composite key (Student Number, Course Name).

**STUDENT_COURSE** (PK = <u>Student Number</u> + <u>Course Name</u>)

| <u>Student Number</u> | Student Name | Exam Score | Support | Date of Birth | <u>Course Name</u> | Exam Board | Teacher Name |
|---|---|---|---|---|---|---|---|
| 1001 | Bob Baker | 78 | No | 2001-08-25 | Computer Science | BCS | Mr Jones |
| 1001 | Bob Baker | 78 | No | 2001-08-25 | Maths | EdExcel | Ms Parker |
| 1001 | Bob Baker | 78 | No | 2001-08-25 | Physics | OCR | Mr Peters |
| 1002 | Sally Davies | 55 | Yes | 1999-10-02 | Maths | AQA | Ms Parker |
| 1002 | Sally Davies | 55 | Yes | 1999-10-02 | Biology | WJEC | Mrs Patel |
| 1002 | Sally Davies | 55 | Yes | 1999-10-02 | Music | AQA | Ms Daniels |
| 1003 | Mark Hanmill | 90 | No | 1995-06-05 | Computer Science | BCS | Mr Jones |
| 1003 | Mark Hanmill | 90 | No | 1995-06-05 | Maths | EdExcel | Ms Parker |
| 1003 | Mark Hanmill | 90 | No | 1995-06-05 | Physics | OCR | Mr Peters |
| 1004 | Anas Ali | 70 | No | 1980-08-03 | Maths | AQA | Ms Parker |
| 1004 | Anas Ali | 70 | No | 1980-08-03 | Physics | OCR | Mr Peters |
| 1004 | Anas Ali | 70 | No | 1980-08-03 | Biology | WJEC | Mrs Patel |
| 1005 | Cheuk Yin | 45 | Yes | 2002-05-01 | Computer Science | BCS | Mr Jones |
| 1005 | Cheuk Yin | 45 | Yes | 2002-05-01 | Maths | EdExcel | Ms Parker |
| 1005 | Cheuk Yin | 45 | Yes | 2002-05-01 | Music | AQA | Ms Daniels |

---

## Second Normal Form (2NF)

Partial dependencies on the composite key were removed:

- `Student Name`, `Exam Score`, `Support` and `Date of Birth` depend only on `Student Number`.
- `Teacher Name` depends only on `Course Name`.
- `Exam Board` depends on both `Student Number` and `Course Name` (for example, Maths is examined by EdExcel for some students and by AQA for others).

**STUDENT** (PK = <u>Student Number</u>)

| <u>Student Number</u> | Student Name | Exam Score | Support | Date of Birth |
|---|---|---|---|---|
| 1001 | Bob Baker | 78 | No | 2001-08-25 |
| 1002 | Sally Davies | 55 | Yes | 1999-10-02 |
| 1003 | Mark Hanmill | 90 | No | 1995-06-05 |
| 1004 | Anas Ali | 70 | No | 1980-08-03 |
| 1005 | Cheuk Yin | 45 | Yes | 2002-05-01 |

**COURSE** (PK = <u>Course Name</u>)

| <u>Course Name</u> | Teacher Name |
|---|---|
| Computer Science | Mr Jones |
| Maths | Ms Parker |
| Physics | Mr Peters |
| Biology | Mrs Patel |
| Music | Ms Daniels |

**ENROLMENT** (PK = <u>Student Number</u> + <u>Course Name</u>)

| <u>Student Number</u> (FK) | <u>Course Name</u> (FK) | Exam Board |
|---|---|---|
| 1001 | Computer Science | BCS |
| 1001 | Maths | EdExcel |
| 1001 | Physics | OCR |
| 1002 | Maths | AQA |
| 1002 | Biology | WJEC |
| 1002 | Music | AQA |
| 1003 | Computer Science | BCS |
| 1003 | Maths | EdExcel |
| 1003 | Physics | OCR |
| 1004 | Maths | AQA |
| 1004 | Physics | OCR |
| 1004 | Biology | WJEC |
| 1005 | Computer Science | BCS |
| 1005 | Maths | EdExcel |
| 1005 | Music | AQA |

---

## Third Normal Form (3NF)

No transitive dependencies remain in the 2NF tables. Teachers and exam boards were moved into their own tables, each with an ID as primary key, so that every value is stored only once and referenced through foreign keys.

**STUDENT** (PK = <u>Student Number</u>)

| <u>Student Number</u> | Student Name | Exam Score | Support | Date of Birth |
|---|---|---|---|---|
| 1001 | Bob Baker | 78 | No | 2001-08-25 |
| 1002 | Sally Davies | 55 | Yes | 1999-10-02 |
| 1003 | Mark Hanmill | 90 | No | 1995-06-05 |
| 1004 | Anas Ali | 70 | No | 1980-08-03 |
| 1005 | Cheuk Yin | 45 | Yes | 2002-05-01 |

**TEACHER** (PK = <u>Teacher ID</u>)

| <u>Teacher ID</u> | Teacher Name |
|---|---|
| T1 | Mr Jones |
| T2 | Ms Parker |
| T3 | Mr Peters |
| T4 | Mrs Patel |
| T5 | Ms Daniels |

**COURSE** (PK = <u>Course ID</u>)

| <u>Course ID</u> | Course Name | Teacher ID (FK) |
|---|---|---|
| C1 | Computer Science | T1 |
| C2 | Maths | T2 |
| C3 | Physics | T3 |
| C4 | Biology | T4 |
| C5 | Music | T5 |

**EXAM_BOARD** (PK = <u>Exam Board ID</u>)

| <u>Exam Board ID</u> | Exam Board Name |
|---|---|
| B1 | BCS |
| B2 | EdExcel |
| B3 | OCR |
| B4 | AQA |
| B5 | WJEC |

**ENROLMENT** (PK = <u>Student Number</u> + <u>Course ID</u>)

| <u>Student Number</u> (FK) | <u>Course ID</u> (FK) | Exam Board ID (FK) |
|---|---|---|
| 1001 | C1 | B1 |
| 1001 | C2 | B2 |
| 1001 | C3 | B3 |
| 1002 | C2 | B4 |
| 1002 | C4 | B5 |
| 1002 | C5 | B4 |
| 1003 | C1 | B1 |
| 1003 | C2 | B2 |
| 1003 | C3 | B3 |
| 1004 | C2 | B4 |
| 1004 | C3 | B3 |
| 1004 | C4 | B5 |
| 1005 | C1 | B1 |
| 1005 | C2 | B2 |
| 1005 | C5 | B4 |



### How the tables link together (ERD)
```
STUDENT ──< ENROLMENT >── COURSE >── TEACHER
                │
                v
           EXAM_BOARD
```
