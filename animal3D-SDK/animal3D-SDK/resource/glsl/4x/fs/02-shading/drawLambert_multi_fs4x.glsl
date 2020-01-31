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
	
	drawLambert_multi_fs4x.glsl
	Draw Lambert shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!

#define max_lightct 4

uniform sampler2D uTex_dm;
uniform vec4 uLightPos[max_lightct];
uniform vec4 uLightCol[max_lightct];
uniform int uLightCt;

in vec4 lightTextCoord;
in vec4 outNorm;
in vec4 viewPos;

out vec4 rtFragColor;

vec4 lambertLightClump()
{
	vec4 lightSum = vec4 (0.0,0.0,0.0,0.0);
	vec4 monoLight;
	float dotVal;
	vec4 normNorm = normalize(outNorm);

	for (int i = 0; i < uLightCt; ++i)
	{
		monoLight = uLightPos[i] - viewPos;
		monoLight = normalize(monoLight);
		dotVal = max(0.0, dot(normNorm, monoLight));
		lightSum += dotVal * uLightCol[i];
	}



	return lightSum * textureProj(uTex_dm, lightTextCoord);
}

void main()
{

	rtFragColor = lambertLightClump();

	//DEBUGGING	
	//rtFragColor = lightTextCoord;
	//rtFragColor = outNorm;
	//rtFragColor = viewPos;
	//rtFragColor = uLightCol[3];
}

