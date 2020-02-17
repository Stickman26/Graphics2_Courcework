/*
	Copyright 2011-2020 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawTexture_blendScreen4_fs4x.glsl
	Draw blended sample from multiple textures using screen function.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) declare additional texture uniforms
//	2) implement screen function with 4 inputs
//	3) use screen function to sample input textures

uniform sampler2D uImage00;
uniform sampler2D uImage01;
uniform sampler2D uImage02;
uniform sampler2D uImage03;

in vec4 textureCoordOut;

//4x Inputs?
//Other Images?

//Screen Function
vec4 screen(vec4 A, vec4 B, vec4 C, vec4 D)
{
	return 1.0 - ((1.0 - A) * (1.0 - B) * (1.0 - C) * (1.0 - D));
}

out vec4 rtFragColor;

void main()
{
	// fragments set based on texture
	vec4 img0 = textureProj(uImage00, textureCoordOut);
	vec4 img1 = textureProj(uImage01, textureCoordOut);
	vec4 img2 = textureProj(uImage02, textureCoordOut);
	vec4 img3 = textureProj(uImage03, textureCoordOut);
	
	rtFragColor = screen(img0,img1,img2,img3);
}
