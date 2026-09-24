/// @param datatype
/// @param looping
/// @param width
/// @param height

#macro __BUFFERGRID_F32_SIZE  4
#macro __BUFFERGRID_U32_SIZE  4

function BufferGridCreate(_datatype, _looping, _width, _height)
{
    if (_datatype == buffer_f32)
    {
        if (_looping)
        {
            return new BufferGridFloat32Looping(_width, _height);
        }
        else
        {
            return new BufferGridFloat32(_width, _height);
        }
    }
    else if (_datatype == buffer_u32)
    {
        if (_looping)
        {
            return new BufferGridUint32Looping(_width, _height);
        }
        else
        {
            return new BufferGridUint32(_width, _height);
        }
    }
    else
    {
        show_error($" \nDatatype `{_datatype}` not supported\n ", true);
    }
}