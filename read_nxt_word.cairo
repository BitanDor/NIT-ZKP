%builtins output

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word

# This function returns a list of all the things that lie between a and b
func get_all_between(
        a : felt*, a_len, b : felt*, b_len, x : felt*, x_len, o : felt*, o_lens : felt*, o_len,
        o_total) -> (out : felt*, out_lens : felt*, out_len, out_total):
    if (a_len) == (x_len):
        return (out=o, out_lens=o_lens, out_len=o_len, out_total=o_total)
    end
    let (match) = x_start_with_arr(a, a_len, x, x_len)
    if (match) == 1:
        let (_, line_len) = read_to_point(b, b_len, x, x_len, o, o_total)
        let (oREST, o_lensREST, o_lenREST, o_totalREST) = get_all_between(
            a=a,
            a_len=a_len,
            b=b,
            b_len=b_len,
            x=x + 1,
            x_len=x_len - 1,
            o=o,
            o_lens=o_lens,
            o_len=o_len + 1,
            o_total=line_len)
        return (out=oREST, out_lens=o_lensREST, out_len=o_lenREST, out_total=o_totalREST)
    end
    let (oREST0, o_lensREST0, o_lenREST0, o_totalREST0) = get_all_between(
        a=a,
        a_len=a_len,
        b=b,
        b_len=b_len,
        x=x + 1,
        x_len=x_len - 1,
        o=o,
        o_lens=o_lens,
        o_len=o_len,
        o_total=o_total)
    return (oREST0, o_lensREST0, o_lenREST0, o_totalREST0)
end

# This function returns the first part of x that lies between a and b including a excluding b
func read_between(a : felt*, a_len, b : felt*, b_len, x : felt*, x_len, o : felt*, o_len) -> (
        out : felt*, out_len):
    if (a_len) == (x_len):
        return (out=o, out_len=o_len)
    end
    let (match) = x_start_with_arr(a, a_len, x, x_len)
    if (match) == 1:
        let (res, res_len) = read_to_point(b, b_len, x, x_len, o, o_len)
        return (res, res_len)
    end
    let (out_rest, out_rest_len) = read_between(a, a_len, b, b_len, x + 1, x_len - 1, o, o_len)
    return (out_rest, out_rest_len)
end

# This function returns the part of x from start until arr
func read_to_point(arr : felt*, arr_len, x : felt*, x_len, line : felt*, line_len) -> (
        out : felt*, out_len):
    if (arr_len) == (x_len):
        return (out=line, out_len=line_len)
    end
    assert [line + line_len] = [x]
    let (endpoint) = x_start_with_arr(arr=arr, arr_len=arr_len, x=x + 1, x_len=x_len - 1)
    if (endpoint) == 1:
        return (out=line, out_len=line_len + 1)
    end
    let (out_of_rest, len_of_rest) = read_to_point(
        arr=arr, arr_len=arr_len, x=x + 1, x_len=x_len - 1, line=line, line_len=line_len + 1)
    return (out_of_rest, len_of_rest)
end

# This function prints the elements of a given array
func print_all_words_in_list{output_ptr0 : felt*}(lst : felt*, lst_len) -> (
        new_lst : felt*, new_lst_len):
    if lst_len == 0:
        return (new_lst=lst, new_lst_len=lst_len)
    end
    serialize_word{output_ptr=output_ptr0}([lst])
    let (rest, rest_len) = print_all_words_in_list{output_ptr0=output_ptr0}(
        lst=lst + 1, lst_len=lst_len - 1)
    return (new_lst=rest, new_lst_len=rest_len)
end

# This function returns a list of all the words that come right after arr in x
func read_all_words_after_arrs(
        arr : felt*, arr_len, x : felt*, x_len, words_list : felt*, words_list_len) -> (
        out : felt*, out_len):
    if (arr_len) == (x_len):
        return (out=words_list, out_len=words_list_len)
    end
    let (temp_nxt_word, temp_left) = read_word_in_x_after_arr(
        arr=arr, arr_len=arr_len, x=x, x_len=x_len)
    if temp_nxt_word == 0:
        return (out=words_list, out_len=words_list_len)
    end
    assert [words_list + words_list_len] = temp_nxt_word
    let diff = x_len - temp_left
    let (out_of_rest, out_len_of_rest) = read_all_words_after_arrs(
        arr=arr,
        arr_len=arr_len,
        x=x + diff,
        x_len=x_len - diff,
        words_list=words_list,
        words_list_len=words_list_len + 1)
    return (out=out_of_rest, out_len=out_len_of_rest)
end

# This function returns the word that appears right after the first appearance of arr in x
func read_word_in_x_after_arr(arr : felt*, arr_len, x : felt*, x_len) -> (out, x_left):
    if (arr_len) == (x_len):
        return (out=0, x_left=0)
    end
    let (match) = x_start_with_arr(arr, arr_len, x, x_len)
    if (match) == 1:
        return (out=[x + arr_len], x_left=x_len - 1)
    end
    let (out_of_rest, x_left_of_rest) = read_word_in_x_after_arr(
        arr=arr, arr_len=arr_len, x=x + 1, x_len=x_len - 1)
    return (out_of_rest, x_left_of_rest)
