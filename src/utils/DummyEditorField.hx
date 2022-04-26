package utils;
import openfl.events.KeyboardEvent;
import openfl.text.TextFieldType;
import openfl.text.TextField;
class DummyEditorField {
    public static var value:Float = 10;
    public function new() {
        var t = new TextField();
        t.scaleY = t.scaleX = 3;
        t.text = "" + value;
        t.type = TextFieldType.INPUT;
        t.textColor = 0xffffff;
        openfl.Lib.current.addChild(t);
        t.addEventListener(KeyboardEvent.KEY_UP, (e) -> {
            var trg:TextField = e.target;
            trace(trg.text);
            value = Std.parseFloat(trg.text);
        });

//        var r = {x:0., y:-1., w:1., h:1.}
//        var tile = new GLGlyphData(r, r, 1., 1.);
//        tiles[0].tile = tile;
    }
}
