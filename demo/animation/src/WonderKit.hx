package;

import al.animation.AnimationTree;
import ec.Entity;
import fu.PropStorage;
import widgets.WonderButton;
import utils.MacroGenericAliasConverter as MGA;
class WonderKit {
    public static function configure(e:Entity) {
        var props = new DummyProps<AnimationPreset>();
        var preset = new AnimationPreset({
            layout: "offset",
            name: "wonderbutton",
            children: [{size: {value: 1.}, name: "dot4"}, {size: {value: 1.}, name: "1dot"}]
        });
        preset.mapping.push(AnimationSlotSelectors.pathMapper.bind([0]));
        preset.mapping.push(AnimationSlotSelectors.pathMapper.bind([1]));
        preset.mapping.push(AnimationSlotSelectors.pathMapper.bind([1]));
        props.set(AnimationPreset.getId(WonderButton), preset);
        e.addComponentByName(MGA.toAlias(PropStorage, AnimationPreset), props);
    }
}
