/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package;

import openfl.display.BitmapData;
import openfl.events.ProgressEvent;
import openfl.events.Event;
import openfl.display.Sprite;
import com.tilbuci.statictools.Assets;

/**
    Preloader screen displayed while assets are loading.
    Shows a gray background with a black progress rectangle that expands as loading progresses.
**/
class Preloader extends Sprite {

    private var _ast:Assets;

    /**
        Constructs the preloader and sets up the initial gray background.
        Registers event listeners for loading progress and completion.
    **/
    public function new() {
        super();

        this._ast = new Assets();
        this._ast.addEventListener(Event.CHANGE, onAstChange);
        this._ast.addEventListener(Event.COMPLETE, onAstComplete);

        if (this.stage != null) {
            this.graphics.beginFill(0x666666);
            this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
            this.graphics.endFill();
        }

        this.addEventListener(Event.COMPLETE, this.onComplete);
        this.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
    }

    /**
        Called when loading progress updates.
        Draws a black rectangle that grows proportionally to the loading progress.
        @param evt ProgressEvent containing bytesLoaded and bytesTotal.
    **/
    private function onProgress(evt:ProgressEvent):Void {
        /*if (this.stage != null) {
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
        }*/
    }

    /**
        Called when loading is complete.
        Clears the preloader graphics and dispatches an UNLOAD event.
        @param evt The COMPLETE event.
    **/
    private function onComplete(evt:Event):Void {
        evt.stopImmediatePropagation();
        evt.preventDefault();
    }

    private function onAstChange(evt:Event):Void {
        if (this.stage != null) {
            this.graphics.clear();
            this.graphics.beginFill(0x666666);
            this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
            this.graphics.endFill();
            var wd:Float = this.stage.stageWidth * (this._ast.complete / 100);
            var ht:Float = this.stage.stageHeight * (this._ast.complete / 100);
            this.graphics.beginFill(0x000000);
            this.graphics.drawRect(((this.stage.stageWidth/2) - (wd/2)), ((this.stage.stageHeight/2) - (ht/2)), wd, ht);
            this.graphics.endFill();
        }
    }

    private function onAstComplete(evt:Event):Void {
        this._ast.removeEventListener(Event.CHANGE, onAstChange);
        this._ast.removeEventListener(Event.COMPLETE, onAstComplete);
        this._ast = null;
        this.graphics.clear();
        evt.preventDefault();
        this.dispatchEvent(new Event(Event.UNLOAD));
    }

}