end

# this function counts the number of times that arr appears in x
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

# This function returns 1 if x begins with arr, and 0 otherwise
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

# This function returns 1 if arr is in x, and 0 otherwise
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

func main{output_ptr : felt*}():
    alloc_locals
    # Strings that we are looking for are hardcoded in the cairo program
    # The first one is in the code
    const ARR_once_len0 = 3
    let (ARR_once0) = alloc()
    assert [ARR_once0 + 0] = 'os'
    assert [ARR_once0 + 1] = '.'
    assert [ARR_once0 + 2] = 'system'

    const ARR_none_len0 = 3
    let (ARR_none0) = alloc()
    assert [ARR_none0 + 0] = 'import'
    assert [ARR_none0 + 1] = ' '
    assert [ARR_none0 + 2] = 'socket'

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

    # get the first word in X that comes right after arr
    const ARR_for_nxt_len = 2
    let (ARR_for_nxt) = alloc()
    assert [ARR_for_nxt + 0] = 'import'
    assert [ARR_for_nxt + 1] = ' '
    let (nxt_word, left) = read_word_in_x_after_arr(
        arr=ARR_for_nxt, arr_len=ARR_for_nxt_len, x=X, x_len=X_len)
    serialize_word(nxt_word)
    serialize_word(left)
    serialize_word(X_len)
    serialize_word(1000000000000)

    # get all the words that come right after arr in X
    let (ARR_forr_all_nxts) = alloc()
    let (list_of_words, list_of_words_len) = read_all_words_after_arrs(
        arr=ARR_for_nxt,
        arr_len=ARR_for_nxt_len,
        x=X,
        x_len=X_len,
        words_list=ARR_forr_all_nxts,
        words_list_len=0)
    serialize_word([list_of_words])
    serialize_word(list_of_words_len)
    serialize_word(1000000000000)

    # print words in list that we find
    let (_none, _none_len) = print_all_words_in_list{output_ptr0=output_ptr}(
        lst=list_of_words, lst_len=list_of_words_len)
    serialize_word(1000000000000)

    # get all the words from start until endpoint
    const ARR_endpoint_len = 3
    let (ARR_endpoint) = alloc()
    assert [ARR_endpoint + 0] = 'import'
    assert [ARR_endpoint + 1] = ' '
    assert [ARR_endpoint + 2] = 'glob'
    let (ARR_initial) = alloc()
    let (res, res_len) = read_to_point(ARR_endpoint, ARR_endpoint_len, X, X_len, ARR_initial, 0)
    let (_none1, _none_len1) = print_all_words_in_list{output_ptr0=output_ptr}(
        lst=res, lst_len=res_len)
    serialize_word(1000000000000)

    # get the first thing that lies between a and b
    const ARR_A_len = 3
    let (ARR_A) = alloc()
    assert [ARR_A + 0] = 'while'
    assert [ARR_A + 1] = ' '
    assert [ARR_A + 2] = 'True'
    const ARR_B_len = 2
    let (ARR_B) = alloc()
    assert [ARR_B + 0] = 'if'
    assert [ARR_B + 1] = ' '
    let (ARR_between) = alloc()
    let (res_between, res_between_len) = read_between(
        ARR_A, ARR_A_len, ARR_B, ARR_B_len, X, X_len, ARR_between, 0)
    let (_none2, _none_len2) = print_all_words_in_list{output_ptr0=output_ptr}(
        res_between, res_between_len)
    serialize_word(1000000000000)

    # get everything that lies between a and b
    const A_len = 2
    let (A) = alloc()
    assert [A] = 'import'
    assert [A + 1] = ' '
    const B_len = 1
    let (B) = alloc()
    assert [B] = 'END_OF_LINE'

    let (root) = alloc()
    let (segments_lens) = alloc()
    let (all_between_root, all_between_lens, root_len, total_len) = get_all_between(
        a=A,
        a_len=A_len,
        b=B,
        b_len=B_len,
        x=X,
        x_len=X_len,
        o=root,
        o_lens=segments_lens,
        o_len=0,
        o_total=0)
    serialize_word(root_len)
    serialize_word(total_len)
    let (_none3, _none_len3) = print_all_words_in_list{output_ptr0=output_ptr}(
        all_between_root, total_len)

    # Call x_contains_arr to check.
    let (out_once0) = x_contains_arr(arr=ARR_once0, arr_len=ARR_once_len0, x=X, x_len=X_len)
    let (out_none0) = x_contains_arr(arr=ARR_none0, arr_len=ARR_none_len0, x=X, x_len=X_len)

    # assert outcomes
    assert out_once0 = 1
    assert out_none0 = 0

    return ()
end
