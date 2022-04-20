import socket
import sys
import os
import datetime
import hashlib
from starkware.crypto.signature.signature import pedersen_hash as ph

p = 3618502788666131213697322783095070105623107215331596699973092056135872020481

char_types = {
    "spacebar": [32],
    "digits": [48 + i for i in range(10)],
    "letters": [65 + i for i in range(26)] + [97 + i for i in range(26)],
    "sign-words": [33 + i for i in range(15)] +
    [58 + i for i in range(7)] +
    [91 + i for i in range(6)] +
    [123 + i for i in range(4)]
}

types_index = {
    "spacebar": "0",
    "digits": "1",
    "letters": "2",
    "sign-words": "4"
}


def arr_hash2(arr):
    if len(arr) < 2:
        print("ERROR: ARRAY TO SHORT!")
        return
    current = ph(arr[0], arr[1])
    for element in arr[2:]:
        current = ph(current, element)
    return current


def update_log_hash(arr):
    with open("current_hash_of_log_file.txt", "a") as f:
        f.write("")

    with open("current_hash_of_log_file.txt", "r") as f:
        data = f.read()

    if len(data):
        current = int(data)
        new_arr = [current] + arr
        new_hash = arr_hash2(new_arr)
        with open("current_hash_of_log_file.txt", "w") as f:
            f.write(str(new_hash))
    else:
        with open("current_hash_of_log_file.txt", "w") as f:
            f.write(str(arr_hash2(arr)))
    return


def to_felts(line):
    words = []
    types = types_of_line(line)
    types_with_breaks = chr(167)
    line_with_breaks = chr(167)
    for char_type, char in zip(types, line):
        if char_type == "0" and types_with_breaks[-1] == "0":
            pass
        else:
            if char_type == types_with_breaks[-1] and char_type != "4":
                types_with_breaks += char_type
                line_with_breaks += char
            else:
                types_with_breaks += chr(167)
                types_with_breaks += char_type
                line_with_breaks += chr(167)
                line_with_breaks += char
    new_words = line_with_breaks.split(chr(167))
    for new_word in new_words:
        if new_word:
            words.append(new_word)
    words.append("END_OF_LINE")
    felts = []
    for word in words:
        felts.append(convert_word_to_cairo_felt(word))
    return felts


def key_for_val(val):
    '''val is an integer indicating the ord(.) of a char'''
    '''the function returns the type of the char as a char between 0-4'''
    for key in char_types:
        if val in char_types[key]:
            return types_index[key]
    return "4"


def types_of_line(line):
    '''line is a line of words'''
    '''the function returns a line that indicates the types of each entry'''
    types = ""
    for char in line:
        types += key_for_val(ord(char))
    return types


def convert_word_to_cairo_felt(word):
    l = len(word)
    if l == 0:
        return 0
    count = 0
    for i, letter in enumerate(word):
        count += ord(letter)*pow(256, l-1-i)
    return count


def send_and_return_response(original_string_msg, FORMAT, HEADER, client):
    '''input string_msg is a utf8-string'''
    bytes_message = original_string_msg.encode(
        FORMAT)  # recall that encode returns bytes
    length_of_original_message_in_bytes = len(
        bytes_message)  # this is an integer
    # this is a string with the length of the original message in bytes
    header_message_as_string = str(length_of_original_message_in_bytes)
    header_message_as_bytes = header_message_as_string.encode(
        FORMAT)  # this is the header message as bytes
    padded_header_message = header_message_as_bytes + b' ' * \
        (HEADER-len(header_message_as_bytes))  # compute the padding
    client.send(padded_header_message)
    client.send(bytes_message)
    return client.recv(2**20)


def TIME():
    return datetime.datetime.now().strftime("%Z %B %d, %Y; %H:%M:%S")


def Hash(s):
    '''returns the sha256 of a the bytes buffer s as bytes'''
    if type(s) == bytes:
        m = hashlib.sha256()  # creates a SHA-256 hash object
        m.update(s)
        return m.digest()
    else:
        return Hash(bytes(str(s).encode()))


def main():
    _, PORT, MOVNAME, PIECENUM, TARGET_PATH = RUN_PARAMETERS

    PORT = int(PORT)
    PIECENUM = int(PIECENUM)
    HEADER = 64
    SERVER = socket.gethostbyname(socket.gethostname())
    ADDR = (SERVER, PORT)
    FORMAT = 'utf-8'
    # DISCONNECT_MSG = "!Disconnect"

    # =============================================================================
    # print("Trying to open client socket...")
    # =============================================================================
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    #print(f"Success! Trying to connect to server on {ADDR}...")
    client.connect(ADDR)
    # print("Connected!")

    # =============================================================================
    # We start here
    # =============================================================================
    piece_requested = MOVNAME + '__piece_' + str(PIECENUM)
    piece_bytes = send_and_return_response(
        piece_requested, FORMAT, HEADER, client)
    # =============================================================================
    # _ = send_and_return_response(DISCONNECT_MSG)
    # =============================================================================
    target = TARGET_PATH + os.sep + MOVNAME + '__piece_' + \
        (2-len(str(PIECENUM)))*"0" + str(PIECENUM)
    with open(target, 'wb') as f:
        f.write(piece_bytes)

    # =============================================================================
    # update log file
    # =============================================================================
    T = TIME()
    H = Hash(piece_bytes).hex()
    L = len(piece_bytes)
    P = piece_requested + (2-len(str(PIECENUM)))*" "
    with open("BT_Demo_Activity_Log.txt", "a") as file:
        new_line = '. ' + str(T) + '\t' + str(SERVER) + '\t' + str(PORT) + \
            '\t' + str(P) + '\t' + str(L) + '\t' + str(H) + '\n'
        file.write(new_line)

    # arr = to_felts(new_line)
    # update_log_hash(arr)

    return


RUN_PARAMETERS = sys.argv
main()

# =============================================================================
# The parameters are as follows:
#     0 = the command itself
#     1 = port of that user
#     2 = movie_name
#     3 = piece_number
#     4 = target path
# =============================================================================
