#!/bin/python3

import pandas as pd
import argparse
import numpy as np

# Compare two CSV files and print the differences
def compare_csvs(file1, file2, diff, zero_diff, mode):
    # Load the CSV files into pandas DataFrames
    df1 = pd.read_csv(file1)
    df2 = pd.read_csv(file2)

    # Ensure the indexes are consistent for comparison
    df1.set_index('Index', inplace=True)
    df2.set_index('Index', inplace=True)

    largest_diff = 0  # Track the largest percentage difference
    mismatch_count = 0  # Count mismatches outside the margin of error

    # Iterating over each row by index
    for index in df1.index[:-1]:  # Exclude the final row in this loop
        if index in df2.index:
            row1, row2 = df1.loc[index], df2.loc[index]
            # Comparing values in each column
            for col in df1.columns:
                value1, value2 = row1[col], row2[col]
                # Check for NaN values to avoid errors
                if not (np.isnan(value1) or np.isnan(value2)):
                    current_diff = abs(value1 - value2) / max(abs(value1), abs(value2)) if value1 and value2 else 0
                    largest_diff = max(largest_diff, current_diff)

                    if mode == 'percent':
                        if value1 == 0 or value2 == 0:
                            if abs(value1 - value2) > zero_diff:
                                print(f'Index: {index}, Column: {col}, Values: {value1}, {value2} (Zero comparison)')
                                mismatch_count += 1
                        else:
                            if current_diff > diff / 100.0:
                                print(f'Index: {index}, Column: {col}, Values: {value1}, {value2}')
                                mismatch_count += 1
                    elif mode == 'absolute':
                        if abs(value1 - value2) > diff:
                            print(f'Index: {index}, Column: {col}, Values: {value1}, {value2}')
                            mismatch_count += 1
                else:
                    print(f'Index: {index}, Column: {col}, Invalid comparison due to NaN value')

    # Explicit check for the final row
    final_index = df1.index[-1]
    if final_index in df2.index:
        final_row1, final_row2 = df1.loc[final_index], df2.loc[final_index]
        for col in df1.columns:
            if final_row1[col] != final_row2[col]:
                print(f'Final Row Mismatch at Index: {final_index}, Column: {col}, Values: {final_row1[col]}, {final_row2[col]}')

    # Print final summary
    print(f'Largest percent difference found: {largest_diff * 100:.2f}%')
    print(f'Number of transactions compared: {len(df1.index)}')
    print(f'Number of mismatches: {mismatch_count}')
    if mismatch_count == 0:
        print('Trojan unlikely to be present')
    else:
        print('Trojan likely!')

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description='Compare two CSV files.')
    parser.add_argument('--file1', type=str, default='golden_model.csv', help='Path to the first CSV file')
    parser.add_argument('--file2', type=str, default='comparison_model.csv', help='Path to the second CSV file')
    parser.add_argument('--diff', type=float, default=10.0, help='Margin of error for comparison')
    parser.add_argument('--zero_diff', type=float, default=0.1, help='Absolute difference threshold for zero comparisons')
    parser.add_argument('--mode', type=str, default='percent', choices=['percent', 'absolute'], help='Mode of comparison: percent or absolute')

    # Parse arguments
    args = parser.parse_args()

    # Run the comparison function
    compare_csvs(args.file1, args.file2, args.diff, args.zero_diff, args.mode)
