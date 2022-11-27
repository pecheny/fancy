package ui;
import al.animation.AnimationTreeBuilder;
import al.ec.WidgetSwitcher;
import widgets.Widget;
import utils.Updatable;
import al.animation.Animation.AnimWidget;
class Screens implements Updatable {
    var tree:AnimWidget;
    var time:Float = 0;
    var e1 = (t:Float) -> {
        var a1 = Math.abs((Math.sin(Math.PI * t / 2)));
        return Math.pow(a1, 2);
    }

    var e2 = t -> {
        var a1 = Math.abs((Math.sin(Math.PI * t / 2)));
        return Math.pow(a1, 2);
    }

    var duration = 2.;
    public inline static var ONE:String = "one";
    public inline static var TWO:String = "TWO";

    public var screens:Map<String, Screen> = new Map();
    public var switcher:WidgetSwitcher<Axis2D>;
    var prev:Screen;
//    var next:Screen;
    var current:Screen;

    public function new(switcher) {
        this.switcher = switcher;
        tree = new AnimationTreeBuilder().build(
            {
                layout:"portion",
                children:[
                    {size:{value:1. }},
                    {size:{value:1. }},
                ]
            }
        );
        tree.bindAnimation(0, t -> {if (prev != null) prev.setT(1 - t);});
        tree.bindAnimation(1, t -> {if (current != null) current.setT(t);});
    }

    public function add(name, screen) {
        screens[name] = screen;
        switcher.bind(screen.widget());
        switcher.unbind(screen.widget());
    }

    public function switchTo(name) {
        time = current != null ? 0 : 0.5;
        prev = current;
        current = screens[name];
        switcher.bind(current.widget());
    }

    public function update(dt:Float):Void {
        if (time == 1 || current == null)
            return;
        time += dt / duration;
        if (time >= 1) time = 1;
        tree.setTime(time);
        if (time == 1 && prev != null) {
            switcher.unbind(prev.widget());
            prev = null;
        }
    }
}


class Screen extends Widget {
    var tree:AnimWidget;

    public function setT(t:Float) {
        if (tree == null)
            return;
        tree.setTime(t);
        for (a in Axis2D) {
            var axis = w.axisStates[a];
            axis.apply(axis.getPos(), axis.getSize());
        }
    }
}
