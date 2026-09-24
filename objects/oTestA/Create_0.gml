bufferGrid = new BufferGridUint32Looping(3, 3);

var _index = 1;
var _yCell = 0;
repeat(bufferGrid.GetHeight())
{
    var _xCell = 0;
    repeat(bufferGrid.GetWidth())
    {
        bufferGrid.Set(_xCell, _yCell, _index);
        ++_index;
        ++_xCell;
    }
    
    ++_yCell;
}