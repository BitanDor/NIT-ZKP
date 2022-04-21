import json
from datetime import datetime

# This file auto-generates the check-program W from an empty template and the below hard-coded lists. 

######   These are the lists. 
# We want to check that: 
# Every element of the white-list appears in the code at least once, 
# no element of the black-list appears in the code,
# elements in the count-list appear in the code according to the specified quantity. 


# The white-list
appear_at_least_once = [
    'os.system(f"python client_request.py {param_string}")']
    # "download_n_display_summary("

# The black-list
do_not_appear = [
    "socket"]
    # "import socket", 
    # "exec",
    # "send",
    # "bind",
    # "listen",
    # "connect",
    # "AF_INET",
    # "SOCK_STREAM",
    # "sendfile",
    # "ssl", 
    # "socketserver"

# The count_list
appear_exact= [
    ("import", 7)
    ]


# Some useful functions
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

def count_leading_spaces(string,count = 0):
    if string.startswith(" "):
        return count_leading_spaces(string[1:],count+1)
    return count

def convert_word_to_cairo_felt(word):
    l = len(word)
    if l == 0:
        return 0
    count = 0 
    for i, letter in enumerate(word):
        count += ord(letter)*pow(256,l-1-i)
    return count

def convert_from_felt_to_word(felt):
    word = ""
    num = felt
    while num > 0:
        word += chr(int(num%256))
        num = num - (num%256)
        num = num // 256
    return word[::-1]

def phrase_to_list(line):
    words = []
    if len(line):
        types = types_of_line(line)
        types_with_breaks = chr(167)
        line_with_breaks = chr(167)
        for char_type, char  in zip(types,line):
            if char_type == "0" and types_with_breaks[-1]=="0":
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
    return words

char_types = {
    "spacebar" : [32],
    "digits" : [48 + i for i in range(10)],
    "letters" : [65 + i for i in range(26)] + [97 + i for i in range(26)],
    "sign-words" : [33 + i for i in range(15)] + 
    [58 + i for i in range(7)] + 
    [91 + i for i in range(6)] + 
    [123 + i for i in range(4)]
}

types_index = {
    "spacebar" : "0",
    "digits" : "1",
    "letters" : "2",
    "sign-words" : "4"
}


# first we write the first part of the file:
cairo_wrapper = ""

with open("wrapper_template.cairo","r") as f:
    lines = f.readlines()

for line in lines[:60]:
    cairo_wrapper += line

# now we hard-code the lists.
# we begin with the white-list
for i, phrase in enumerate(appear_at_least_once):
    phrase_list = phrase_to_list(phrase)
    l = len(phrase_list)
    cairo_wrapper += f"    const ARR_once_len{i} = {l}\n"
    cairo_wrapper += f"    let (ARR_once{i}) = alloc()\n"
    for j, word in enumerate(phrase_list):
        cairo_wrapper += f"    assert [ARR_once{i} + {j}] = '{word}'\n"
    cairo_wrapper += "\n"

# now the black-list
for i, phrase in enumerate(do_not_appear):
    phrase_list = phrase_to_list(phrase)
    l = len(phrase_list)
    cairo_wrapper += f"    const ARR_none_len{i} = {l}\n"
    cairo_wrapper += f"    let (ARR_none{i}) = alloc()\n"
    for j, word in enumerate(phrase_list):
        cairo_wrapper += f"    assert [ARR_none{i} + {j}] = '{word}'\n"
    cairo_wrapper += "\n"

# now the count list
for i, phrase in enumerate(appear_exact):
    phrase_list = phrase_to_list(phrase[0])
    l = len(phrase_list)
    cairo_wrapper += f"    const ARR_exact_len{i} = {l}\n"
    cairo_wrapper += f"    const ARR_exact_count{i} = {phrase[1]}\n"
    cairo_wrapper += f"    let (ARR_exact{i}) = alloc()\n"
    for j, word in enumerate(phrase_list):
        cairo_wrapper += f"    assert [ARR_exact{i} + {j}] = '{word}'\n"
    cairo_wrapper += "\n"

# now we write the secret input part and hashing
for line in lines[65:84]:
    cairo_wrapper += line 

# now we call the functions
for i in range(len(appear_at_least_once)):
    cairo_wrapper += f"    let (out_once{i}) = x_contains_arr(arr=ARR_once{i}, arr_len=ARR_once_len{i}, x=X, x_len=X_len)\n"
for i in range(len(do_not_appear)):
    cairo_wrapper += f"    let (out_none{i}) = x_contains_arr(arr=ARR_none{i}, arr_len=ARR_none_len{i}, x=X, x_len=X_len)\n"
for i in range(len(appear_exact)):
    cairo_wrapper += f"    let (out_exact{i}) = count_arr_in_x(arr=ARR_exact{i}, arr_len=ARR_exact_len{i}, x=X, x_len=X_len, count = 0)\n"
cairo_wrapper += "\n"

# now we assert
for i in range(len(appear_at_least_once)):
    cairo_wrapper += f"    assert out_once{i} = 1\n"
for i in range(len(do_not_appear)):
    cairo_wrapper += f"    assert out_none{i} = 0\n"
for i in range(len(appear_exact)):
    cairo_wrapper += f"    assert out_exact{i} = ARR_exact_count{i}\n"
cairo_wrapper += "\n"

# now we print the outputs 
for i in range(len(appear_at_least_once)):
    cairo_wrapper += f"    serialize_word(out_once{i})\n"
for i in range(len(do_not_appear)):
    cairo_wrapper += f"    serialize_word(out_none{i})\n"
for i in range(len(appear_exact)):
    cairo_wrapper += f"    serialize_word(out_exact{i})\n"

cairo_wrapper += "\n"

# now we end the code
cairo_wrapper += "    return ()\n"
cairo_wrapper += "end"

# now we save the file

gen_time = str(datetime.now())[:-7].replace(" ","__").replace(":","_")
file_name = "wrapper_" + gen_time + ".cairo"

with open(file_name,"w") as f:
    f.write(cairo_wrapper)

