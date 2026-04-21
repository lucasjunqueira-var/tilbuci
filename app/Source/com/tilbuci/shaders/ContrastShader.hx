package com.tilbuci.shaders;

import openfl.display.Shader;
import openfl.display.GraphicsShader;

class ContrastShader extends GraphicsShader
{
	@:glFragmentSource(
		"#pragma header
		void main(void) {
			vec4 color = texture2D(bitmap, openfl_TextureCoordv);
			float contrast = 1.5;
			vec3 contrasted = ((color.rgb - 0.5) * contrast) + 0.5;
			gl_FragColor = vec4(contrasted, color.a);
			gl_FragColor = gl_FragColor * openfl_Alphav;
		}"
	)
	
	public function new()
	{
		super();
	}
}