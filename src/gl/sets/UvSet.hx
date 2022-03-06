package gl.sets;
import data.AttribAliases;
import data.AttribSet;
import data.DataType;
import gl.AttribSet;
class UvSet extends AttribSet {
    public static var instance(default, null):UvSet = new UvSet();

    function new() {
        super();
        addAttribute(AttribAliases.NAME_UV_0, 2, DataType.float32);
        createWriters();
    }
}