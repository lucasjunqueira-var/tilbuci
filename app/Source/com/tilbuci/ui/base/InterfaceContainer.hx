/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.base;

/** FEATHERS UI **/
import feathers.skins.RectangleSkin;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalLayout;
import feathers.controls.ScrollContainer;
import feathers.core.ValidatingSprite;


class InterfaceContainer extends ScrollContainer {

    /**
        Constructor.
    **/
    public function new(lay:String = '', gap:Int = -1, bgcolor:Int = -1, border:Int = -1) {
        super();
        // layout?
        if (lay == 'v') {
            var lay:VerticalLayout = new VerticalLayout();
            if (gap > 0) {
                lay.gap = gap;
                lay.setPadding(gap);
            } else if (gap == 0) {
                lay.gap = 10;
                lay.setPadding(0); 
            }
            this.layout = lay;
        } else if (lay == 'h') {
            var lay:HorizontalLayout = new HorizontalLayout();
            if (gap > 0) {
                lay.gap = gap;
                lay.setPadding(gap);
            }
            this.layout = lay;
        }
        // background?
        if (bgcolor >= 0) {
            var skin:RectangleSkin = new RectangleSkin();
            skin.fill = SolidColor(bgcolor);
            if (border >= 0) {
                skin.border = SolidColor(1, border);
            }
            this.backgroundSkin = skin;
        }
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