/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package com.tilbuci.statictools;

// OpenFL
import openfl.display.Sprite;

// Actuate
import motion.Actuate;
import motion.easing.Quad;

/**
    String-related static tools.
**/
class SpriteStatic
{
    public static function shake(target:Sprite, duration:Float, intensity:Float):Void {
        var originalX = target.x;
        var originalY = target.y;
        Actuate.timer(duration).onUpdate(function() {
            target.x = originalX + (Math.random() * intensity * 2 - intensity);
            target.y = originalY + (Math.random() * intensity * 2 - intensity);
        }).onComplete(function() {
            target.x = originalX;
            target.y = originalY;
        });
    }

    public static function quickJump(target:Sprite, duration:Float, intensity:Float):Void {
        var originalY = target.y;
        Actuate.tween(target, duration/2, { y: originalY - intensity })
            .ease(Quad.easeOut)
            .onComplete(function() {
                Actuate.tween(target, duration/2, { y: originalY })
                    .ease(Quad.easeIn);
            });
    }
}