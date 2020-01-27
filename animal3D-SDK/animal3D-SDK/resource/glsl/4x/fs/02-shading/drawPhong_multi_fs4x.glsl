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
	
	drawPhong_multi_fs4x.glsl
	Draw Phong shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Phong shading model
//	Note: test all data and inbound values before using them!

#define max_lightct 4

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform vec4 uLightPos[max_lightct];
uniform vec4 uLightCol[max_lightct];
uniform int uLightCt;

in vec4 lightTextCoord;
in vec4 outNorm;
in vec4 viewPos;

out vec4 rtFragColor;

vec4 phongLightClump()
{
	vec4 lightSum = vec4 (0.0,0.0,0.0,0.0);
	vec4 reflection = vec4(0.0,0.0,0.0,0.0);
	float specular;

	vec4 monoLight;
	float dotVal;

	for (int i = 0; i < uLightCt; ++i)
	{
		monoLight = uLightPos[i] - viewPos;
		monoLight = normalize(monoLight);
		dotVal = max(0.0, dot(normalize(outNorm), monoLight));

		reflection = 2.0 * max(0.0, dot(normalize(outNorm), monoLight)) * normalize(outNorm) - monoLight;

		specular = pow(max(dot(-normalize(viewPos), reflection), 0.0), 32.0);

		lightSum += dotVal * textureProj(uTex_dm, lightTextCoord) * uLightCol[i];
		lightSum += specular * textureProj(uTex_sm, lightTextCoord) * uLightCol[i];
	}

	return lightSum;
}


void main()
{
	rtFragColor = phongLightClump();
}
