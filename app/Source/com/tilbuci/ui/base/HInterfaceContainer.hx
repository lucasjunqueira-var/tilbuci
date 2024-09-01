package com.tilbuci.ui.base;

/** FEATHERS UI **/
import feathers.layout.VerticalLayout;
import feathers.controls.HDividedBox;
import feathers.core.ValidatingSprite;

class HInterfaceContainer extends HDividedBox {

    /**
        Constructor.
    **/
    public function new() {
        super();
    }

    /**
        Replaces the current children by a list of new ones.
    **/
    public function replaceChildren(newOnes:Array<ValidatingSprite>):Void {
        this.removeChildren();
        for (n in 0...newOnes.length) {
            this.addChild(newOnes[n]);
        }
    }

}