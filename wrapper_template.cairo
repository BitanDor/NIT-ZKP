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

func x_start_with_arr(arr : felt*, arr_len, x : felt*, x_len) -> (out):
    if arr_len == 0:
        return (out=1)
    end
    if [arr] == [x]:
        let (out_of_rest) = x_start_with_arr(
            arr=arr + 1, arr_len=arr_len - 1, x=x + 1, x_len=x_len - 1)
        return (out=out_of_rest)
    end
    return (out=0)
end

func x_contains_arr(arr : felt*, arr_len, x : felt*, x_len) -> (out):
    if (arr_len) == (x_len):
        return (out=0)
    end
    let (temp_res) = x_start_with_arr(arr, arr_len, x, x_len)
    if (temp_res) == 1:
        return (out=1)
    end
    let (out_of_rest) = x_contains_arr(arr=arr, arr_len=arr_len, x=x + 1, x_len=x_len - 1)
    return (out=out_of_rest)
end

func count_arr_in_x(arr : felt*, arr_len, x : felt*, x_len, count) -> (out):
    if (arr_len) == (x_len):
        return (out=count)
    end
    let (temp_res) = x_start_with_arr(arr, arr_len, x, x_len)
    if (temp_res) == 1:
        let (out_of_rest) = count_arr_in_x(
            arr=arr, arr_len=arr_len, x=x + 1, x_len=x_len - 1, count=count + 1)
        return (out=out_of_rest)
    end
    let (out_of_rest) = count_arr_in_x(
        arr=arr, arr_len=arr_len, x=x + 1, x_len=x_len - 1, count=count)
    return (out=out_of_rest)
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    # Strings that we are looking for are hardcoded in the cairo program
    # The first one is in the code

    # The second isn't

    # The third should appear a specific number of times

    # Secret code - will be input as hint
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

    # Call x_contains_arr to check.

    # Write the output: 0 for False, 1 for True, number for count

    return ()
end
