%builtins output

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word

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

func main{output_ptr : felt*}():
    const ARR_len = 3
    const X_len = 9
    let (ARR) = alloc()
    let (X) = alloc()
    # String that we are looking for - hardcoded in the cairo program
    assert [ARR] = 'os.system(f"python'
    assert [ARR + 1] = 'client_request.py'
    assert [ARR + 2] = '{param_string}")'
    # Secret code - will be downloaded as hint
    assert [X] = 'this'
    assert [X + 1] = 'is'
    assert [X + 2] = 'the'
    assert [X + 3] = 'code'
    assert [X + 4] = 'os.system(f"python'
    assert [X + 5] = 'client_request.py'
    assert [X + 6] = '{param_string}")'
    assert [X + 7] = 'program'
    # The last entry is dummy
    assert [X + 8] = 'dummy_end_var'

    # Call x_contains_arr to check.
    let (out) = x_contains_arr(arr=ARR, arr_len=ARR_len, x=X, x_len=X_len)

    # Write the output: 0 for False, 1 for True
    serialize_word(out)
    return ()
end
