package;

import openfl.events.Event;
import openfl.display3D.Context3D;
import bindings.RenderEvent;
import Gui;
import al.ec.WidgetSwitcher;
import backends.openfl.OpenflBackend.StageImpl;
// import bindings.GL;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import openfl.display.Sprite;
import openfl.display3D.Context3DCompareMode;

// import openfl.events.RenderEvent;
using a2d.ProxyWidgetTransform;
using a2d.transform.LiquidTransformer;
using al.Builder;

class Demo extends Sprite {
    var ctx:Context3D;

    public function new() {
        super();

        addEventListener(openfl.events.RenderEvent.RENDER_OPENGL, onRender);
        // addEventListener(openfl.events.Event.ENTERFRAME, onEnterFrame);
        var stage = new StageImpl(1);
        var fui = new FuiBuilder(stage, new FlatDepthUikit(stage));

        BaseDkit.inject(fui);
        var root:Entity = fui.createDefaultRoot();

        fui.uikit.configure(root);
        fui.uikit.createContainer(root);
        fui.configureDisplayRoot(root, this);
        var switcher = root.getComponent(WidgetSwitcher);

        var wdg = Builder.widget();

        var gui = new Cont(wdg);
        gui.dc.initData(["foo", "bar", "baz", "buz", "foo", "bar", "baz", "buz"]);
        switcher.switchTo(wdg);

        ctx = this.stage.context3D;
        // this.stage.addEventListener(Event.RESIZE, (e) -> {
        //     trace("r");
        //     // this.stage.context3D.configureBackBuffer(this.stage.stageWidth, this.stage.stageHeight, 4, true);
        // });

        var spr = new Sprite();

        spr.graphics.beginFill(0x772A3075);
        spr.graphics.drawRect(400, 0, 300, 1600);
        // spr.graphics.drawRect(-0.9, -0.5, 2, 1);
        spr.graphics.endFill();

        @:privateAccess spr.__transform.tz = 0.5;
        // var tr = @:privateAccess spr.__transform;
        // tr.tz = 0.5;
        // spr.transform.matrix = matrix;

        spr.name = "SPR";
        addChild(spr);
        var td = new TestDisplay();
        td.name = "td";
        addChild(td);
    }

    var intd = false;

    function onRender(event) {
        // trace(@:privateAccess this.stage.context3D.__state.depthCompareMode);

        this.stage.context3D.setDepthTest(true, Context3DCompareMode.GREATER_EQUAL);
        // trace(ctx == this.stage.context3D);
        if (intd)
            return;
        intd = true;
        // var depthBits = GL.getInteger(GL.DEPTHBITS);
        // trace("depthBits ", depthBits);

        // var objectType = GL.getFramebufferAttachmentParameteriv(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE);
        // if (objectType == GL.RENDERBUFFER) {
        //     trace("A Renderbuffer is attached");
        // } else if (objectType == GL.TEXTURE) {
        //     trace("A Depth Texture is attached");
        // } else if (objectType == GL.NONE) {
        //     trace("no");
        // }

        // var renderer:openfl.display.OpenGLRenderer = cast event.renderer;
        // GL.clearColor(0.2, 0.3, 0.3, 1.0);
        // GL.enable(GL.DEPTH_TEST);
        // stage.context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, true);
        // GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
        // GL.depthFunc(GL.NEVER);
        // trace(GL);
    }
}
