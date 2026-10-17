
# "csv" is a tool that comes with Python for reading CSV files.
# We use it here (instead of pandas) because it keeps the column
# names exactly as they are, even when two columns share the same
# name (like the two "Cluster number" columns).
import csv


# --- Step 1: Choose which person you want to see ---------------
# 1 = the first person in the file, 2 = the second, and so on.
# Change this number to look at someone else.
PERSON_NUMBER = 1


with open("mn_renamed.csv", encoding="utf-8") as file: #opens the file
    
    reader = csv.reader(file) #reads the file one row at a time

    questions = next(reader) #obtains questions from first row of the file (contains column names)

    #searching for the row matching the person number we want to see the answers from
    answers = None 
    for row_number, row in enumerate(reader, start=1):
        if row_number == PERSON_NUMBER:
            answers = row
            break  # we found the person, so we stop reading


# --- Step 3: Check that the person exists ----------------------
if answers is None:
    print("There is no person number", PERSON_NUMBER, "in the file.")

else:
    # --- Step 4: Print each question with its answer -----------
    # zip() pairs each question with the matching answer:
    #   ("Age of man", "29"), ("Ever attended school", "Yes"), ...
    for question, answer in zip(questions, answers):

        # The very first column has no name; it is only a row
        # number, so we skip it.
        if question == "":
            continue

        # Empty answers mean the question was not asked or not
        # answered. We skip them to keep the output tidy.
        if answer == "":
            continue

        print("Question:", question)
        print("Answer:", answer)
