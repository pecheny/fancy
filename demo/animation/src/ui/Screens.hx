package ui;

import a2d.Placeholder2D;
import al.animation.Animation.AnimationPlaceholder;
import al.animation.AnimationTreeBuilder;
import al.ec.WidgetSwitcher;
import update.Updatable;

class Screens implements Updatable {
    var tree:AnimationPlaceholder;
    var time:Float = 0;
    var duration = 2.;
    var switcher:WidgetSwitcher<Axis2D>;
    var prev:Placeholder2D;
    var prevAnim:Animator;
    var current:Placeholder2D;
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
            if (curAnim != null)
                curAnim.setT(t);
        });
    }

    public function switchTo(ph:Placeholder2D) {
        time = current != null ? 0 : 0.5;
        prev = current;
        prevAnim = curAnim;
        current = ph;
        curAnim = current.entity.getComponent(Animator);
        switcher.bind(ph);
    }

    public function update(dt:Float):Void {
        if (time == 1 || current == null)
            return;
        time += dt / duration;
        if (time >= 1)
            time = 1;
        tree.setTime(time);
        if (time == 1 && prev != null) {
            switcher.unbind(prev);
            prev = null;
        }
    }
}
