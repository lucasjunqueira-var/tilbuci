/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package com.tilbuci.statictools;

// OpenFL
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

// Actuate
import motion.Actuate;
import motion.easing.Quad;

/**
    String-related static tools.
**/
class SpriteStatic
{
    public static function shake(target:Sprite, duration:Float, intensity:Float, end:Dynamic = null):Void {
        var originalX = target.x;
        var originalY = target.y;
        Actuate.timer(duration).onUpdate(function() {
            target.x = originalX + (Math.random() * intensity * 2 - intensity);
            target.y = originalY + (Math.random() * intensity * 2 - intensity);
        }).onComplete(function() {
            target.x = originalX;
            target.y = originalY;
            if (end != null) {
                GlobalPlayer.parser.run(end, true);
            }
        });
    }

    public static function quickJump(target:Sprite, duration:Float, intensity:Float, end:Dynamic = null):Void {
        var originalY = target.y;
        Actuate.tween(target, duration/2, { y: originalY - intensity })
            .ease(Quad.easeOut)
            .onComplete(function() {
                Actuate.tween(target, duration/2, { y: originalY })
                    .ease(Quad.easeIn)
                    .onComplete(function() {
                        if (end != null) {
                            GlobalPlayer.parser.run(end, true);
                        }
                    });
            });
    }

    public static function pulse(target:Sprite, duration:Float, intensity:Float, iteractions:Int, end:Dynamic = null):Void {
        var originalScaleX = target.scaleX;
        var originalScaleY = target.scaleY;
        var originalX = target.x;
        var originalY = target.y;
        var newX = target.x - (((target.width * intensity) - target.width) / 2);
        var newY = target.y - (((target.height * intensity) - target.height) / 2);
        var zoomIn:Void->Void = null;
        var zoomOut:Void->Void = null;
        var remaining:Int = iteractions;
        duration = duration / (2 * iteractions);
        zoomIn = function() {
            if (remaining > 0) {
                remaining--;
                Actuate.tween(target, duration, { scaleX: intensity, scaleY: intensity, x: newX, y: newY })
                .ease(Quad.easeOut)
                .onComplete(zoomOut);
            } else {
                if (end != null) {
                    GlobalPlayer.parser.run(end, true);
                }
            }
        }
        zoomOut = function () {
            Actuate.tween(target, duration, { scaleX: originalScaleX, scaleY: originalScaleY, x: originalX, y: originalY })
                .ease(Quad.easeIn)
                .onComplete(zoomIn);
        }
        zoomIn();
    }
}