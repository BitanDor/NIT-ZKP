%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr : felt*}():
    serialize_word(1234)
    serialize_word(4321)
    return ()
end
