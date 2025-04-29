package dkit;

import al.ec.WidgetSwitcher;
import fu.ui.ButtonBase;
import al.core.DataView;
import fu.Signal.IntSignal;
import a2d.ContainerStyler;
import a2d.Placeholder2D;
import a2d.Widget2DContainer;
import al.appliers.ContainerRefresher;
import al.core.TWidget;
import al.layouts.AxisLayout;
import al.layouts.WholefillLayout;
import al.layouts.PortionLayout;
import ec.Entity;

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

    function _init(e:Entity) {}

    inline function containerRequired() {
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
        if (containerRequired()) {
            c = new Widget2DContainer(ph.getInnerPh(), 2);
            for (a in Axis2D) {
                ph.getInnerPh().axisStates[a].addSibling(new ContainerRefresher(c));
            }
            setLayouts();
            ph.entity.addComponent(c);
            for (ch in children) {
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

    public function getChildRefPosition(first:Bool):Int {
        throw new haxe.exceptions.NotImplementedException();
    }
}

@:uiComp("data-container")
@:postInit(initDkit)
class DataContainerDkit extends BaseDkit implements DataView<Array<String>> {
    static var SRC = <data-container vl={PortionLayout.instance}></data-container>

    var pool:a2d.ChildrenPool.DataChildrenPool<Dynamic, Dynamic>;

    public var onChoice(default, null):IntSignal;
    public var dispatch:Bool;

    public dynamic function itemFactory():Dynamic {
        return null;
    }

    public dynamic function inputFactory(ph:Placeholder2D, n:Int) {
        if (dispatch) {
            new ButtonBase(ph, onChoice.dispatch.bind(n));
        }
    }

    override function initDkit() {
        super.initDkit();
        if (dispatch)
            onChoice = new IntSignal();
        pool = new fu.ui.InteractivePanelBuilder().withContainer(c)
            .withWidget(() -> itemFactory())
            .withInput(inputFactory)
            .build();
    }

    public function initData(descr):Void {
        pool.initData(descr);
    }

    public function getItems() {
        return pool.pool;
    }
}

@:uiComp("switcher")
@:postInit(initDkit)
class SwitcherDkit extends BaseDkit {
    var switcher:WidgetSwitcher<Axis2D>;

    override function initDkit() {
        switcher = new WidgetSwitcher(ph.getInnerPh());
    }
    
    public function switchTo(ph) {
        switcher.switchTo(ph);
    }
}
