package com.tilbuci.ui.base;

/** FEATHERS UI **/
import feathers.layout.AnchorLayout;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalLayout;
import feathers.controls.HDividedBox;
import feathers.core.ValidatingSprite;
import feathers.controls.supportClasses.BaseDividedBox;

//class HInterfaceContainer extends HDividedBox {
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

    /**
        Sets the container width.
        @param  wd  the new width
        @param  indv    individual widths for children
    **/
    public function setWidth(wd:Int, indv:Array<Int> = null):Void {
        this.width = wd;
        if (this.numChildren > 0) {
            if ((indv != null) && (indv.length == this.numChildren)) {
                for (i in 0...indv.length) {
                    this.getChildAt(i).width = indv[i];
                }
            } else {
                var each:Float = (wd - ((this.numChildren - 1) * 10)) / this.numChildren;
                for (i in 0...this.numChildren) {
                    this.getChildAt(i).width = each;
                }
            }
        }
    }

}