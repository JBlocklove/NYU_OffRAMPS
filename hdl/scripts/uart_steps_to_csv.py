#!/bin/python3

import serial
import time
import csv
import struct
import argparse

# Set up command line arguments
parser = argparse.ArgumentParser(description="UART to CSV script")
parser.add_argument("--port", type=str, default="/dev/ttyUSB1", help="Serial port to use")
parser.add_argument("--baud", type=int, default=115200, help="Baud rate")
parser.add_argument("--csv", type=str, default="uart_data.csv", help="CSV file name")
args = parser.parse_args()

# Setup the serial port
ser = serial.Serial(args.port, args.baud)
ser.timeout = 15  # Timeout for read

# Read 16 bytes from the UART and return them as a list of 4 32-bit integers
def read_uart():
    # Read 16 bytes from UART
    data = ser.read(16)

    # Check if we received 16 bytes
    if len(data) == 16:
        # Convert each 4-byte chunk to a 32-bit unsigned integer
        integers = [struct.unpack('>I', data[i:i+4])[0] for i in range(0, len(data), 4)]
        return integers
    else:
        return None

# Write 4 integers to a CSV file
def write_to_csv(index, integers):
    with open(args.csv, 'a', newline='') as file:
        writer = csv.writer(file)
        if file.tell() == 0:  # If the file is empty, write the header
            writer.writerow(["Index", "X", "Y", "Z", "E"])
        writer.writerow([index] + integers)

# Main loop
try:
    index = 0
    while True:
        integers = read_uart()
        if integers:
            print(f"Transaction {index}: Received integers:", integers)
            write_to_csv(index, integers)
            index += 1
        else:
            print("Did not receive 16 bytes of data.")

        # Sleep for a short period to avoid overwhelming the CPU
        time.sleep(0.1)

except KeyboardInterrupt:
    print("Program terminated by user.")

finally:
    ser.close()

