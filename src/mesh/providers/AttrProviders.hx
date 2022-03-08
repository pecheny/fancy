package mesh.providers;
import haxe.io.Bytes;
class TriPosProvider extends PosProvider {

    public function new(scale:Float, mirror = 1) {
        super();
        addVertex(-scale * mirror, -scale);
        addVertex(scale * mirror, -scale);
        addVertex(scale * mirror, scale);
    }


}

class QuadPosProvider extends PosProvider {
    public function new (x, y, w, h) {
        super();
        addVertex(x,y);
        addVertex(x+w,y);
        addVertex(x+w, y+h);
        addVertex(x, y+h);
    }

}

class PosProvider {
    var vertx:Array<Float> = [];
    var verty:Array<Float> = [];

    public function new() {}

    public function addVertex(x:Float, y:Float) {
        vertx.push(x);
        verty.push(y);
    }

    public function getPos(idx, cmp) {
        var carr =
        if (cmp == 0)
            vertx
        else if (cmp == 1)
            verty
        else throw "Wrong1";
        return carr[idx];
    }

    public function getValue(v,c) {
        return getPos(v, c);
    }

    public function load(vbo:Bytes, ofstX, ofstY, stride) {
        var vertCount = Std.int(vbo.length / stride);
        vertx = [];
        verty = [];
        for (vi in 0...vertCount) {
            var vo = stride * vi;
            vertx.push(vbo.getFloat(vo + ofstX));
            verty.push(vbo.getFloat(vo + ofstY));
        }
    }

    public function getVertCount() {
        return verty.length;
    }

}

class SolidColorProvider {
    var components:Array<Float> = [];

    public function new(r, g, b, a = 255) {
        components.push(r);
        components.push(g);
        components.push(b);
        components.push(a);
    }

    public function getValue(_, cmp) {
        return components[cmp];
    }

    public function setColor(val:Int) {
        var r = val >> 16;
        var g = (val & 0x00ff00) >> 8;
        var b = (val & 0x0000ff);
        components[0] = r;
        components[1] = g;
        components[2] = b;
        return this;
    }

    public static function fromInt(val:Int, a=255) {
        return new SolidColorProvider(0,0,0,a).setColor(val);
    }
}


