package com.tilbuci.ui.base;

/** FEATHERS UI **/
import feathers.controls.LayoutGroup;
import feathers.controls.ScrollContainer;
import openfl.display.Sprite;
import feathers.layout.AnchorLayout;
import feathers.layout.HorizontalLayout;
import feathers.controls.Panel;
import feathers.core.ValidatingSprite;
import feathers.layout.AutoSizeMode;

class HPanelContainer extends LayoutGroup {

    /**
        Constructor.
    **/
    public function new() {
        super();
        var lay = new HorizontalLayout();
        lay.gap = 10;
        this.layout = lay;
    }

    /**
        Replaces the current children by a list of new ones.
    **/
    public function replaceChildren(newOnes:Array<ValidatingSprite>):Void {
        var wd:Float = this.width;
        this.removeChildren();
        for (n in 0...newOnes.length) {
            this.addChild(newOnes[n]);
        }
        this.setWidth(Math.round(wd));
    }

    public function setWidth(wd:Int):Void {
        //this.width = wd;
        if (this.numChildren > 0) {
            var each:Float = (wd - ((this.numChildren - 1) * 10)) / this.numChildren;

trace ('wd', wd, 'each', each);

            for (i in 0...this.numChildren) {
                this.getChildAt(i).width = each;
                trace ('set', this.getChildAt(i), this.getChildAt(i).width);
            }
        }
        //this.width = wd;
    }

}