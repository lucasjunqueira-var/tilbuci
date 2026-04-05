package com.tilbuci.shaders;

import openfl.display.Shader;
import openfl.display.GraphicsShader;

class DeuteranopiaShader extends GraphicsShader
{
	@:glFragmentSource(
		"#pragma header
		void main(void) {
			vec4 color = texture2D(bitmap, openfl_TextureCoordv);
			mat3 deuteranopiaCorrection = mat3(
				0.625, 0.375, 0.0,
				0.7,   0.3,   0.0,
				0.0,   0.3,   0.7 
			);
			vec3 corrected = deuteranopiaCorrection * color.rgb;
			gl_FragColor = vec4(corrected, color.a);
			gl_FragColor = gl_FragColor * openfl_Alphav;
		}"
	)
	
	public function new()
	{
		super();
	}
}