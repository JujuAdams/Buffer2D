bufferA = new BufferGridFloat32(3, 3);

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

bufferB = new BufferGridFloat32(bufferA.GetWidth(), bufferA.GetHeight());
bufferA.CopyPartTo(-1, -1, 3, 2,   bufferB, 0, -1);

saveBuffer = buffer_create(1024, buffer_grow, 1);
bufferB.Serialize(saveBuffer);
buffer_seek(saveBuffer, buffer_seek_start, 0);
bufferC = BufferGridDeserialize(saveBuffer);