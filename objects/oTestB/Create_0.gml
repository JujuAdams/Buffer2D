bufferGridA = new BufferGridUint32Looping(3, 3);

var _index = 1;
var _yCell = 0;
repeat(bufferGridA.GetHeight())
{
    var _xCell = 0;
    repeat(bufferGridA.GetWidth())
    {
        bufferGridA.Set(_xCell, _yCell, _index);
        ++_index;
        ++_xCell;
    }
    
    ++_yCell;
}

bufferGridB = new BufferGridUint32Looping(bufferGridA.GetWidth(), bufferGridA.GetHeight());
bufferGridA.CopyTo(bufferGridB);

buffer = buffer_create(4*4*4, buffer_fixed, 4);
buffer_fill(buffer, 0, buffer_u32, 99, 4*4*4);

bufferGridB.CopyBufferToPart(buffer, 0, 4, 4,   2, 2);

//bufferA.CopyPartTo(-1, -1, 3, 2,   bufferB, 0, -1);