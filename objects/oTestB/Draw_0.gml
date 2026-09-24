var _funcDebug = function(_x, _y, _bufferGrid)
{
    var _yCell = 0;
    repeat(_bufferGrid.GetHeight())
    {
        var _xCell = 0;
        repeat(_bufferGrid.GetWidth())
        {
            var _value = _bufferGrid.Get(_xCell, _yCell);
            
            draw_set_color((_value > 0)? c_white : c_gray);
            draw_text(_x + 30*_xCell, _y + 30*_yCell, _value);
        
            ++_xCell;
        }
        
        ++_yCell;
    }
}

_funcDebug( 10, 10, bufferGridA);
_funcDebug(210, 10, bufferGridB);
//_funcDebug(410, 10, bufferC);

draw_set_color(c_white);