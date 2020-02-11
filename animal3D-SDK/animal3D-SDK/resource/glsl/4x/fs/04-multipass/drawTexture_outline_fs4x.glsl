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
	
	drawTexture_outline_fs4x.glsl
	Draw texture sample with outlines.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) implement outline algorithm - see render code for uniform hints

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;

//Toon outline
uniform double uSize; //pixel size actual
uniform double uAxis; //thickness
uniform vec4 uColor; //color of line

in vec4 textureCoordOut;

out vec4 rtFragColor;

//Sobel Operator: https://computergraphics.stackexchange.com/questions/3646/opengl-glsl-sobel-edge-detection-filter
mat3 sx = mat3(
	1.0, 2.0, 1.0,
	0.0, 0.0, 0.0,
	-1.0, -2.0, -1.0
);

mat3 sy = mat3(
	1.0, 0.0, -1.0,
	2.0, 0.0, -2.0,
	1.0, 0.0, -1.0
);

void main()
{
	vec3 vTexture = textureProj(uTex_dm, textureCoordOut).rgb;	
	
	mat3 storage;

	for (int x = 0 ; x < 3 ; ++x)
	{
		for (int y = 0 ; y < 3 ; ++y)
		{
			vec3 simple = texelFetch(uTex_sm, ivec2(gl_FragCoord) + ivec2(x-1,y-1),0).rgb;
			storage[x][y] = length(simple);
		}
	}

	float gx = dot(sx[0], storage[0]) + dot(sx[1], storage[1]) + dot(sx[2], storage[2]);
	float gy = dot(sy[0], storage[0]) + dot(sy[1], storage[1]) + dot(sy[2], storage[2]);

	gx *= gx;
	gy *= gy;

	float g = sqrt(gx + gy);

	rtFragColor = vec4(vTexture - vec3(g), 1.0);
}
