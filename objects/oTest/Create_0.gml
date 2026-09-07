bufferA = new Buffer2D_f32(3, 3);
bufferA.Fill(1);

var _index = 1;
var _yCell = 0;
repeat(bufferA.GetHeight())
{
    var _xCell = 0;
    repeat(bufferA.GetWidth())
    {
        bufferA.Set(_xCell, _yCell, _index);
        ++_index;
        ++_xCell;
    }
    
    ++_yCell;
}

bufferB = new Buffer2D_f32(bufferA.GetWidth(), bufferA.GetHeight());
bufferA.CopyPartTo(-1, -1, 3, 2,   bufferB, 0, -1);