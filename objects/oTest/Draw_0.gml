var _funcDebug = function(_x, _y, _buffer2d)
{
    var _yCell = 0;
    repeat(_buffer2d.GetHeight())
    {
        var _xCell = 0;
        repeat(_buffer2d.GetWidth())
        {
            var _value = _buffer2d.Get(_xCell, _yCell);
            
            draw_set_color((_value > 0)? c_white : c_gray);
            draw_text(_x + 20*_xCell, _y + 20*_yCell, _value);
        
            ++_xCell;
        }
        
        ++_yCell;
    }
}

_funcDebug(10, 10, bufferA);
_funcDebug(210, 10, bufferB);

draw_set_color(c_white);