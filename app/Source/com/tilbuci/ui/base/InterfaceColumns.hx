package com.tilbuci.ui.base;

/** FEATHERS UI **/
import feathers.controls.HDividedBox;
import feathers.controls.VDividedBox;
import feathers.layout.AnchorLayoutData;
import feathers.skins.RectangleSkin;

/** TILBUCI **/
import com.tilbuci.ui.base.InterfaceContainer;

class InterfaceColumns extends VDividedBox {

    /**
        left column
    **/
    public var left:InterfaceContainer;

    /**
        right column
    **/
    public var right:InterfaceContainer;

    /**
        bottom area
    **/
    public var bottom:InterfaceContainer;

    /**
        Constructor.
    **/
    public function new(lf:InterfaceContainer, rt:InterfaceContainer, bt:InterfaceContainer = null, ht:Float = 0) {
        super();
        this.layoutData = AnchorLayoutData.fill();

        var bgSkin:RectangleSkin = new RectangleSkin();
        bgSkin.fill = SolidColor(0x666666);
        this.backgroundSkin = bgSkin;

        var cols:HDividedBox = new HDividedBox();
        cols.layoutData = AnchorLayoutData.fill();
        cols.backgroundSkin = bgSkin;

        this.left = lf;
        this.right = rt;
        cols.addChild(this.left);
        cols.addChild(this.right);
        this.addChild(cols);

        if (bt != null) {
            this.bottom = bt;
            this.bottom.backgroundSkin = bgSkin;
            this.addChild(this.bottom);
            if (ht > 0) cols.minHeight = ht;
        }
    }

}