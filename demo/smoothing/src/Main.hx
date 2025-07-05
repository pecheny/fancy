package;

import fu.ui.CMSDFLabel;
import dkit.Dkit;

import data.IndexCollection;
import haxe.io.Bytes;
import gl.passes.CirclePass;
import FuiBuilder;
import a2d.Placeholder2D;
import al.ec.WidgetSwitcher;
import data.aliases.AttribAliases;
import ec.Entity;
import fu.graphics.ShapeWidget;
import gl.sets.CircleSet;
import graphics.shapes.QuadGraphicElement;
import graphics.shapes.Shape;
import openfl.display.Sprite;

using a2d.transform.LiquidTransformer;
using al.Builder;

class Main extends Sprite {
    public var fui:FuiBuilder;
    public var switcher:WidgetSwitcher<Axis2D>;
    var label:CMSDFLabel;
    var text = '
    <font face="24-2">Font 24, dfSize 2 <font scale="0.12">small text</font></font><br />
    <font face="24-8">Font 24, dfSize 8 <font scale="0.12">small text</font></font>
    ';

    var e:Entity;

    public function new() {
        super();
        fui = new FuiBuilder();
        BaseDkit.inject(fui);
        var root:Entity = fui.createDefaultRoot();
        root.addComponent(new al.openfl.display.FlashDisplayRoot(this));

        var uikit = new JiUikit(fui);
        uikit.configure(root);
        uikit.createContainer(root);
        
        var fitStyle = fui.textStyles.newStyle("fit")
        .withSize(sfr, .25)
        .withAlign(horizontal, Forward)
        .withAlign(vertical, Center)
        .withPadding(horizontal, pfr, 0.33)
        .withPadding(vertical, pfr, 0.33)
        .build();

        label = new CMSDFLabel(Builder.widget(), fui.textStyles.getStyle("fit"));
        label.withText(text);

        switcher = root.getComponent(WidgetSwitcher);
        root.getComponent(WidgetSwitcher).switchTo(label.ph);
    }

   
}