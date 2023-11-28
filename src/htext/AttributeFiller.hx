package htext;

import haxe.io.Bytes;

interface AttributeFiller {
    function write(target:Bytes, startVert:Int):Void;
}

class AttFillContainer implements AttributeFiller {
    var children:Array<AttributeFiller> = [];

    public function new() {}

    public function addChild(ch:AttributeFiller) {
        children.push(ch);
    }

    public function write(target:Bytes, startVert:Int) {
        for (ch in children)
            ch.write(target, startVert);
    }
}
