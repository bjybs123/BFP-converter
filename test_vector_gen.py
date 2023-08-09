import struct
import random

# Function to convert a 32-bit float to binary representation
def float_to_binary(num):
    return bin(struct.unpack('!I', struct.pack('!f', num))[0])[2:].zfill(32)

# Function to generate a random 32-bit float
def get_random_float32():
    sign = random.randint(0, 1)
    exponent = random.randint(1, 7)
    mantissa = random.getrandbits(23)
    return struct.unpack('!f', struct.pack('!I', (sign << 31) | (exponent << 23) | mantissa))[0]


def add_one_in_exponent_and_mantissa(binary_str):
    sign_bit = binary_str[0]
    exponent = int(binary_str[1:9], 2)
    mantissa = "1" + binary_str[9:31]  # Adding 1 to the mantissa as specified

    return sign_bit + format(exponent + 1, '08b') + mantissa


def find_maximum_exponent(binary_list):
    max_exponent = 0
    for binary_str in binary_list:
        exponent = int(binary_str[1:9], 2)
        if exponent > max_exponent:
            max_exponent = exponent
    return max_exponent


def align_to_maximum_exponent(binary_str, max_exponent):
    sign_bit = binary_str[0]
    exponent = int(binary_str[1:9], 2)
    mantissa = binary_str[9:32]

    difference = max_exponent - exponent
    new_exponent = exponent + difference
    if difference > 23:
        new_mantissa = "0" * 23
    else:
        new_mantissa = "0" * difference + mantissa[0:23 - difference] 
    if new_mantissa[3] == "1":
        if new_mantissa[0:3] == "111":
            new_new_mantissa = new_mantissa[0:3]
        else:
            mantissa_int = int(new_mantissa[0:3], 2)
            new_mantissa_int = (mantissa_int + 1) % 8
            new_new_mantissa = format(new_mantissa_int, '03b')
    else :
        new_new_mantissa = new_mantissa[0:3]
    return sign_bit + format(new_exponent, '08b') + new_new_mantissa

# Number of sets and number of floating-point numbers per set
num_sets = 10
num_numbers_per_set = 16

# Generate 10 sets of 16 random 32-bit floating-point numbers in binary format
all_binary_numbers = [
    [float_to_binary(get_random_float32()) for _ in range(num_numbers_per_set)]
    for _ in range(num_sets)
]

# Store the binary numbers in a file
with open('./fps.tv', 'w') as file:
    for set_num, binary_numbers in enumerate(all_binary_numbers, 1):
        for binary_num in binary_numbers:
            file.write(binary_num + '_')
        file.write(f"\n")


# Store the binary numbers in a file
with open('./bfps.tv', 'w') as file:
    for set_num, binary_numbers in enumerate(all_binary_numbers, 1):
        step1_results = [add_one_in_exponent_and_mantissa(binary) for binary in binary_numbers]
        max_exp = find_maximum_exponent(step1_results)
        step3_results = [align_to_maximum_exponent(binary, max_exp) for binary in step1_results]
        for binary in step3_results:
            file.write(binary + '_')
        file.write(f"\n")