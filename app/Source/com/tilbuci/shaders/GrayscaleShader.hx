package com.tilbuci.shaders;

import openfl.display.Shader;
import openfl.display.GraphicsShader;

class GrayscaleShader extends GraphicsShader
{
	
	@:glFragmentSource(
		"#pragma header
		void main(void) {
			gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
			float sum = (gl_FragColor.r + gl_FragColor.g + gl_FragColor.b) / 3.0;
			gl_FragColor = vec4(sum, sum, sum, gl_FragColor.a);
			gl_FragColor = gl_FragColor * openfl_Alphav;
		}"
	)
	
	public function new()
	{
		super();
	}
}