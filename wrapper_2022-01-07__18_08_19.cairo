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
    const ARR_once_len0 = 21
    let (ARR_once0) = alloc()
    assert [ARR_once0 + 0] = 'os'
    assert [ARR_once0 + 1] = '.'
    assert [ARR_once0 + 2] = 'system'
    assert [ARR_once0 + 3] = '('
    assert [ARR_once0 + 4] = 'f'
    assert [ARR_once0 + 5] = '"'
    assert [ARR_once0 + 6] = 'python'
    assert [ARR_once0 + 7] = ' '
    assert [ARR_once0 + 8] = 'client'
    assert [ARR_once0 + 9] = '_'
    assert [ARR_once0 + 10] = 'request'
    assert [ARR_once0 + 11] = '.'
    assert [ARR_once0 + 12] = 'py'
    assert [ARR_once0 + 13] = ' '
    assert [ARR_once0 + 14] = '{'
    assert [ARR_once0 + 15] = 'param'
    assert [ARR_once0 + 16] = '_'
    assert [ARR_once0 + 17] = 'string'
    assert [ARR_once0 + 18] = '}'
    assert [ARR_once0 + 19] = '"'
    assert [ARR_once0 + 20] = ')'

    const ARR_none_len0 = 1
    let (ARR_none0) = alloc()
    assert [ARR_none0 + 0] = 'socket'

    const ARR_exact_len0 = 1
    const ARR_exact_count0 = 7
    let (ARR_exact0) = alloc()
    assert [ARR_exact0 + 0] = 'import'

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
    let (out_once0) = x_contains_arr(arr=ARR_once0, arr_len=ARR_once_len0, x=X, x_len=X_len)
    let (out_none0) = x_contains_arr(arr=ARR_none0, arr_len=ARR_none_len0, x=X, x_len=X_len)
    let (out_exact0) = count_arr_in_x(arr=ARR_exact0, arr_len=ARR_exact_len0, x=X, x_len=X_len, count = 0)

    assert out_once0 = 1
    assert out_none0 = 0
    assert out_exact0 = ARR_exact_count0

    serialize_word(out_once0)
    serialize_word(out_none0)
    serialize_word(out_exact0)

    return ()
end