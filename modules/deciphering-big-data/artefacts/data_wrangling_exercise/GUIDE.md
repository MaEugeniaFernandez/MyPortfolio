---
layout: page
title: "Unit 4 - Data Wrangling Exercise"
---

For this exercise we were given a United Nations survey dataset (`mn.csv`), in which the column headers were short codes (such as `MWB2` or `MMT3`) that cannot be understood without a reference sheet. We were asked to first replace those codes with their English "long version",  available in a second file (`mn_headers.csv`), and to then make the data more readable by reformatting the output.



I split the exercise into two scripts:

1. `replacing_headers.py`, which swaps the short codes for their English names and saves the result in a new file, leaving the original data  untouched.
2. `user_friendly_output.py`, which based on the new file shows the answers of one person interviewed as a list of questions and answers.

Before writing any code, I opened both files to understand how they were connected. `mn.csv` holds the survey data, with one row per person interviewed and one column per question. `mn_headers.csv` works like a dictionary with three columns:

```
Name,Label,Question
MWB2,Age of man,How old are you?
MMT2,Frequency of reading newspaper or magazine,"How often do you read a newspaper or magazine..."
```

`Name` is the short code used in `mn.csv`, and `Label` is the English long version of the name of the columns I needed.

---

## Script 1: Replacing the headers

I first imported the package I would use for this exercise, which is `pandas` or `pd`:

```python
import pandas as pd
```

Then, I opened the data file with `read_csv()`, which turns a CSV file into a table called a DataFrame:

```python
data = pd.read_csv("mn.csv", index_col=0, low_memory=False)
```

The first column of `mn.csv` has no name and only holds row numbers, so `index_col=0` tells pandas to use it as row numbers and not as real data. `low_memory=False` makes pandas read the whole file in one go, which avoids a warning about some columns mixing numbers and text.

Then, I opened the headers file the same way:

```python
headers = pd.read_csv("mn_headers.csv")
```

Afterwards, I built a Python dictionary that links each short code to its long English name.

```python
labels_dictionary = dict(zip(headers["Name"], headers["Label"]))
print(labels_dictionary)
```

`zip()` pairs the `Name` and `Label` columns item by item, and `dict()` turns those pairs into a dictionary like this one: `{"MWB2": "Age of man", "MMT2": "Frequency of reading newspaper or magazine", ...}`. I printed it so I could check that it had been built correctly.

With the dictionary ready, renaming the columns took a single line of code:

```python
renamed_data = data.rename(columns=labels_dictionary)
```

`rename()` goes through every column, looks up its code in the dictionary, and replaces it with the English name. If a code is not in the dictionary, pandas simply keeps the original name, so nothing breaks.

Since some codes might not have a translation, I asked the script to tell me which ones were left as they were, using a `for` that runs through every column and keeps the ones missing from the dictionary:

```python
missing = []
for column in data.columns:
    if column not in labels_dictionary:
        missing.append(column)
```

Finally, I saved the result as a new CSV file:

```python
renamed_data.to_csv("mn_renamed.csv")
```

---

### What I see in the terminal when running the script

After the printed dictionary, the script shows:

```
Columns with no English label (kept as they were): ['MDV1F', 'MTA8E', 'mwelevel', 'mnweight', 'wscoreu', 'windex5u', 'wscorer', 'windex5r']
Done! The renamed data was saved to mn_renamed.csv
```

---

### What the headers look like before and after

Before, in `mn.csv`:

```
"","HH1","HH2","LN","MWM1","MWM2","MWM4","MWM5","MWM6D","MWM6M","MWM6Y",...
```

After, in `mn_renamed.csv`:

```
,Cluster number,Household number,Line number,Cluster number,Household number,Man's line number,Interviewer number,Day of interview,Month of interview,Year of interview,...
```

---

## Script 2: Making the output more user friendly

