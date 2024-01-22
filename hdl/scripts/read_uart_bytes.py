#!/bin/python3

import serial
import time

# Setup the serial port
ser = serial.Serial('/dev/ttyUSB1', 115200)
ser.timeout = 30  # Timeout for read

def format_byte(byte):
    """Format a single byte to its hexadecimal representation."""
    return f"0x{byte:02x}"

def read_uart():
    # Read 16 bytes from UART
    data = ser.read(16)

    # Check if we received 16 bytes
    if len(data) == 16:
        # Convert each byte to its hexadecimal representation
        formatted_data = [format_byte(b) for b in data]
        # Split the formatted data into 4 lists of 4 bytes each
        byte_lists = [formatted_data[i:i+4] for i in range(0, len(formatted_data), 4)]
        return byte_lists
    else:
        return None

try:
    while True:
        byte_lists = read_uart()
        if byte_lists:
            print("Received 4 lists of bytes (in hex):", byte_lists)
        else:
            print("Did not receive 16 bytes of data.")

        # Sleep for a short period to avoid overwhelming the CPU
        time.sleep(0.1)

except KeyboardInterrupt:
    print("Program terminated by user.")

finally:
    ser.close()

