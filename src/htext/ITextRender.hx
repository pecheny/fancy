package htext;

import gl.Renderable;
import gl.AttribSet;

interface ITextRender<T:AttribSet> extends Renderable<T> extends ITextConsumer {}

enum abstract Dirty(Int) to Int {
    // No changes, cached buffer can be used
    var none = 0;
    // For baking option, use cached local-space position, but reapply widget transform
    var transform = 1;
    // Call text relayout with htext on next render call
    var full = 2;
    // Immediately relayout text
    var force = 3;

    @:op(A >= B) static function gt(a:Dirty, b:Dirty):Bool;
}

interface ITextConsumer {
    function setText(s:String):Void;
    function setDirty(level:Dirty):Void;
}
