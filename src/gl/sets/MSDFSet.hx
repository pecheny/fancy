package gl.sets;

import data.AttribAliases;
import data.AttribSet;
import data.DataType;
import gl.AttribSet;
class MSDFSet extends AttribSet {
    public static inline var NAME_DPI = "dpi";
    public static var instance(default, null):MSDFSet = new MSDFSet();

    function new() {
        super();
        addAttribute(AttribAliases.NAME_POSITION, 2, DataType.float32);
        addAttribute(AttribAliases.NAME_UV_0, 2, DataType.float32);
        addAttribute(NAME_DPI, 1, DataType.float32);
        createWriters();
    }
}
