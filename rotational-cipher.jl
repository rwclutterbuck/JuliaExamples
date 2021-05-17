# Important Notes:
# Inspiratoin comes from example solutions by:
# Tomerarnon on rotational-cipher (this is mostly a branchless version of his
# example)
# Nucleotide count example solutions (this github repository)
#
# rotate char and string both call the same function but are not compatible with
# one another due to different sized data for characters.
# i.e. a char is 32 bit and a string is 8 bit.
# This is not an issue if only ASCII chars are used, however if non-ASCII
# chars are used then the code breaks down, hence the below solution.
#
# Below configuration looks to be close to 4x increase in speed over standard
# solution:
# original rotate = 623.638ns
# below rotate    = 152.620ns
rotate(rot::Real, code::AbstractChar) = Char(rotate(rot, UInt32(code)))

function rotate(rot::Real, code::AbstractString)
    code_uint = transcode(UInt8,code)
    transcode(String, UInt8.(rotate.(rot,code_uint)))
end

@inline function rotate(rot::Real, code::Unsigned)
    a, A, z, Z  = UInt64.(('a', 'A', 'z', 'Z'))
    lowest_char = A + 0x20*(a<=code<=z)
    char_shift = lowest_char + (code - lowest_char + rot) % 0x1a
    isascii    = (a<=code<=z) | (A<=code<=Z)
    ifelse(isascii, char_shift, code)
end

for i = 0:26
    macro_name = Symbol("R",string(i),"_str")
    @eval macro $(macro_name)(code)
        rotate($i,code)
    end
end
