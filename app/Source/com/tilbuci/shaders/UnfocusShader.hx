package com.tilbuci.shaders;

import openfl.display.Shader;
import openfl.display.GraphicsShader;

class UnfocusShader extends GraphicsShader
{
	@:glFragmentSource(
		"#pragma header
		vec3 reduceSaturation(vec3 color, float factor) {
			float gray = dot(color, vec3(0.299, 0.587, 0.114));
			return mix(vec3(gray), color, factor);
		}
		void main(void) {
			vec2 uv = openfl_TextureCoordv;
			vec4 baseColor = texture2D(bitmap, uv);
			float offset = 1.0 / 512.0;
			vec4 blurColor = baseColor;
			blurColor += texture2D(bitmap, uv + vec2(offset, 0.0));
			blurColor += texture2D(bitmap, uv - vec2(offset, 0.0));
			blurColor += texture2D(bitmap, uv + vec2(0.0, offset));
			blurColor += texture2D(bitmap, uv - vec2(0.0, offset));
			blurColor /= 5.0;
			vec3 desaturated = reduceSaturation(blurColor.rgb, 0.15);
			gl_FragColor = vec4(desaturated, blurColor.a);
			gl_FragColor *= openfl_Alphav;
		}"
	)
	
	public function new()
	{
		super();
	}
}