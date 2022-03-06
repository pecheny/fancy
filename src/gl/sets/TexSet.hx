package gl.sets;
import data.AttribAliases;
import data.AttribSet;
import data.DataType;
import gl.AttribSet;
class TexSet extends AttribSet {
    public static var instance(default, null):TexSet = new TexSet();

    function new() {
        super();
        addAttribute(AttribAliases.NAME_POSITION, 2, DataType.float32);
        addAttribute(AttribAliases.NAME_UV_0, 2, DataType.float32);
        createWriters();
    }
}

