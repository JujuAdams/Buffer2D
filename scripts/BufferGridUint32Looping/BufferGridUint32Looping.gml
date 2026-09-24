/// @param width
/// @param height

function BufferGridUint32Looping(_width, _height) constructor
{
    __width  = clamp(_width,  0, 0xFFFF_FFFF);
    __height = clamp(_height, 0, 0xFFFF_FFFF);
    __size   = __BUFFERGRID_U32_SIZE*__width*__height;
    __buffer = buffer_create(__size, buffer_fixed, __BUFFERGRID_U32_SIZE);
    
    static GetLooping = function()
    {
        return true;
    }
    
    static Fill =  function(_value)
    {
        buffer_fill(__buffer, 0, buffer_u32, _value, __size);
        
        return self;
    }
    
    static Set = function(_x, _y, _value)
    {
        buffer_poke(__buffer, __BUFFERGRID_U32_SIZE*(wrap(_x, __width) + __width*wrap(_y, __height)), buffer_u32, _value);
        return self;
    }
    
    static Get = function(_x, _y)
    {
        return buffer_peek(__buffer, __BUFFERGRID_U32_SIZE*(wrap(_x, __width) + __width*wrap(_y, __height)), buffer_u32);
    }
    
    static GetInterpolated = function(_x, _y)
    {
        var _gridWidth = __width;
        
        var _x0 = wrap(_x,   _gridWidth);
        var _y0 = wrap(_y,   __height);
        var _x1 = wrap(_x+1, _gridWidth);
        var _y1 = wrap(_y+1, __height);
        
        var _xFrac = frac(_x);
        var _yFrac = frac(_y);
        _x = floor(_x);
        _y = floor(_y);
        
        var _buffer = __buffer;
        var _value00 = buffer_peek(_buffer, __BUFFERGRID_U32_SIZE*(_x0 + _gridWidth*_y0), buffer_u32);
        var _value10 = buffer_peek(_buffer, __BUFFERGRID_U32_SIZE*(_x1 + _gridWidth*_y0), buffer_u32);
        var _value01 = buffer_peek(_buffer, __BUFFERGRID_U32_SIZE*(_x0 + _gridWidth*_y1), buffer_u32);
        var _value11 = buffer_peek(_buffer, __BUFFERGRID_U32_SIZE*(_x1 + _gridWidth*_y1), buffer_u32);
        
        return lerp(lerp(_value00, _value10, _xFrac), lerp(_value01, _value11, _xFrac), _yFrac);
    }
    
    static Add = function(_x, _y, _value)
    {
        var _index = __BUFFERGRID_U32_SIZE*(wrap(_x, __width) + __width*wrap(_y, __height));
        buffer_poke(__buffer, _index, buffer_u32, buffer_peek(__buffer, _index, buffer_u32) + _value);
        return self;
    }
    
    static SetRegion = function(_left, _top, _width, _height, _value)
    {
        //TODO - Looping .SetRegion()
        sdm("TODO");
        return self;
        
        var _gridWidth  = __width;
        var _gridHeight = __height;
        var _buffer     = __buffer;
        
        var _right  = _left + _width-1;
        var _bottom = _top + _height-1;
        
        if ((_left < _gridWidth) && (_top < _gridHeight) && (_right >= 0) && (_bottom >= 0))
        {
            _right  = clamp(_left + _width-1, 0, _gridWidth-1);
            _bottom = clamp(_top + _height-1, 0, _gridHeight-1);
            _left   = clamp(_left, 0, _gridWidth);
            _top    = clamp(_top,  0, _gridHeight);
            
            var _size = __BUFFERGRID_U32_SIZE*(1 + _right - _left);
            var _index = __BUFFERGRID_U32_SIZE*(_left + _gridWidth*_top);
            repeat(1 + _bottom - _top)
            {
                buffer_fill(_buffer, _index, buffer_u32, _value, _size);
                _index += __BUFFERGRID_U32_SIZE*_gridWidth;
            }
        }
        
        return self;
    }
    
    static AddRegion = function(_left, _top, _width, _height, _value)
    {
        //TODO - Looping .AddRegion()
        sdm("TODO");
        return self;
        
        var _gridWidth  = __width;
        var _gridHeight = __height;
        var _buffer     = __buffer;
        
        var _right  = _left + _width-1;
        var _bottom = _top + _height-1;
        
        if ((_left < _gridWidth) && (_top < _gridHeight) && (_right >= 0) && (_bottom >= 0))
        {
            _right  = clamp(_left + _width-1, 0, _gridWidth-1);
            _bottom = clamp(_top + _height-1, 0, _gridHeight-1);
            _left   = clamp(_left, 0, _gridWidth);
            _top    = clamp(_top,  0, _gridHeight);
            
            var _regionWidth = 1 + _right - _left;
            var _y = _top;
            repeat(1 + _bottom - _top)
            {
                var _index = __BUFFERGRID_U32_SIZE*(_left + _gridWidth*_y);
                repeat(_regionWidth)
                {
                    buffer_poke(_buffer, _index, buffer_u32, buffer_peek(_buffer, _index, buffer_u32) + _value);
                    _index += __BUFFERGRID_U32_SIZE;
                }
                
                ++_y;
            }
        }
        
        return self;
    }
    
    static Randomize = function(_min, _max)
    {
        var _buffer = __buffer;
        
        buffer_seek(_buffer, buffer_seek_start, 0);
        repeat(__width*__height)
        {
            buffer_write(_buffer, buffer_u32, random_range(_min, _max));
        }
    }
    
    static Duplicate = function()
    {
        var _new = new BufferGridFloat32(__width, __height);
        buffer_copy(__buffer, 0, __size, _new.__buffer, 0);
        return _new;
    }
    
    static ConvertToNonLooping = function()
    {
        var _new = new BufferGridFloat32(__width, __height);
        buffer_copy(__buffer, 0, __size, _new.__buffer, 0);
        Destroy();
        return _new;
    }
    
    static CopyPartToBuffer = function(_srcLeft, _srcTop, _copyWidth, _copyHeight, _dstBuffer)
    {
        var _buffer    = __buffer;
        var _srcWidth  = __width;
        var _srcHeight = __height;
        
        var _dstWidth = _copyWidth; //Presume the width of the destination buffer is equal to the copy width
        
        _srcLeft = __BufferGridWrap(_srcLeft, _srcWidth);
        _srcTop  = __BufferGridWrap(_srcTop,  _srcHeight);
        
        var _dstY = 0;
        var _srcY = _srcTop;
        var _remainingY = _copyHeight;
        while(_remainingY > 0)
        {
            var _availableHeight = min(_remainingY, _srcHeight - _srcY);
            
            var _dstX = 0;
            var _srcX = _srcLeft;
            var _remainingX = _copyWidth;
            while(_remainingX > 0)
            {
                var _availableWidth = min(_remainingX, _srcWidth - _srcX);
                
                buffer_copy_stride(_buffer,    __BUFFERGRID_U32_SIZE*(_srcX + _srcWidth*_srcY), __BUFFERGRID_U32_SIZE*_availableWidth, __BUFFERGRID_U32_SIZE*_srcWidth, _availableHeight,
                                   _dstBuffer, __BUFFERGRID_U32_SIZE*(_dstX + _dstWidth*_dstY), __BUFFERGRID_U32_SIZE*_dstWidth);
                
                _dstX += _availableWidth;
                _remainingX -=_availableWidth;
                _srcX = wrap(_srcX + _availableWidth, _srcWidth);
            }
            
            _dstY += _availableHeight;
            _remainingY -=_availableHeight;
            _srcY = wrap(_srcY + _availableHeight, _srcHeight);
        }
        
        return self;
    }
    
    static CopyBufferToPart = function(_srcBuffer, _srcOffset, _dstLeft, _dstTop, _copyWidth, _copyHeight)
    {
        //TODO - Looping .CopyBufferToPart()
        
        var _dstWidth  = __width;
        var _dstHeight = __height;
        
        if ((_dstLeft >= _dstWidth) || (_dstTop >= _dstHeight))
        {
            return;
        }
        
        var _dstRight  = _dstLeft + _copyWidth-1;
        var _dstBottom = _dstTop + _copyHeight-1;
        
        if ((_dstRight < 0) || (_dstBottom < 0))
        {
            return;
        }
        
        var _inCopyWidth = _copyWidth;
        
        _dstLeft   = clamp(_dstLeft,   0, _dstWidth-1);
        _dstTop    = clamp(_dstTop,    0, _dstHeight-1);
        _dstRight  = clamp(_dstRight,  0, _dstWidth-1);
        _dstBottom = clamp(_dstBottom, 0, _dstHeight-1);
        
        _copyWidth  = 1 + _dstRight - _dstLeft;
        _copyHeight = 1 + _dstBottom - _dstTop;
        
        buffer_copy_stride(_srcBuffer, _srcOffset, __BUFFERGRID_U32_SIZE*_copyWidth, __BUFFERGRID_U32_SIZE*_inCopyWidth, _copyHeight,
                           __buffer, 0, __BUFFERGRID_U32_SIZE*__width);
        
        return self;
    }
    
    static CopyPartTo = function(_srcLeft, _srcTop, _copyWidth, _copyHeight, _destBufferGrid, _dstLeft, _dstTop)
    {
        //TODO - Looping .CopyPartTo()
        sdm("TODO");
        return self;
        
        var _srcWidth  = __width;
        var _srcHeight = __height;
        var _dstWidth  = _destBufferGrid.__width;
        var _dstHeight = _destBufferGrid.__height;
        
        if ((_srcLeft >= _srcWidth) || (_srcLeft >= _srcHeight) || (_dstLeft >= _dstWidth) || (_dstTop >= _dstHeight))
        {
            return;
        }
        
        var _srcRight  = _srcLeft + _copyWidth-1;
        var _srcBottom = _srcTop + _copyHeight-1;
        
        if ((_srcRight < 0) || (_srcBottom < 0))
        {
            return;
        }
        
        if (_srcLeft < 0) { _dstLeft -= _srcLeft; _srcLeft = 0; }
        if (_srcTop  < 0) { _dstTop  -= _srcTop;  _srcTop  = 0; }
        
        _srcLeft   = min(_srcLeft,   _srcWidth-1);
        _srcTop    = min(_srcTop,    _srcHeight-1);
        _srcRight  = min(_srcRight,  _srcWidth-1);
        _srcBottom = min(_srcBottom, _srcHeight-1);
        
        _srcRight  = min(_srcRight  + _dstLeft, _dstWidth-1)  - _dstLeft;
        _srcBottom = min(_srcBottom + _dstTop,  _dstHeight-1) - _dstTop;
        
        if (_dstLeft < 0) { _srcLeft -= _dstLeft; _dstLeft = 0; }
        if (_dstTop  < 0) { _srcTop  -= _dstTop;  _dstTop  = 0; }
        
        _copyWidth  = 1 + _srcRight - _srcLeft;
        _copyHeight = 1 + _srcBottom - _srcTop;
        
        if ((_copyWidth > 0) && (_copyHeight > 0))
        {
            
            buffer_copy_stride(__buffer,               __BUFFERGRID_U32_SIZE*(_srcLeft + _srcWidth*_srcTop), __BUFFERGRID_U32_SIZE*_copyWidth, __BUFFERGRID_U32_SIZE*_srcWidth, _copyHeight,
                               _destBufferGrid.__buffer, __BUFFERGRID_U32_SIZE*(_dstLeft + _dstWidth*_dstTop), __BUFFERGRID_U32_SIZE*_dstWidth);
        }
        
        return self;
    }
    
    static Resize = function(_newWidth, _newHeight, _hAlign = fa_left, _vAlign = fa_top)
    {
        _newWidth  = clamp(_newWidth,  0, 0xFFFF_FFFF);
        _newHeight = clamp(_newHeight, 0, 0xFFFF_FFFF);
        
        var _oldWidth  = __width;
        var _oldHeight = __height;
        
        if ((_oldWidth == _newWidth) && (_oldHeight == _newHeight)) return;
        
        var _old = __buffer;
        var _new = buffer_create(__BUFFERGRID_U32_SIZE*_newWidth*_newHeight, buffer_fixed, __BUFFERGRID_U32_SIZE);
        
        if ((_newWidth > 0) && (_newHeight > 0))
        {
            var _copyWidth  = min(_oldWidth, _newWidth);
            var _copyHeight = min(_oldHeight, _newHeight);
            
            var _srcX = 0;
            var _srcY = 0;
            var _dstX = 0;
            var _dstY = 0;
            
            if (_hAlign == fa_center)
            {
                if (_newWidth > _oldWidth)
                {
                    _dstX = floor(_newWidth - _oldWidth)/2;
                }
                else
                {
                    _srcX = floor(_oldWidth - _newWidth)/2;
                }
            }
            else if (_hAlign == fa_right)
            {
                if (_newWidth > _oldWidth)
                {
                    _dstX = _newWidth - _oldWidth;
                }
                else
                {
                    _srcX = _oldWidth - _newWidth;
                }
            }
            
            if (_vAlign == fa_center)
            {
                if (_newHeight > _oldHeight)
                {
                    _dstY = floor(_newHeight - _oldHeight)/2;
                }
                else
                {
                    _srcY = floor(_oldHeight - _newHeight)/2;
                }
            }
            else if (_vAlign == fa_right)
            {
                if (_newHeight > _oldHeight)
                {
                    _dstY = _newHeight - _oldHeight;
                }
                else
                {
                    _srcY = _oldHeight - _newHeight;
                }
            }
            
            buffer_copy_stride(_old, __BUFFERGRID_U32_SIZE*(_srcX + _oldWidth*_srcY), __BUFFERGRID_U32_SIZE*_copyWidth, __BUFFERGRID_U32_SIZE*_oldWidth, _copyHeight,
                               _new, __BUFFERGRID_U32_SIZE*(_dstX + _newWidth*_dstY), __BUFFERGRID_U32_SIZE*_newWidth);
        }
        
        buffer_delete(_old);
        __width  = _newWidth;
        __height = _newHeight;
        __size   = __BUFFERGRID_U32_SIZE*_newWidth*_newHeight;
        __buffer = _new;
        
        return self;
    }
    
    static Shift = function(_dX, _dY)
    {
        if ((_dX == 0) && (_dY == 0)) return;
        
        var _width  = __width;
        var _height = __height;
        
        var _old = __buffer;
        var _new = buffer_create(__BUFFERGRID_U32_SIZE*_width*_height, buffer_fixed, __BUFFERGRID_U32_SIZE);
        
        var _copyWidth  = _width - abs(_dX);
        var _copyHeight = _height - abs(_dY);
        
        if ((_copyWidth > 0) && (_copyHeight > 0))
        {
            var _srcX = 0;
            var _srcY = 0;
            var _dstX = 0;
            var _dstY = 0;
            if (_dX < 0) { _srcX = -_dX; } else { _dstX = _dX; }
            if (_dY < 0) { _srcY = -_dY; } else { _dstY = _dY; }
            
            buffer_copy_stride(_old, __BUFFERGRID_U32_SIZE*(_srcX + _width*_srcY), __BUFFERGRID_U32_SIZE*_copyWidth, __BUFFERGRID_U32_SIZE*_width, _copyHeight,
                               _new, __BUFFERGRID_U32_SIZE*(_dstX + _width*_dstY), __BUFFERGRID_U32_SIZE*_width);
        }
        
        buffer_delete(_old);
        __buffer = _new;
        
        return self;
    }
    
    static Serialize = function(_buffer)
    {
        buffer_write(_buffer, buffer_u8, 0x02);
        buffer_write(_buffer, buffer_bool, true); //looping
        buffer_write(_buffer, buffer_u32, __width);
        buffer_write(_buffer, buffer_u32, __height);
        
        if (buffer_tell(_buffer) + __size > buffer_get_size(_buffer))
        {
            buffer_resize(_buffer, buffer_tell(_buffer) + __size);
        }
        
        buffer_copy(__buffer, 0, __size, _buffer, buffer_tell(_buffer));
        buffer_seek(_buffer, buffer_seek_relative, __size);
        
        return self;
    }
    
    static __Deserialize = function(_buffer)
    {
        buffer_copy(_buffer, buffer_tell(_buffer), __size, __buffer, 0);
        buffer_seek(_buffer, buffer_seek_relative, __size);
        
        return self;
    }
    
    static GetBuffer = function()
    {
        return __buffer;
    }
    
    static GetWidth = function()
    {
        return __width;
    }
    
    static GetHeight = function()
    {
        return __height;
    }
    
    static Destroy = function()
    {
        buffer_delete(__buffer);
    }
}