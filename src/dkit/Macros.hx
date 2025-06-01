package dkit;

import fu.macros.FieldUtils;
import haxe.macro.Expr.Field;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;

class DefaultConstructorBuilder {
    static var template = macro class Templ {
        var _dkit_called = false;

        function _initDkit() {
            if(_dkit_called)
                return;
            _dkit_called = true;
            initDkit();
        }

        public function new(p:a2d.Placeholder2D, ?parent:dkit.Dkit.BaseDkit) {
            super(p, parent);
            initComponent();
            if (parent == null)
                _initDkit();
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
                        exprs.push(macro if (parent == null) _initDkit());
                    case _:
                        throw "Incompatible constructor";
                }
                break;
            }
        }
        for (f in template.fields)
            if (!FieldUtils.hasField(f.name))
                fields.push(f);
        // if (required)
        //     fields = fields.concat(template.fields);

        return fields;
    }
}
