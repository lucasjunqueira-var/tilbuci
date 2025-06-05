/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.narrative;

import com.tilbuci.player.MovieArea;
import openfl.events.MouseEvent;
import com.tilbuci.display.InstanceImage;
import com.tilbuci.display.VideoImage;
import com.tilbuci.display.PictureImage;
import com.tilbuci.display.SpritemapImage;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class Narrative {

    // characters
    public var chars:Map<String, CharacterNarrative> = [ ];

    public function new() {

    }

    public function clear():Void {
        for (k in this.chars.keys()) {
            this.chars[k].kill();
            this.chars.remove(k);
        }
    }

    public function getData():String {
        var data:Map<String, Array<Dynamic>> = [ ];
        data['chars'] = new Array<Dynamic>();
        for (k in this.chars) {
            data['chars'].push(k.toObject());
        }
        return(StringStatic.jsonStringify(data));
    }

}