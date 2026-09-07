#macro __BUFFER2D_F32_SIZE  4

function Buffer2D_f32(_width, _height) constructor
{
    __width  = max(0, _width);
    __height = max(0, _height);
    __buffer = buffer_create(__BUFFER2D_F32_SIZE*_width*_height, buffer_fixed, __BUFFER2D_F32_SIZE);
    
    static Fill =  function(_value)
    {
        buffer_fill(__buffer, 0, buffer_f32, _value, __BUFFER2D_F32_SIZE*__width*__height);
        
        return self;
    }
    
    static Set = function(_x, _y, _value)
    {
        if ((_x >= 0) && (_x < __width) && (_y >= 0) || (_y < __height))
        {
            buffer_poke(__buffer, __BUFFER2D_F32_SIZE*(_x + __width*_y), buffer_f32, _value);
        }
        
        return self;
    }
    
    static Get = function(_x, _y)
    {
        if ((_x >= 0) && (_x < __width) && (_y >= 0) || (_y < __height))
        {
            return buffer_peek(__buffer, __BUFFER2D_F32_SIZE*(_x + __width*_y), buffer_f32);
        }
        else
        {
            return undefined;
        }
    }
    
    static Duplicate = function()
    {
        var _new = new Buffer2D_f32(__width, __height);
        buffer_copy(__buffer, 0, __BUFFER2D_F32_SIZE*__width*__height, _new.__buffer, 0);
        return _new;
    }
    
    static CopyPartTo = function(_srcLeft, _srcTop, _copyWidth, _copyHeight, _destBuffer2d, _dstLeft, _dstTop)
    {
        var _srcWidth  = __width;
        var _srcHeight = __height;
        var _dstWidth  = _destBuffer2d.__width;
        var _dstHeight = _destBuffer2d.__height;
        
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
            
            buffer_copy_stride(__buffer,               __BUFFER2D_F32_SIZE*(_srcLeft + _srcWidth*_srcTop), __BUFFER2D_F32_SIZE*_copyWidth, __BUFFER2D_F32_SIZE*_srcWidth, _copyHeight,
                               _destBuffer2d.__buffer, __BUFFER2D_F32_SIZE*(_dstLeft + _dstWidth*_dstTop), __BUFFER2D_F32_SIZE*_dstWidth);
        }
        
        return self;
    }
    
    static Resize = function(_newWidth, _newHeight, _hAlign = fa_left, _vAlign = fa_top)
    {
        _newWidth  = max(0, _newWidth);
        _newHeight = max(0, _newHeight);
        
        var _oldWidth  = __width;
        var _oldHeight = __height;
        
        if ((_oldWidth == _newWidth) && (_oldHeight == _newHeight)) return;
        
        var _old = __buffer;
        var _new = buffer_create(__BUFFER2D_F32_SIZE*_newWidth*_newHeight, buffer_fixed, __BUFFER2D_F32_SIZE);
        
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
            
            buffer_copy_stride(_old, __BUFFER2D_F32_SIZE*(_srcX + _oldWidth*_srcY), __BUFFER2D_F32_SIZE*_copyWidth, __BUFFER2D_F32_SIZE*_oldWidth, _copyHeight,
                               _new, __BUFFER2D_F32_SIZE*(_dstX + _newWidth*_dstY), __BUFFER2D_F32_SIZE*_newWidth);
        }
        
        buffer_delete(_old);
        __width  = _newWidth;
        __height = _newHeight;
        __buffer = _new;
        
        return self;
    }
    
    static Shift = function(_dX, _dY)
    {
        if ((_dX == 0) && (_dY == 0)) return;
        
        var _width  = __width;
        var _height = __height;
        
        var _old = __buffer;
        var _new = buffer_create(__BUFFER2D_F32_SIZE*_width*_height, buffer_fixed, __BUFFER2D_F32_SIZE);
        
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
            
            buffer_copy_stride(_old, __BUFFER2D_F32_SIZE*(_srcX + _width*_srcY), __BUFFER2D_F32_SIZE*_copyWidth, __BUFFER2D_F32_SIZE*_width, _copyHeight,
                               _new, __BUFFER2D_F32_SIZE*(_dstX + _width*_dstY), __BUFFER2D_F32_SIZE*_width);
        }
        
        buffer_delete(_old);
        __buffer = _new;
        
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