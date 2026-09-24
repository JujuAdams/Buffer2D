/// @param value
/// @param modulo

function __BufferGridWrap(_value, _modulo)
{
    return (_value < 0)? ((_value mod _modulo) + _modulo) : (_value mod _modulo);
}