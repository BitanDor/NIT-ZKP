# the code cannot contain:
# 1. the char chr(167) in lines that don't start with either #, ''', or """
# 2. a line with a single character, not including indentation

import json
import os
import random
from starkware.crypto.signature.signature import pedersen_hash as ph

# =3618502788666131213697322783095070105623107215331596699973092056135872020481
p = pow(2, 251) + 17*pow(2, 192) + 1


def arr_hash2(arr):
    if len(arr) < 2:
        print("ARRAY TO SHORT!!!")
        return
    current = ph(arr[0], arr[1])
    for element in arr[2:]:
        current = ph(current, element)
    return current


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


def count_leading_spaces(string, count=0):
    if string.startswith(" "):
        return count_leading_spaces(string[1:], count+1)
    return count


def convert_word_to_cairo_felt(word):
    l = len(word)
    if l == 0:
        return 0
    count = 0
    for i, letter in enumerate(word):
        count += ord(letter)*pow(256, l-1-i)
    return count


def convert_from_felt_to_word(felt):
    word = ""
    num = felt
    while num > 0:
        word += chr(int(num % 256))
        num = num - (num % 256)
        num = num // 256
    return word[::-1]


# Here we read the code
operating_system = os.name

if operating_system == "posix":
    loc = r"/mnt/c/Users/bitan/scripts/code/Law_ZKP/python"

if operating_system == "nt":
    loc = r"C:\Users\bitan\scripts\code\Law_ZKP\python"


file_name = "BitTorrent_Demo_LE_version.py"
with open(loc + os.sep + file_name, "r") as file:
    data = file.readlines()


# first we define what types of letters we have to create words
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

words = []

# convert code into list of words
for line in data:
    print(line)
    if len(line) > 3 and len(line.strip()) > 1:
        line_indentation = count_leading_spaces(line)
        stripped_line = line.strip()
        if (stripped_line[0] != "#") and (stripped_line[0:3] != "'''") and (stripped_line[0:3] != '"""'):
            if line_indentation > 0:
                words.append("INDENT_"+str(line_indentation))

            types = types_of_line(stripped_line)
            types_with_breaks = chr(167)
            line_with_breaks = chr(167)
            for char_type, char in zip(types, stripped_line):
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
            print(new_words, "\n")
            for new_word in new_words:
                if new_word:
                    words.append(new_word)

            words.append("END_OF_LINE")


# check if words are not too long and convert to cairo-felts
felts = []
ok = True
for word in words:
    felts.append(convert_word_to_cairo_felt(word))
    if len(word) > 31:
        ok = False
        print(f"Long word with {len(word)} chars: {word}")

# adding randomness:
felts.append(random.randint(0, p-1))

felts_hash = arr_hash2(felts)

# if all words are short, create a json file for the cairo program
if ok:
    out = loc + os.sep + file_name + "_input.json"
    mydict = {"X": felts}
    with open(out, "w") as out_file:
        json.dump(mydict, out_file)

    out_text = loc + os.sep + file_name + "_input.txt"
    passed_text = ""
    EOL = convert_word_to_cairo_felt("END_OF_LINE")
    IDT = "INDENT_"
    for felt in felts:
        if felt == EOL:
            passed_text += "\n"
        else:
            curr_word = convert_from_felt_to_word(felt)
            if curr_word.startswith(IDT):
                curr_idt = int(curr_word[7:])
                passed_text += " "*curr_idt
            else:
                passed_text += curr_word

    passed_text += f"\n# Hash computed of above text: {str(felts_hash)}"

    with open(out_text, "w") as out_text_file:
        out_text_file.write(passed_text)