Even with English headers, a CSV with 220 columns is still hard to read. So, in a second script, I decided to show the answers of one person at a time, in the following format:

```
Question: Frequency of reading newspaper or magazine
Answer: Almost every day
```

For this script I used `csv`, a tool that comes with Python, instead of pandas. When pandas finds two columns with the same name (like the two "Cluster number" columns), it renames the second one to "Cluster number.1", whereas `csv` keeps the names exactly as they are.

```python
import csv

PERSON_NUMBER = 1
```

`PERSON_NUMBER` lets me choose whose answers I want to see: `1` is the first person in the file, `2` the second, and so on.

Then, I opened the renamed file and read it one row at a time with `csv.reader()`. The first row holds the column names, which are my questions, and `next()` grabs that first row:

```python
with open("mn_renamed.csv", encoding="utf-8") as file:
    reader = csv.reader(file)
    questions = next(reader)
```

Afterwards, I told the script to look for the row of the person I chose, using a `for` that counts the rows with `enumerate()` and stops (`break`) as soon as it finds the right one, so it doesn't read the remaining 9,000 rows for nothing:

```python
    answers = None
    for row_number, row in enumerate(reader, start=1):
        if row_number == PERSON_NUMBER:
            answers = row
            break
```

If the person number doesn't exist (for example, `PERSON_NUMBER = 50000`), `answers` stays empty (`None`) and the script says so instead of crashing:

```python
if answers is None:
    print("There is no person number", PERSON_NUMBER, "in the file.")
```

Lastly, I paired each question with its answer using `zip()`, and printed them one after the other:

```python
for question, answer in zip(questions, answers):
    if question == "":
        continue
    if answer == "":
        continue

    print("Question:", question)
    print("Answer:", answer)
```

The two `if` lines skip what is not useful to the reader: the first column, which has no name and is only a row number, and any empty answers, which mean the question was not asked or not answered. `continue` means *skip this one and move on to the next*.

---

### What I see in the terminal when running the script

```
Question: Cluster number
Answer: 1
Question: Household number
Answer: 17
...
Question: Frequency of reading newspaper or magazine
Answer: Almost every day
Question: Frequency of listening to the radio
Answer: At least once a week
Question: Frequency of watching TV
Answer: Less than once a week
...
```

---

### Things I noticed along the way

- **Not every code had an English label.** Eight columns (listed above) are missing from `mn_headers.csv`, so they kept their original codes.
- **Some English names appear twice.** For example, `HH1` and `MWM1` are both labelled *"Cluster number"* in `mn_headers.csv`. The file still saves correctly, but duplicated column names can cause confusion in later analysis.
- **Some whole numbers turned into decimals.** For example, *"Highest grade completed at that level"* shows `31.0` instead of `31`. This happens because pandas stores numbers as decimals in any column that also has empty cells, and keeps them that way when saving the new file.

---

### Files

- [mn.csv]({{ '/modules/deciphering-big-data/artefacts/data_wrangling_exercise/mn.csv' | relative_url }}) – original survey dataset
- [mn_headers.csv]({{ '/modules/deciphering-big-data/artefacts/data_wrangling_exercise/mn_headers.csv' | relative_url }}) – reference file with the English names
- [mn_renamed.csv]({{ '/modules/deciphering-big-data/artefacts/data_wrangling_exercise/mn_renamed.csv' | relative_url }}) – dataset with the replaced headers
- [replacing_headers.py]({{ '/modules/deciphering-big-data/artefacts/data_wrangling_exercise/replacing_headers.py' | relative_url }}) – script 1
- [user_friendly_output.py]({{ '/modules/deciphering-big-data/artefacts/data_wrangling_exercise/user_friendly_output.py' | relative_url }}) – script 2

<ul class="actions">
	<li><a href="{{ '/modules/deciphering-big-data/module-contents/unit-4/' | relative_url }}" class="button">Back to Unit 4</a></li>
</ul>
