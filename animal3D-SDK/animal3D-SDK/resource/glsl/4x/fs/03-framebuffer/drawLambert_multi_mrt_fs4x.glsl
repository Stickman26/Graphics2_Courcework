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
	
	drawLambert_multi_mrt_fs4x.glsl
	Draw Lambert shading model for multiple lights with MRT output.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!
//	5) set location of final color render target (location 0)
//	6) declare render targets for each attribute and shading component

#define max_lightct 4

uniform sampler2D uTex_dm;
uniform vec4 uLightPos[max_lightct];
uniform vec4 uLightCol[max_lightct];
uniform int uLightCt;

in vec4 lightTextCoord;
in vec4 outNorm;
in vec4 viewPos;

layout (location = 0) out vec4 vLambert;
layout (location = 1) out vec4 vViewPos;
layout (location = 2) out vec4 vViewNorm;
layout (location = 3) out vec4 vTextCoordr;
layout (location = 4) out vec4 vDiffuseM;
layout (location = 6) out vec4 vDiffuseT;

//out vec4 rtFragColor;

vec4 lambertLightClump()
{
	vec4 lightSum = vec4 (0.0,0.0,0.0,1.0);
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

	return lightSum;
}

void main()
{
	vLambert = lambertLightClump() * textureProj(uTex_dm, lightTextCoord);
	vViewPos = viewPos;
	vViewNorm = normalize(outNorm) + vec4(0.0,0.0,0.0,1.0);
	vTextCoordr = lightTextCoord;
	vDiffuseM = textureProj(uTex_dm, lightTextCoord);
	vDiffuseT = lambertLightClump();
}
