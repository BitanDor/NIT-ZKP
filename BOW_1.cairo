%builtins output

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word as sw

# bag is a beg of words given by (seen, counts, len).
# if w is in the beg, return its count.
# otherwise, return 0
func count_word_in_bag(w, seen : felt*, counts : felt*, len) -> (out):
    if len == 0:
        return (out=0)
    end
    if [seen] == w:
        return (out=[counts])
    end
    let (rest) = count_word_in_bag(w=w, seen=seen + 1, counts=counts + 1, len=len - 1)
    return (rest)
end

# gets two bags b0=(s0,c0,l0) and b1=(s1,c1,l1).
# returns a new bag that contains the words from b0 with added counts from b1
func update_matching_words(
        s0 : felt*, c0 : felt*, l0, s1 : felt*, c1 : felt*, l1, s_total : felt*, c_total : felt*,
        l_total) -> (os_total : felt*, oc_total : felt*, ol_total):
    if l0 == 0:
        return (os_total=s_total, oc_total=c_total, ol_total=l_total)
    end
    # n1 is the count of the current word in the bag b1
    let (n1) = count_word_in_bag([s0], s1, c1, l1)
    assert [s_total + l_total] = [s0]
    assert [c_total + l_total] = n1 + [c0]
    let (s_rest, c_rest, l_rest) = update_matching_words(
        s0 + 1, c0 + 1, l0 - 1, s1, c1, l1, s_total, c_total, l_total + 1)
    return (s_rest, c_rest, l_rest)
end

# gets a primary bag b0 = (s0,c0,l0) and a secondary bag b1 = (s1,c1,l1)
# writes to b0 all the words that do not appear in it
func update_non_matching_words(s0 : felt*, c0 : felt*, l0, s1 : felt*, c1 : felt*, l1) -> (
        s_out : felt*, c_out : felt*, l_out):
    if l1 == 0:
        return (s_out=s0, c_out=c0, l_out=l0)
    end
    let (match) = x_contains_word([s1], s0, l0)
    if (match) == 1:
        let (s_rest, c_rest, l_rest) = update_non_matching_words(s0, c0, l0, s1 + 1, c1 + 1, l1 - 1)
        return (s_rest, c_rest, l_rest)
    end
    assert [s0 + l0] = [s1]
    assert [c0 + l0] = [c1]
    let (s_rest, c_rest, l_rest) = update_non_matching_words(s0, c0, l0 + 1, s1 + 1, c1 + 1, l1 - 1)
    return (s_rest, c_rest, l_rest)
end

# gets two bags of words and returns their sum
func sum_bags(s0 : felt*, c0 : felt*, l0, s1 : felt*, c1 : felt*, l1, s2 : felt*, c2 : felt*) -> (
        out_s : felt*, out_c : felt*, out_l):
    let (join_s, join_c, join_l) = update_matching_words(s0, c0, l0, s1, c1, l1, s2, c2, 0)
    let (S, C, L) = update_non_matching_words(join_s, join_c, join_l, s1, c1, l1)
    return (S, C, L)
end

# gets a list of words x and creates bag of 2grams
# the first word in every 2gram is stored in w1, the second in w2, and the count in c
func bag_of_2grams(x : felt*, x_len, w1 : felt*, w2 : felt*, c : felt*, l) -> (
        x_out : felt*, x_len_out, w1_out : felt*, w2_out : felt*, c_out : felt*, l_out):
    if x_len == 1:
        return (x, x_len, w1, w2, c, l)
    end
    let (seen_current_2gram) = bag_contains_2gram([x], [x + 1], w1, w2, l)
    if (seen_current_2gram) == 1:
        let (x_rest, x_len_rest, w1_rest, w2_rest, c_rest, l_rest) = bag_of_2grams(
            x + 1, x_len - 1, w1, w2, c, l)
        return (x_rest, x_len_rest, w1_rest, w2_rest, c_rest, l_rest)
    end
    let (Arr) = alloc()
    assert [Arr] = [x]
    assert [Arr + 1] = [x + 1]
    let (current_2gram_count) = count_arr_in_x(Arr, 2, x, x_len, 0)
    assert [w1 + l] = [x]
    assert [w2 + l] = [x + 1]
    assert [c + l] = (current_2gram_count)
    let (x_rest, x_len_rest, w1_rest, w2_rest, c_rest, l_rest) = bag_of_2grams(
        x + 1, x_len - 1, w1, w2, c, l + 1)
    return (x_rest, x_len_rest, w1_rest, w2_rest, c_rest, l_rest)
end

# bow = bag of words
# the function gets a list of words x and returns their counts
func bow(x : felt*, x_len, seen : felt*, counts : felt*, seen_len) -> (
        out_x : felt*, out_x_len, out_seen : felt*, out_counts : felt*, out_seen_len):
    if x_len == 0:
        return (out_x=x, out_x_len=x_len, out_seen=seen, out_counts=counts, out_seen_len=seen_len)
    end
    let (seen_current_word) = x_contains_word([x], seen, seen_len)
    if (seen_current_word) == 1:
        let (x_rest, x_len_rest, seen_rest, counts_rest, seen_len_rest) = bow(
            x + 1, x_len - 1, seen, counts, seen_len)
        return (x_rest, x_len_rest, seen_rest, counts_rest, seen_len_rest)
    end
    let (current_word_count) = count_w_in_x([x], x, x_len, 0)
    assert [seen + seen_len] = [x]
    assert [counts + seen_len] = (current_word_count)
    let (x_rest, x_len_rest, seen_rest, counts_rest, seen_len_rest) = bow(
        x + 1, x_len - 1, seen, counts, seen_len + 1)
    return (x_rest, x_len_rest, seen_rest, counts_rest, seen_len_rest)
