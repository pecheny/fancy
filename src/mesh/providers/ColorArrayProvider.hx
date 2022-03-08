package mesh.providers;
import hxColorToolkit.spaces.RGB;
class ColorArrayProvider {
    var colors:Array<RGB>;
    public function new(colors) {
        this.colors = colors;
    }

    public function getValue(v, c) {
        if (c == 3)
            return 255.;
        return colors[v % (colors.length)].getValue(c);
    }
}
