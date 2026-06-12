package dkit;

import Axis2D;
import a2d.ContainerStyler;
import a2d.Placeholder2D;
import a2d.Stage;
import a2d.Widget.ResizableWidget2D;
import a2d.Widget2DContainer;
import al.appliers.ContainerRefresher;
import al.core.AxisApplier.DynApp;
import al.core.DataView;
import al.core.TWidget;
import al.ec.WidgetSwitcher;
import al.layouts.AxisLayout;
import al.layouts.WholefillLayout;
import ec.Entity;
import fu.Signal.IntSignal;
import fu.ui.ButtonBase;
import openfl.display.DisplayObject;

using a2d.ProxyWidgetTransform;

class Dkit {
    public static inline var TEXT_COLOR = "TEXT_COLOR";
    public static inline var TEXT_STYLE = "TEXT_STYLE";
}

@:uiComp("base")
@:postInit(initDkit)
#if (!macro && !completion && !display)
@:autoBuild(dkit.Macros.DefaultConstructorBuilder.build())
#end
class BaseDkit implements domkit.Model<BaseDkit> implements domkit.Object implements IWidget<Axis2D> {
    public var ph(get, null):Placeholder2D;
    public var entity(get, null):Entity;
    public var c:Widget2DContainer;
    public var fui(get, null):FuiBuilder;
    public var onConstruct:(Placeholder2D) -> Void;

    var hl:AxisLayout = WholefillLayout.instance;
    var vl:AxisLayout = WholefillLayout.instance;
    var scroll = false;
    @:isVar var layouts(default, set):String = "";

    static var _fui:FuiBuilder;

    @:once var containerStyler:ContainerStyler;

    public static function inject(fui) {
        _fui = fui;
    }

    var children:Array<BaseDkit> = [];

    public var dom:domkit.Properties<BaseDkit>;
    public var parent:BaseDkit;

    public function getChildren()
        return children;

    public function new(p:a2d.Placeholder2D, ?parent:dkit.Dkit.BaseDkit) {
        if (p == null)
            this.ph = b().b();
        else
            this.ph = p;

        if (parent != null) {
            this.fui = parent.fui;
            this.parent = parent;
            parent.children.push(this);
        } else if (fui != null)
            this.fui = fui;

        initComponent();
        watch(entity);
    }

    function scrollboxRequired() {
        return scroll;
    }

    function containerRequired() {
        if (children.length > 0)
            return true;
        if (layouts != "")
            return true;
        if (vl != WholefillLayout.instance)
            return true;
        if (hl != WholefillLayout.instance)
            return true;
        return false;
    }

    var dkitInited = false;

    public function initDkit() {
        if (dkitInited)
            return;
        dkitInited = true;

        if (onConstruct != null)
            onConstruct(ph);
        if (scrollboxRequired()) {
            var content = ph.entity.getComponent(ResizableWidget2D);
            if (content == null) {
                c = al.Builder.createContainer(b().b(), horizontal, Center);
                fui.makeClickInput(c.ph, ph);
                setLayouts();
                fui.uikit.createScrollbox(c, ph);
                for (ch in children) {
                    c.addChild(ch.ph);
                    c.entity.addChild(ch.ph.entity);
                }
            } else {
                // the case with custom resizables works but not well
                // tested with label, works with incorrect offset
                fui.uikit.createScrollbox(content, ph);
            }
        } else if (containerRequired()) {
            c = ph.entity.getComponent(Widget2DContainer);
            if (c == null) {
                c = new Widget2DContainer(ph.getInnerPh(), 2);
                ph.entity.addComponent(c);
                setLayouts();
            }
            for (a in Axis2D) {
                ph.getInnerPh().axisStates[a].addSibling(new ContainerRefresher(c));
            }
            for (ch in children) {
                if (Std.is(ch, OrphansDkit))
                    continue;
                c.addChild(ch.ph);
                c.entity.addChild(ch.ph.entity);
            }
        }
        entity.dispatchContext();
    }

    function setLayouts() {
        if (c == null)
            return;
        if (containerStyler != null && layouts != "") {
            containerStyler.stylize(c, layouts);
        } else {
            c.setLayout(horizontal, hl);
            c.setLayout(vertical, vl);
        }
        c.refresh();
    }

    public function init() {
        if (layouts != "")
            setLayouts();
    }

    function b() {
        return fui.placeholderBuilder;
    }

    function get_fui():FuiBuilder {
        return _fui;
    }

