package dkit;

import haxe.macro.Expr.Field;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;

class DefaultConstructorBuilder {
    static var template = macro class Templ {
        public function new(p:a2d.Placeholder2D, ?parent:dkit.Dkit.BaseDkit) {
            super(p, parent);
            initComponent();
            if (parent == null)
                initDkit();
        }
    };

    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var required = true;
        for (f in fields) {
            if (f.name == 'new') {
                required = false;
                switch f.kind {
                    case FFun({expr: {expr: EBlock(exprs)}}):
                        exprs.push(macro if (parent == null) initDkit());
                    case _:
                        throw "Incompatible constructor";
                }
                break;
            }
        }
        if (required)
            fields.push(template.fields[0]);

        return fields;
    }
}
