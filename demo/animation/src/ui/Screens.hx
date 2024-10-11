package ui;

import ec.Component;
import a2d.PlaceholderBuilder2D;
import ec.Entity;
import al.animation.Animation.AnimContainer;
import al.layouts.OffsetLayout;
import a2d.Stage;
import update.Updatable;
import al.animation.AnimationTreeBuilder;
import al.ec.WidgetSwitcher;
import a2d.Widget;
import al.animation.Animation.AnimationPlaceholder;

class Screens implements Updatable {
    var tree:AnimationPlaceholder;
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

    public var screens:Map<String, Screen> = new Map();
    public var switcher:WidgetSwitcher<Axis2D>;

    var prev:Screen;
    var prevAnim:Animator;
    var current:Screen;
    var curAnim:Animator;

    public function new(switcher) {
        this.switcher = switcher;
        tree = new AnimationTreeBuilder().build({
            layout: "portion",
            children: [{size: {value: 1.}}, {size: {value: 1.}},]
        });
        tree.bindAnimation(0, t -> {
            if (prevAnim != null)
                prevAnim.setT(1 - t);
        });
        tree.bindAnimation(1, t -> {
            if (current != null)
                curAnim.setT(t);
        });
    }

    public function add(name, screen) {
        screens[name] = screen;
        switcher.bind(screen.ph);
        switcher.unbind(screen.ph);
    }

    public function switchTo(name) {
        time = current != null ? 0 : 0.5;
        prev = current;
        prevAnim = curAnim;
        current = screens[name];
        curAnim = current.entity.getComponent(Animator);
        switcher.bind(current.ph);
    }

    public function update(dt:Float):Void {
        if (time == 1 || current == null)
            return;
        time += dt / duration;
        if (time >= 1)
            time = 1;
        tree.setTime(time);
        if (time == 1 && prev != null) {
            switcher.unbind(prev.ph);
            prev = null;
        }
    }
}

@:build(ec.macros.Macros.buildGetOrCreate())
class Animator extends Component {
    var tree:AnimationPlaceholder;
    @:once var animationTreeBuilder:AnimationTreeBuilder;

    override function init() {
        tree = animationTreeBuilder.build({
            layout: OffsetLayout.NAME,
            children: []
        });
    }

    public function setT(t:Float) {
        if (tree == null)
            return;
        tree.setTime(t);
        // for (a in Axis2D) {
        //     var axis = ph.axisStates[a];
        //     axis.apply(axis.getPos(), axis.getSize());
        // }
    }

    public function addAnim(h) {
        var animContainer = tree.entity.getComponent(AnimContainer);
        var anim = animationTreeBuilder.animationWidget(new Entity(), {});
        animationTreeBuilder.addChild(animContainer, anim);
        anim.animations.channels.push(h);
        animContainer.refresh();
    }
}

class Screen extends Widget {
    var b:PlaceholderBuilder2D;
    var stage:Stage;
    var animator:Animator;
    @:once var fuiBuilder:FuiBuilder;

    override function init() {
        animator = Animator.getOrCreate(entity, entity);
        this.b = fuiBuilder.placeholderBuilder;
        this.stage = fuiBuilder.ar;
    }
}
