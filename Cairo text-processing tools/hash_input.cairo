%builtins output pedersen

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

func arr_hash{hash_ptr0 : HashBuiltin*}(arr : felt*, arr_len, current) -> (out):
    if arr_len == 0:
        return (out=current)
    end
    let (new_current) = hash2{hash_ptr=hash_ptr0}(current, [arr])
    let (new_hash) = arr_hash{hash_ptr0=hash_ptr0}(
        arr=arr + 1, arr_len=arr_len - 1, current=new_current)
    return (out=new_hash)
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*}():
    alloc_locals

    local X : felt*
    local X_len

    # Hint:
    %{
        words = program_input['X']
        ids.X = X = segments.add()
        for i, val in enumerate(words):
            memory[X + i] = val

        ids.X_len = len(words)
    %}

    # compute hash of input and then output the result
    let (prog_hash) = arr_hash{hash_ptr0=pedersen_ptr}(arr=X + 1, arr_len=X_len - 1, current=[X])
    serialize_word(prog_hash)
    return ()
end
