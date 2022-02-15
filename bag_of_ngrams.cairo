# This file is not working. IDK how to do dynamic memory allocation correctly (yet).
# One can do ngrams in a similar way to 2grams, you just need to know n in advance
# and then write the program that does it.
# Perhaps, I can have a python code that gets n and a templet like 2grams and creates a code for ngrams.

%builtins output

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word as sw

struct B:
    member b : felt*
end

func fill_L(bag : B*, bag_len, n) -> (out_bag : B*, out_bag_len):
    if n == 0:
        return (bag, bag_len)
    end
    let (b) = alloc()
    assert [bag + bag_len] = B(b)
    let (rest, rest_len) = fill_L(bag, bag_len + 1, n - 1)
    return (rest, rest_len)
end

func main{output_ptr : felt*}():
    alloc_locals

    # ## Get X from input file:
    local X : felt*
    local X_len
    %{
        words = program_input['X'][:200]
        ids.X = X = segments.add()
        for i, val in enumerate(words):
            memory[X + i] = val

        ids.X_len = len(words)
    %}

    # here we write the value of n for the ngrams:
    let ptr = cast([fp], B*)
    let (Bag, Bag_len) = fill_L(ptr, 0, n=4)
    sw(Bag_len)

    return ()
end
