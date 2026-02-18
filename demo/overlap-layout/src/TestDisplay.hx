import openfl.Lib;
import openfl.ui.Keyboard;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import lime.graphics.opengl.GL;

class TestDisplay extends Sprite {
    public function new() {
        super();
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
        __transform.tz = 1;
    }

    function onKey(e:Event) {
        var ke:KeyboardEvent = cast e;
        switch ke.keyCode {
            case Keyboard.A:
                getDepthPixels();
        }
    }

    function getDepthPixels() {
        var width:Int = stage.stageWidth;
        var height:Int = stage.stageHeight;
        var pixels = new lime.utils.UInt8Array(width * height);

        // Read the depth buffer into our array
        GL.readPixels(0, 0, width, height, GL.DEPTH_COMPONENT, GL.UNSIGNED_BYTE, pixels);
        var depthBitmap = new openfl.display.BitmapData(width, height, true, 0);

        // Convert 8-bit depth to 32-bit ARGB (grayscale)
        for (i in 0...pixels.length) {
            var val = pixels[i];
            // Create an ARGB color: 0xFF (Alpha) + R, G, B being the depth value
            var color = (0xFF << 24) | (val << 16) | (val << 8) | val;
            // Optimization: In a real app, use a faster byte-copying method
            depthBitmap.setPixel32(i % width, height - 1 - Std.int(i / width), color);
        }

        while (numChildren > 0)
            removeChildAt(0);

        addChild(new Bitmap(depthBitmap));
    }
}
