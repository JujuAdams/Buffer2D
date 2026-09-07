/// @param buffer

function BufferGridDeserialize(_buffer)
{
    var _type   = buffer_read(_buffer, buffer_u8);
    var _width  = buffer_read(_buffer, buffer_u32);
    var _height = buffer_read(_buffer, buffer_u32);
    
    if (_type == 0x01)
    {
        var _new = new BufferGridFloat32(_width, _height).__Deserialize(_buffer);
    }
    else
    {
        show_error($" \nBuffer 2D type `{_type}` not supported\n ", true);
    }
    
    return _new;
}