    function get_ph():Placeholder2D {
        return ph;
    }

    function get_entity():Entity {
        return ph.entity;
    }

    function set_layouts(value:String):String {
        layouts = value;
        setLayouts();
        return value;
    }

    // required by domkit.
    public function getChildRefPosition(first:Bool):Int {
        throw new haxe.exceptions.NotImplementedException();
    }
}

@:uiComp("data-container")
@:postInit(initDkit)
class DataContainerDkit<TData, T:IWidget<Axis2D> & DataView<TData>> extends BaseDkit implements DataView<Array<TData>> {
    static var SRC = <data-container></data-container>

    var pool:a2d.ChildrenPool.DataChildrenPool<Dynamic, Dynamic>;
    var data:Array<TData>;

    public var onChoice(default, null):IntSignal;
    public var dispatch:Bool;

    public dynamic function itemFactory():T {
        return null;
    }

    public dynamic function inputFactory(ph:Placeholder2D, n:Int) {
        if (dispatch) {
            new ButtonBase(ph, onChoice.dispatch.bind(n));
        }
    }

    override function containerRequired():Bool {
        return true;
    }

    override function initDkit() {
        super.initDkit();
        if (dispatch)
            onChoice = new IntSignal();
        pool = new fu.ui.InteractivePanelBuilder().withContainer(c)
            .withWidget(() -> itemFactory())
            .withInput(inputFactory)
            .build();
        if (data != null)
            initData(data);
    }

    public function initData(descr:Array<TData>):Void {
        data = descr;
        pool?.initData(descr);
    }

    public function getItems() {
        return pool.pool;
    }
}

@:uiComp("switcher")
@:postInit(initDkit)
class SwitcherDkit extends BaseDkit {
    public var switcher(default, null):WidgetSwitcher<Axis2D>;

    override function initDkit() {
        switcher = new WidgetSwitcher(ph.getInnerPh());
    }

    public function switchTo(ph) {
        switcher.switchTo(ph);
    }

    override function containerRequired():Bool {
        return false;
    }
}

@:uiComp("orphans")
class OrphansDkit extends BaseDkit {
    public function new(?parent) {
        super(null, parent);
        initComponent();
    }

    override function containerRequired():Bool {
        // in fact it is not reauired for now since there is no @:postInit and initDkit() would not called from markup
        // leave it for a case of ridding of manual initDkit() setup for components.
        return false;
    }
}

#if swf
@:uiComp("swf")
@:postInit(initDkit)
class SwfDkit extends BaseDkit {
    public var lib:String = "swf";
    public var name:String;
    public var mc(default, null):openfl.display.MovieClip;
    public var mode:backends.openfl.SpriteAspectKeeper.ScaleMode = fit;
    public var hideOverflow:Bool = false;
    var ak:backends.openfl.SpriteAspectKeeper;
    @:once var s:Stage;
    var boundBindingd:Array<{ph:Placeholder2D, dobj:DisplayObject}> = [];
    override function initDkit() {
        mc = openfl.utils.Assets.getMovieClip('$lib:$name');
        mc.name = name;
        ak = new backends.openfl.SpriteAspectKeeper(ph, mc, null, mode, hideOverflow);
        for (ch in children) {
            entity.addChild(ch.ph.entity);
            var chdo = mc.getChildByName(ch.entity.name);
            if (chdo != null)
                boundBindingd.push({ph: ch.ph, dobj: chdo});
        }
        if (boundBindingd.length > 0)
            ph.axisStates[vertical].addSibling(new DynApp(refresh));
    }

    function refresh() {
        if (@:privateAccess !ak._inited)
            return;
        var p1 = new flash.geom.Point();
        var p2 = new flash.geom.Point();
        var p3 = new flash.geom.Point();
        for (b in boundBindingd) {
            p1.setTo(b.dobj.x, b.dobj.y);
            mc.transform.matrix.transformPointToOutput(p1, p2);
            p1.setTo(b.dobj.width, b.dobj.height);
            mc.transform.matrix.transformPointToOutput(p1, p3);
            b.ph.axisStates[horizontal].apply(do2ph(horizontal, p2.x), do2ph(horizontal, p3.x - mc.x));
            b.ph.axisStates[vertical].apply(do2ph(vertical, p2.y), do2ph(vertical, p3.y - mc.y));
        }
    }

    public inline function do2ph(a, val:Float) {
        return val / s.getWindowSize()[a] * s.getAspectRatio()[a] * 2;
    }
}
#end
