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
	
	drawTexture_pixelation_fs4x.glsl
	Draw texture pixelated.
*/

#version 410

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform sampler2D uImage1;
uniform sampler2D uImage2;

//Toon outline
uniform vec2 uSize; //pixel size actual
uniform vec2 uAxis; //thickness
uniform vec4 uColor; //color of line

in vec4 textureCoordOut;

void main()
{
	vec4 vTexture = textureProj(uTex_dm, textureCoordOut);	
	
	float dx = 15.0 * (1.0/512.0);
	float dy = 10.0 * (1.0/512.0);
	vec2 coord = vec2(dx*floor(textureCoordOut.x/dx),dy*floor(textureCoordOut.y/dy));
	rtFragColor = texture2D(uTex_dm,coord);


	
}
