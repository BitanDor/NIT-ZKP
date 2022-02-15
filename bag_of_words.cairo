%builtins output

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word as sw

struct Word:
    member name : felt
    member count : felt
end

# bow stands for bag of words
# the functiong gets a list of words and returns their count
func bow(x : felt*, x_len, bag : Word*, bag_len, seen : felt*, seen_len) -> (
        out_x : felt*, out_x_len, out_bag : Word*, out_bag_len, out_seen : felt*, out_seen_len):
    if x_len == 0:
        return (
            out_x=x,
            out_x_len=x_len,
            out_bag=bag,
            out_bag_len=bag_len,
            out_seen=seen,
            out_seen_len=seen_len)
    end
    let (seen_current_word) = x_contains_word([x], seen, seen_len)
    if (seen_current_word) == 1:
        let (x_rest, x_len_rest, bag_rest, bag_len_rest, seen_rest, seen_len_rest) = bow(
            x + 1, x_len - 1, bag, bag_len, seen, seen_len)
        return (x_rest, x_len_rest, bag_rest, bag_len_rest, seen_rest, seen_len_rest)
    end
    let (current_word_count) = count_w_in_x([x], x, x_len, 0)
    assert [seen + seen_len] = [x]
    assert [bag + bag_len].name = [x]
    assert [bag + bag_len].count = (current_word_count)
    let (x_rest, x_len_rest, bag_rest, bag_len_rest, seen_rest, seen_len_rest) = bow(
        x + 1, x_len - 1, bag, bag_len + 2, seen, seen_len + 1)  # it is 2 there !!
    return (x_rest, x_len_rest, bag_rest, bag_len_rest, seen_rest, seen_len_rest)
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

func display_bag{output_ptr0 : felt*}(bag : Word*, bag_len):
    if bag_len == 0:
        return ()
    end
    sw{output_ptr=output_ptr0}([bag].name)
    sw{output_ptr=output_ptr0}([bag].count)
    display_bag{output_ptr0=output_ptr0}(bag + 2, bag_len - 2)
    return ()
end

func main{output_ptr : felt*}():
    alloc_locals
    # Secret code - will be input as hint
    local X : felt*
    local X_len

    # Hint:
    %{
        words = program_input['X'][:1000]
        ids.X = X = segments.add()
        for i, val in enumerate(words):
            memory[X + i] = val

        ids.X_len = len(words)
    %}

    # const X_len = 9
    # let (X) = alloc()
    # assert [X + 0] = 'a'
    # assert [X + 1] = 'b'
    # assert [X + 2] = 'a'
    # assert [X + 3] = 'b'
    # assert [X + 4] = 'b'
    # assert [X + 5] = 'c'
    # assert [X + 6] = 'd'
    # assert [X + 7] = 'c'
    # assert [X + 8] = 'a'

    let (local empty_bag : Word*) = alloc()
    let (empty_seen) = alloc()
    let (_x, _x_len, full_bag, full_bag_len, full_seen, full_seen_len) = bow(
        X, X_len, empty_bag, 0, empty_seen, 0)

    sw(full_seen_len)
    let () = display_bag{output_ptr0=output_ptr}(bag=full_bag, bag_len=full_bag_len)
    return ()
end
