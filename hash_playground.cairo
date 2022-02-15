%builtins output pedersen

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word as sw
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

    const ARR_len = 5
    let (ARR) = alloc()
    assert [ARR] = '10'
    assert [ARR + 1] = '20'
    assert [ARR + 2] = '30'
    assert [ARR + 3] = '40'
    assert [ARR + 4] = '50'

    let (c) = arr_hash{hash_ptr0=pedersen_ptr}(arr=ARR + 1, arr_len=ARR_len - 1, current=[ARR])
    # const a = 3
    # const b = 4
    # let (c) = my_hash{hash_ptr0=pedersen_ptr}(a, b)
    sw(c)
    return ()
end
