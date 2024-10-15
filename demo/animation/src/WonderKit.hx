package;

import al.animation.AnimationTreeComponent;
import ec.Entity;
import fu.PropStorage;
import widgets.WonderButton;

class WonderKit {
    public static function configure(e:Entity) {
        var props = new DummyProps<AnimationPreset>();
        var preset = new AnimationPreset({
            layout: "portion",
            children: [{size: {value: .4}}, {size: {value: 1.}},]
        });
        preset.mapping.push(AnimationSlotSelectors.pathMapper.bind([0]));
        preset.mapping.push(AnimationSlotSelectors.pathMapper.bind([1]));
        preset.mapping.push(AnimationSlotSelectors.pathMapper.bind([1]));
        props.set(AnimationTreeComponent.getId(WonderButton), preset);
        e.addComponentByType(PropStorage, props);
    }
}
