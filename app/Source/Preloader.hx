/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package;

import openfl.events.ProgressEvent;
import openfl.events.Event;
import openfl.display.Sprite;

class Preloader extends Sprite {

    public function new() {
        super();
        if (this.stage != null) {
            this.graphics.beginFill(0x666666);
            this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
            this.graphics.endFill();
        }

        this.addEventListener(Event.COMPLETE, this.onComplete);
        this.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
    }

    private function onProgress(evt:ProgressEvent):Void {
        if (this.stage != null) {
            this.graphics.clear();
            this.graphics.beginFill(0x666666);
            this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
            this.graphics.endFill();
            if (evt.bytesTotal > 0) {
                var wd:Float = this.stage.stageWidth * (evt.bytesLoaded / evt.bytesTotal);
                var ht:Float = this.stage.stageHeight * (evt.bytesLoaded / evt.bytesTotal);
                this.graphics.beginFill(0x000000);
                this.graphics.drawRect(((this.stage.stageWidth/2) - (wd/2)), ((this.stage.stageHeight/2) - (ht/2)), wd, ht);
                this.graphics.endFill();
            }
        }
    }

    private function onComplete(evt:Event):Void {
        this.graphics.clear();
        evt.preventDefault();
        this.dispatchEvent(new Event(Event.UNLOAD));
    }

}