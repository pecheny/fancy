package htext;

import gl.Renderable;
import gl.AttribSet;

interface ITextRender<T:AttribSet> extends Renderable<T> extends ITextConsumer {}

interface ITextConsumer {
    function setText(s:String):Void;
    function setDirty():Void;
}
