package macros;
import ec.Entity;
class InitMacroTest {

    public static function main(){
        new InitMacroTest();
    }

    public function new() {
        var root = new Entity();
        var c1 = new Obj();
        var c2 = new Obj("named");
        root.addComponent(c1);
        root.addComponentByName("Obj_named", c2);

        var tester = new InjectionTester();

        root.addChild(tester.entity);

        assert(c1, tester.obj, "Test once injection");
        assert(c2, tester.named, "Test named injection");
        trace('Test completed, succ: $success, fails: $fails');

    }

    var success:Int = 0;
    var fails:Int = 0;

    function assert(expected:Any, actual:Any, descr) {
        if (expected == actual)
            success++;
        else {
            fails++;
            trace("Test " + descr + " failed." + 'Expected: $expected, actual: $actual');
        }
    }
}

@:build(macros.InitMacro.build())
class InjectionTester {
    public var entity(default, null):Entity = new Entity();
    @:once public var obj:Obj;
    @:once("named") public var named:Obj;


    public function new() {
        entity.onContext.listen(_init);
        _init(entity.parent);
    }

    function _init(e){
    }

    public function init() {
    }

}

class Obj {
    static var count = 0;
    public var id(default, null):Int;
    var name = "noname";

    public function new(n = null) {
        if (n != null)
            name = n;
        id = count++;
    }

    function toString(){
        return name  + "_" + id;
    }
}
