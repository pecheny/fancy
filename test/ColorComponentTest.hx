import utest.Assert;
import ec.Entity;
import ColorTests;
import utest.Test;
import fancy.styles.ColorManagement;

class ColorComponentTest extends Test {
    var btn:FakeButton;
    var root:Entity;

    public function setup() {
        root = new Entity("root");
        var storage = new ColorStorageComponent();
        storage.reg("bg", 0xffffff);
        storage.reg("fg", 0x00);
        root.addComponent(storage);
        btn = new FakeButton(new Entity("btn"));
    }

    public function test_plain_biding() {
        root.addChild(btn.e);
        Assert.equals(0xffffff, btn.bgColor.color);
    }

    public function test_changing_subscription() {
        root.addChild(btn.e);
        root.getComponent(ColorStorageComponent).reg("bg", 0xff0000);
        Assert.equals(0xff0000, btn.bgColor.color);
    }

    public function test_rebinding() {
        root.addChild(btn.e);
        var root2 = new Entity("root2");
        var storage = new ColorStorageComponent();
        storage.reg("bg", 0x00ff00);
        root2.addComponent(storage);
        root2.addChild(btn.e);
        Assert.equals(0x00ff00, btn.bgColor.color);
    }

    public function test_proxy_vals() {
        var root2 = new Entity("root2");
        var storage = new ColorStorageComponent();
        storage.reg("fg", 0x00ff00);
        root2.addChild(btn.e);
        root2.addComponent(storage);
        root.addChild(root2);
        Assert.equals(0x00ff00, btn.fgColor.color);
        Assert.equals(0xffffff, btn.bgColor.color);
    }

    public function test_proxy_vals2() {
        var root2 = new Entity("root2");
        var storage = new ColorStorageComponent();
        storage.reg("fg", 0x00ff00);
        root2.addChild(btn.e);
        root2.addComponent(storage);
        root.addChild(root2);
        var bgCnt = 0;
        var fgCnt = 0;
        storage.changed.listen(a -> {
            switch a {
                case "bg": bgCnt++;
                case "fg": fgCnt++;
            }
        });
        root.getComponent(ColorStorageComponent).reg("bg", 0xff0000);
        root.getComponent(ColorStorageComponent).reg("fg", 0xff0000);
        Assert.equals(0, fgCnt); // root2 has its own val so root changes shouldnt be dispatched
        Assert.equals(1, bgCnt);
        Assert.equals(0x00ff00, btn.fgColor.color);
        Assert.equals(0xff0000, btn.bgColor.color);
    }

    public function test_proxy_vals3() {
        var root2 = new Entity("root2");
        var storage = new ColorStorageComponent();
        storage.reg("fg", 0x00ff00);
        root2.addChild(btn.e);
        root2.addComponent(storage);
        Assert.equals(0x00ff00, btn.fgColor.color);
        Assert.equals(0, btn.bgColor.color);
        root.addChild(root2);
        Assert.equals(0x00ff00, btn.fgColor.color);
        Assert.equals(0xffffff, btn.bgColor.color);
        root.getComponent(ColorStorageComponent).reg("fg", 0xff0000);
        root.getComponent(ColorStorageComponent).reg("bg", 0xff0000);
        Assert.equals(0xff0000, btn.bgColor.color);
    }
}
