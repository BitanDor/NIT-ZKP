import json
from starkware.crypto.signature.signature import pedersen_hash as ph

p = 3618502788666131213697322783095070105623107215331596699973092056135872020481


def arr_hash2(arr):
    if len(arr) < 2:
        print("ARRAY TO SHORT!!!")
        return
    current = ph(arr[0], arr[1])
    for element in arr[2:]:
        current = ph(current, element)
    return current


with open("BitTorrent_Demo_LE_version.py_input.json") as json_file:
    data = json.load(json_file)

arr = data["X"]
print(len(arr))
H = arr_hash2(arr)
print(H)
print(H-p)

# 1557304605422253628149195471029628912684081729510345132154842755290894458551

# The following functions do the same, bu are much slower and yield Recurssion Error.
# def arr_hash(arr):
#     '''arr is an array of >2 non-negative integers smaller than cairo's prime'''
#     '''the function returns the hash of the array'''
#     if len(arr) < 2:
#         print("Array too small. Nothing to hash.")
#         return
#     return recursive_hash(arr[0], arr[1:])
#
# def recursive_hash(current, arr):
#     if len(arr) == 0:
#         return current
#     new_current = ph(current, arr[0])
#     return recursive_hash(new_current, arr[1:])
