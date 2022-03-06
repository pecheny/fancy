package gl;

import data.DataType;
typedef AttributeDescr = {
    name:String,
    type:DataType,
    numComponents:Int,
    ?offset:Int,
    ?writer:Float->Float
}

