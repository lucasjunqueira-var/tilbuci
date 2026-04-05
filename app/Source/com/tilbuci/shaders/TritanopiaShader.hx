package com.tilbuci.shaders;

import openfl.display.Shader;
import openfl.display.GraphicsShader;

class TritanopiaShader extends GraphicsShader
{
	@:glFragmentSource(
		"#pragma header
		void main(void) {
            vec4 color = texture2D(bitmap, openfl_TextureCoordv);
            mat3 tritanopiaCorrection = mat3(
                0.95,  0.05,  0.0,
                0.0,   0.433, 0.567,
                0.0,   0.475, 0.525
            );
            vec3 corrected = tritanopiaCorrection * color.rgb;
            gl_FragColor = vec4(corrected, color.a);
            gl_FragColor = gl_FragColor * openfl_Alphav;
        }"
	)
	
	public function new()
	{
		super();
	}
}