import pandas as pd


# --- Step 1: Read the data file --------------------------------
# read_csv() opens a CSV file and turns it into a table (called a
# "DataFrame"). The first column in mn.csv has no name and just
# holds row numbers, so index_col=0 tells pandas: "use the first
# column as row numbers, not as real data".
# low_memory=False makes pandas read the whole file in one go, which
# avoids a warning about some columns mixing numbers and text.
data = pd.read_csv("mn.csv", index_col=0, low_memory=False)


# --- Step 2: Read the headers "dictionary" file ----------------
# mn_headers.csv has three columns: Name, Label and Question.
#   - "Name"  is the short code used in mn.csv (e.g. "MWB2")
#   - "Label" is the English long version    (e.g. "Age of man")
# We don't need "Question" for this task.
headers = pd.read_csv("mn_headers.csv")


# --- Step 3: Build a lookup of  short code -> long name --------
# A Python "dictionary" works like a real dictionary: you look up a
# word (the key) and get its meaning (the value).
# Here we want something like: {"MWB2": "Age of man", ...}
# zip() pairs up the two columns, item by item, and dict() turns
# those pairs into a dictionary.
labels_dictionary = dict(zip(headers["Name"], headers["Label"])) #arma el diccionario
print(labels_dictionary) #para poder ver el diccionario armado


# --- Step 4: Rename the columns --------------------------------
# rename() swaps each old column name for its new one using our
# dictionary. If a column code is NOT in the dictionary, pandas
# simply keeps the original name (nothing breaks).
renamed_data = data.rename(columns=labels_dictionary)


# --- Step 5: Tell the user which columns had no translation ----
# This is just helpful information. We go through every column
# name in the data and keep the ones missing from our dictionary.
missing = []
for column in data.columns:
    if column not in labels_dictionary:
        missing.append(column)

print("Columns with no English label (kept as they were):", missing)


# --- Step 6: Save the result to a NEW file ---------------------
# to_csv() writes the table out as a CSV file.
# The original mn.csv stays untouched.
renamed_data.to_csv("mn_renamed.csv")

print("Done! The renamed data was saved to mn_renamed.csv")
