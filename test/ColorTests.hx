
import utest.Assert;
import utest.Test;
import ec.CtxWatcher;
import ec.Entity;
import fancy.styles.ColorManagement;

class FakeColor implements Colored {
    public var color:Int;

    public function setColor(val:Int) {
        color = val;
    }

    public function new() {}
}

class FakeButton {
    public var textColor:FakeColor = new FakeColor();
    public var bgColor:FakeColor = new FakeColor();
    public var e:Entity;

    public function new(e:Entity) {
        this.e = e;
        var res = new ColorReceiver();
        res.addColored("bg", bgColor);
        res.addColored("fg", textColor);
        e.addComponent(res);
        new CtxWatcher(ColorBinder, e);
    }
}

class ColorTests extends Test {
    var btn:FakeButton;
    var root:Entity;

    public function setup() {
        trace("setup");
        btn = new FakeButton(new Entity("btn"));
        root = new Entity("root");
        var storage = new ColorStorage();
        storage.reg("bg", 0xffffff);
        storage.reg("fg", 0x00);
        var binder = new ColorBinder(storage);
        root.addComponent(binder);
    }

    public function test_color_binding() {
        root.addChild(btn.e);
        Assert.equals(0xffffff, btn.bgColor.color);
    }
}
