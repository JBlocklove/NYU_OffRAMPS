import csv

input_file = 'hammer_print_0p1sec.csv'  # Replace with your input file name
output_file = 'output.csv'  # Replace with your desired output file name

with open(input_file, mode='r', newline='') as infile, open(output_file, mode='w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)

    for row in reader:
        if row:  # Check if the row is not empty
            row[0] = int(row[0]) - 27  # Subtract 26 from the first column
            row[3] = int(row[3]) - 3  # Subtract 3 from the fourth column
        writer.writerow(row)

print(f"File processed. Output saved to '{output_file}'.")

