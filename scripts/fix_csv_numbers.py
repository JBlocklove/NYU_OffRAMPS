#!/bin/python3

import csv

def modify_csv(file_path):
    modified_rows = []

    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            # Check if the fourth column (index 3) is not zero and add 1 if true
            if row[3] != '0':
                row[3] = str(int(row[3]) + 1)
            modified_rows.append(row)

    with open(file_path, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(modified_rows)

# Replace 'path_to_your_csv_file.csv' with the actual path of your CSV file
file_path = 'flaw3d_10_cycle.csv'
modify_csv(file_path)