end

# This function returns 1 if w is in x, and 0 otherwise
func x_contains_word(w : felt, x : felt*, x_len) -> (out):
    if x_len == 0:
        return (out=0)
    end
    if [x] == w:
        return (out=1)
    end
    let (out_of_rest) = x_contains_word(w=w, x=x + 1, x_len=x_len - 1)
    return (out=out_of_rest)
end

func bag_contains_2gram(x, y, w1 : felt*, w2 : felt*, l) -> (out):
    if l == 0:
        return (out=0)
    end
    if [w1] == x:
        if [w2] == y:
            return (out=1)
        end
    end
    let (out_of_rest) = bag_contains_2gram(x, y, w1 + 1, w2 + 1, l - 1)
    return (out=out_of_rest)
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

# this function counts the number of times that w appears in x
func count_w_in_x(w, x : felt*, x_len, count) -> (out):
    if x_len == 0:
        return (out=count)
    end
    if [x] == w:
        let (out_of_rest) = count_w_in_x(w=w, x=x + 1, x_len=x_len - 1, count=count + 1)
        return (out=out_of_rest)
    end
    let (out_of_rest) = count_w_in_x(w=w, x=x + 1, x_len=x_len - 1, count=count)
    return (out=out_of_rest)
end

func display_bag{output_ptr0 : felt*}(seen : felt*, counts : felt*, len):
    if len == 0:
        return ()
    end
    sw{output_ptr=output_ptr0}([seen])
    sw{output_ptr=output_ptr0}([counts])
    display_bag{output_ptr0=output_ptr0}(seen + 1, counts + 1, len - 1)
    return ()
end

func display_2gram{output_ptr0 : felt*}(w1 : felt*, w2 : felt*, c : felt*, l):
    if l == 0:
        return ()
    end
    sw{output_ptr=output_ptr0}([w1])
    sw{output_ptr=output_ptr0}([w2])
    sw{output_ptr=output_ptr0}([c])
    display_2gram{output_ptr0=output_ptr0}(w1 + 1, w2 + 1, c + 1, l - 1)
    return ()
end

func main{output_ptr : felt*}():
    alloc_locals

    # ## First we declare the input X on which we work - either locally, or from input file.

    # ## Get X from input file:
    # local X : felt*
    # local X_len
    # %{
    #    words = program_input['X']
    #    ids.X = X = segments.add()
    #    for i, val in enumerate(words):
    #        memory[X + i] = val
    #    ids.X_len = len(words)
    #%}

    # ## Get X by local declaration
    const X_len = 10
    let (X) = alloc()
    assert [X + 0] = 'a'
    assert [X + 1] = 'b'
    assert [X + 2] = 'a'
    assert [X + 3] = 'b'
    assert [X + 4] = 'b'
    assert [X + 5] = 'c'
    assert [X + 6] = 'd'
    assert [X + 7] = 'c'
    assert [X + 8] = 'a'
    assert [X + 9] = 'a'

    # # ## Example of using bow
    let (empty_s) = alloc()
    let (empty_c) = alloc()
    let (_x, _x_len, s, c, l) = bow(X, X_len, empty_s, empty_c, 0)
    sw(l)

    # ## Example of using bow and sum_bags
    # ## First we create six empty lists.
    # ## The first four are used to create two bags from two parts of X.
    # ## The last two are used to hold the joint list.
    # let (empty_s0) = alloc()
    # let (empty_c0) = alloc()
    # let (empty_s1) = alloc()
    # let (empty_c1) = alloc()
    # let (empty_s_total) = alloc()
    # let (empty_c_total) = alloc()
    # ## Now we create the two bags
    # let (_x0, _x_len0, s0, c0, l0) = bow(X, 500, empty_s0, empty_c0, 0)
    # let (_x1, _x_len1, s1, c1, l1) = bow(X + 500, 500, empty_s1, empty_c1, 0)
    # ## Print the first bag (first its length, last 10*17 seperator)
    # sw(len0)
    # let () = display_bag{output_ptr0=output_ptr}(seen=full_seen0, counts=full_counts0, len=len0)
    # sw(100000000000000000)
    # ## Print the second bag (first its length, last 10*17 seperator)
    # sw(len1)
    # let () = display_bag{output_ptr0=output_ptr}(seen=full_seen1, counts=full_counts1, len=len1)
    # sw(100000000000000000)
    # ## Create the joint bag and display it:
    # let (S, C, L) = sum_bags(s0, c0, l0, s1, c1, l1, empty_s_total, empty_c_total)
    let () = display_bag{output_ptr0=output_ptr}(s, c, l)

    # ##Example of using bag_of_2grams
    # let (w1) = alloc()
    # let (w2) = alloc()
    # let (c) = alloc()
    # let (_x, _x_len, W1, W2, C, L) = bag_of_2grams(X, X_len, w1, w2, c, 0)
    # let () = display_2gram{output_ptr0=output_ptr}(W1, W2, C, L)
    # sw(L)
    return ()
end
