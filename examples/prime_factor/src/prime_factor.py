#!/usr/bin/python3

import pyrah

APPID = 1

def input_data_and_mode():
    try:
        input1 = int(input("Enter the input for Prime Factorization: "))

        if input1 <= 0 or input1 > 2147483648:
            print("Invalid input: Please enter a positive integer up to 2147483648.")
            return None

    except ValueError:
        print("Invalid input: Please enter a valid number.")
        return None

    input2 = int(0)

    byte_1 = int_to_hex(input1)
    byte_2 = int_to_hex(input2)
    concatenated_result = concatenate_bytes(byte_1, byte_2)
    transfer_data(concatenated_result)

    return input1

def concatenate_bytes(byte_obj1, byte_obj2):
    concatenated_bytes = byte_obj1 + byte_obj2
    return concatenated_bytes

def int_to_hex(input_value):
    # Convert the integer to a hex string and remove the '0x' prefix
    hex_value = hex(input_value)  # Strip '0x' prefix
    hex_value = hex_value.lstrip('0x')

    # Ensure the hex string has an even length (pad with '0' if necessary)
    if len(hex_value) % 2 != 0:
        hex_value = '0' + hex_value

    # Convert the hex string into bytes
    byte_data = bytes.fromhex(hex_value)

    # Pad or trim to ensure it's exactly 6 bytes
    if len(byte_data) < 6:
        # Pad with zero bytes (b'\x00') if less than 6 bytes
        byte_data = byte_data.rjust(6, b'\x00')
    elif len(byte_data) > 6:
        # Trim extra bytes if greater than 6 bytes
        byte_data = byte_data[:6]
    return byte_data

def transfer_data(data_in):
    pyrah.rah_write(APPID, data_in)

def receive_data():
    while True:
        try:
            input1 = input_data_and_mode()

            if input1 is None:
                continue

            received_data = pyrah.rah_read(APPID, 6)
            length = int.from_bytes(received_data, 'big')
            count = 0

            factors = []
            while(count < length):
                received_data = pyrah.rah_read(APPID, 6)
                value = int.from_bytes(received_data, 'big')
                count = count + 1
                factors.append(value)

            print("Prime Factors for", input1, ": ", ' x '.join(str(f) for f in factors))
            print()

        except KeyboardInterrupt:
            print("\nExiting...")
            break

if __name__ == "__main__":
    receive_data()