package com.tilbuci.ui.base;

/** FEATHERS UI **/
import feathers.skins.RectangleSkin;

/**
    Default interface background skin.
**/
class BackgroundSkin extends RectangleSkin {

    public function new(color:Int = 0x666666) {
        super();
        this.fill = SolidColor(color);
    }

}