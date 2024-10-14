package widgets;

import al.animation.Animation.AnimContainer;
import al.animation.Animation.AnimationPlaceholder;
import al.animation.AnimationTreeBuilder;
import ec.Component;
import ec.CtxWatcher.CtxBinder;
import ec.CtxWatcher;
import ec.Entity;
import fu.PropStorage;
import fu.graphics.BarWidget;
import fu.graphics.ColouredQuad.InteractiveColors;
import fu.ui.AnimatedLabel;
import fu.ui.ButtonBase;
import gl.sets.ColorSet;
import graphics.ShapeColors;
import graphics.shapes.Bar;

class WonderButton extends ButtonBase implements Channels {
    public var channels(default, null):Array<Float->Void> = [];

    var tree:AnimationTreeComponent;

    public function new(w, h, text, style) {
        super(w, h);

        var elements = [
            new BarContainer(Portion(new BarAxisSlot({start: 0., end: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
            new BarContainer(FixedThikness(new BarAxisSlot({pos: 0., thikness: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
        ];
        var bg = new BarWidget(ColorSet.instance, w, elements);
        var bgcolors = new ShapeColors(ColorSet.instance, bg.getBuffer());
        bg.onShapesDone.listen(() -> bgcolors.initChildren(bg.getChildren()));
        bgcolors.colorize(1, 0x6c6c6c);
        addHandler(new InteractiveColors(bgcolors.getColorizeFun(0)).viewHandler);

        var lbl = new AnimatedLabel(w, style);
        lbl.withText(text);

        WonderKit.configure(entity);
        tree = new AnimationTreeComponent(entity, this);
        channels.push(BarAnimationUtils.directUnfold(elements[1]));
        channels.push(BarAnimationUtils.directUnfold(elements[0]));
        channels.push(lbl.setTime);
    }

    public function setTime(t):Void {
        tree.setTime(t);
    }
}

class WonderKit {
    public static function configure(e:Entity) {
        var props = new DummyProps<AnimationPreset>();
        var preset = new AnimationPreset({
            layout: "wholefill",
            children: [
                {
                    layout: "portion",
                    children: [{size: {value: .4}}, {size: {value: 1.}},]
                }
            ]
        });
        preset.mapping.push(AnimationSlotSelectors.pathSelector.bind([0, 0]));
        preset.mapping.push(AnimationSlotSelectors.pathSelector.bind([0, 1]));
        preset.mapping.push(AnimationSlotSelectors.pathSelector.bind([0, 1]));
        props.set(AnimationTreeComponent.getId(WonderButton), preset);
        e.addComponentByType(PropStorage, props);
    }
}

typedef Selector = AnimationPlaceholder->AnimationPlaceholder;

class AnimationPreset {
    public var treeDesc(default, null):Dynamic; //  uikit+class based preset
    public var mapping(default, null):Array<Selector> = []; // uikit+class based preset

    public function new(descr) {
        this.treeDesc = descr;
    }
}

class AnimationSlotSelectors {
    public static function pathSelector(path:Array<Int>, aph:AnimationPlaceholder) {
        return aph.entity.getGrandchild(path).getComponent(AnimationPlaceholder);
    }
}

interface Channels {
    var channels(default, null):Array<Float->Void>;
}

class AnimationTreeBinder implements CtxBinder {
    var container:AnimContainer;

    public function new(container) {
        this.container = container;
    }

    public function bind(e:Entity) {
        var acomp = e.getComponent(AnimationTreeComponent);
        if (acomp != null) {
            AnimationTreeBuilder.addChild(container, acomp.tree);
            container.refresh();
        }
    }

    public function unbind(e:Entity) {
        var acomp = e.getComponent(AnimationTreeComponent);
        if (acomp != null) {
            AnimationTreeBuilder.removeChild(container, acomp.tree);
            container.refresh();
        }
    }
}

class AnimationTreeComponent extends Component {
    public var tree(default, null):AnimationPlaceholder; // can be constructed at place and binded to parent w Ctx

    var target:Channels;
    var alias:String;
    @:once var props:PropStorage<AnimationPreset>;
    @:once var builder:AnimationTreeBuilder;

    public function new(e, target, alias = "") {
        this.target = target;
        this.alias = alias;
        super(e);
    }

    override function init() {
        var preset = props.get(getId(target, alias));
        tree = builder.build(preset.treeDesc);
        for (i in 0...target.channels.length)
            preset.mapping[i](tree).channels.push(target.channels[i]);
        new CtxWatcher(AnimationTreeBinder, entity);
    }

    public function setTime(t):Void {
        if (_inited)
            tree.setTime(t);
    }

    public static function getId(instance:Dynamic, alias = "") {
        return Entity.getComponentId(instance) + "_" + alias;
    }
}
