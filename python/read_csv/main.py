#!/usr/bin/env python3

import csv
import pandas as pd

print("\n***********************************")
print("Reading a file containing only text")
print("***********************************\n")
with open('example_text.csv', 'r', newline='') as csvfile:
    filereader = csv.reader(csvfile,
                            delimiter=',',
                            quotechar='"')
    for index_row, row in enumerate(filereader):
        print(f"row index: {index_row}")
        for index_element, element in enumerate(row):
            print(f"[{index_element}]: {element}")
        print("Whole row with elements separated by '--':")
        print("--".join(row) + "\n")

print("\n***************************************************")
print("Reading a file containing numbers for data handling")
print("***************************************************\n")
with open('example_numbers.csv', 'r', newline='') as csvfile:
    filereader = csv.DictReader(csvfile,
                            delimiter=' ',
                            quotechar='"')
    for row in filereader:
        print(f"row['date']: {row['date']}")

print("\n************************************************************")
print("Reading a file containing numbers for data handling USING PANDAS")
print("************************************************************\n")

df = pd.read_csv('example_numbers.csv', sep=' ')
print("Dataframe:")
print(df)

df_success = df[df['status'] == 'SUCCESS']
df_failure = df[df['status'] == 'FAILURE']
# Print SUCCESS and FAILURE to the same histogram

df_print = pd.DataFrame(
    {
        "SUCCESS": df_success['download time'],
        "FAILURE": df_failure['download time']
    }
)

ax = df_print.plot.hist()
ax.figure.savefig('histogram.pdf')
