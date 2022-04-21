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
    # x is an array of felts. The function checks if it begins with arr.
    # x must be at least as long as arr
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
    # x is an array of felts. The function checks if it contains arr.
    # we assume that x is longer than arr
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
    # x is an array of felts. The function checks if it contains arr.
    # we assume that x is longer than arr
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
    const ARR_len = 21
    let (ARR) = alloc()
    assert [ARR] = 'os'
    assert [ARR + 1] = '.'
    assert [ARR + 2] = 'system'
    assert [ARR + 3] = '('
    assert [ARR + 4] = 'f'
    assert [ARR + 5] = '"'
    assert [ARR + 6] = 'python'
    assert [ARR + 7] = ' '
    assert [ARR + 8] = 'client'
    assert [ARR + 9] = '_'
    assert [ARR + 10] = 'request'
    assert [ARR + 11] = '.'
    assert [ARR + 12] = 'py'
    assert [ARR + 13] = ' '
    assert [ARR + 14] = '{'
    assert [ARR + 15] = 'param'
    assert [ARR + 16] = '_'
    assert [ARR + 17] = 'string'
    assert [ARR + 18] = '}'
    assert [ARR + 19] = '"'
    assert [ARR + 20] = ')'

    # The second isn't
    const ARR2_len = 3
    let (ARR2) = alloc()
    assert [ARR2] = 'import'
    assert [ARR2 + 1] = ' '
    assert [ARR2 + 2] = 'socket'

    # The third should appear a specific number of times
    const ARR3_len = 2
    const ARR_exact_count3 = 7
    let (ARR3) = alloc()
    assert [ARR3] = 'import'
    assert [ARR3 + 1] = ' '

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

    # Call x_contains_arr to check.
    let (out) = x_contains_arr(arr=ARR, arr_len=ARR_len, x=X, x_len=X_len)
    let (out2) = x_contains_arr(arr=ARR2, arr_len=ARR2_len, x=X, x_len=X_len)
    let (out3) = count_arr_in_x(arr=ARR3, arr_len=ARR3_len, x=X, x_len=X_len, count=0)

    # Write the output: 0 for False, 1 for True
    serialize_word(prog_hash)
    serialize_word(out)
    serialize_word(out2)
    serialize_word(out3)
    assert out = 1
    assert out2 = 0
    assert out3 = ARR_exact_count3
    return ()
end
