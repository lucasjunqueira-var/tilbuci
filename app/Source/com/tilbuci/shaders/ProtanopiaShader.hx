package com.tilbuci.shaders;

import openfl.display.Shader;
import openfl.display.GraphicsShader;

class ProtanopiaShader extends GraphicsShader
{
	@:glFragmentSource(
		"#pragma header
		void main(void) {
            vec4 color = texture2D(bitmap, openfl_TextureCoordv);
            mat3 protanopiaCorrection = mat3(
                0.567, 0.433, 0.0,
                0.558, 0.442, 0.0,
                0.0,   0.242, 0.758
            );
            vec3 corrected = protanopiaCorrection * color.rgb;
            gl_FragColor = vec4(corrected, color.a);
            gl_FragColor = gl_FragColor * openfl_Alphav;
        }"
	)
	
	public function new()
	{
		super();
	}
}