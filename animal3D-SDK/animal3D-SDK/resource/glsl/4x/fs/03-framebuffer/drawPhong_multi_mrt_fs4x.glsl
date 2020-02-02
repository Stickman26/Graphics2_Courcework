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
	
	drawPhong_multi_mrt_fs4x.glsl
	Draw Phong shading model for multiple lights with MRT output.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Phong shading model
//	Note: test all data and inbound values before using them!
//	5) set location of final color render target (location 0)
//	6) declare render targets for each attribute and shading component

#define max_lightct 4

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform vec4 uLightPos[max_lightct];
uniform vec4 uLightCol[max_lightct];
uniform int uLightCt;

in vec4 lightTextCoord;
in vec4 outNorm;
in vec4 viewPos;

//Variables for storing diffuse and specular sperately
vec4 specularSum;
vec4 diffuseSum;

//out vec4 rtFragColor;

layout (location = 0) out vec4 vPhong;
layout (location = 1) out vec4 vViewPos;
layout (location = 2) out vec4 vViewNorm;
layout (location = 3) out vec4 vTextCoordr;
layout (location = 4) out vec4 vDiffuseM;
layout (location = 5) out vec4 vSpecularM;
layout (location = 6) out vec4 vDiffuseT;
layout (location = 7) out vec4 vSpecularT;

vec4 phongLightClump()
{
	vec4 lightSum = vec4 (0.0,0.0,0.0,0.0);
	vec4 reflection = vec4(0.0,0.0,0.0,0.0);
	float specular;

	vec4 monoLight;
	float dotVal;
	vec4 normNorm = normalize(outNorm);
	vec4 viewVec = -normalize(viewPos);

	for (int i = 0; i < uLightCt; ++i)
	{
		monoLight = uLightPos[i] - viewPos;
		monoLight = normalize(monoLight);
		dotVal = max(0.0, dot(normNorm, monoLight));

		reflection = 2.0 * max(0.0, dot(normNorm, monoLight)) * normNorm - monoLight;

		specular = max(dot(viewVec, reflection), 0.0);
		//power 32
		specular *= specular; //2
		specular *= specular; //4
		specular *= specular; //8
		specular *= specular; //16
		specular *= specular; //32

		lightSum += dotVal * textureProj(uTex_dm, lightTextCoord) * uLightCol[i];
		lightSum += specular * textureProj(uTex_sm, lightTextCoord) * uLightCol[i];
	}

	return lightSum;
}

vec4 phongDiffuse()
{
	vec4 diffuseSum = vec4 (0.0,0.0,0.0,0.0);

	vec4 monoLight;
	float dotVal;
	vec4 normNorm = normalize(outNorm);
	vec4 viewVec = -normalize(viewPos);

	for (int i = 0; i < uLightCt; ++i)
	{
		monoLight = uLightPos[i] - viewPos;
		monoLight = normalize(monoLight);
		dotVal = max(0.0, dot(normNorm, monoLight));

		diffuseSum += dotVal * uLightCol[i];
	}

	return diffuseSum;
}

vec4 phongSpecular()
{
	vec4 specularSum = vec4 (0.0,0.0,0.0,1.0);
	vec4 reflection = vec4(0.0,0.0,0.0,0.0);
	float specular;

	vec4 monoLight;
	float dotVal;
	vec4 normNorm = normalize(outNorm);
	vec4 viewVec = -normalize(viewPos);

	for (int i = 0; i < uLightCt; ++i)
	{
		monoLight = uLightPos[i] - viewPos;
		monoLight = normalize(monoLight);
		dotVal = max(0.0, dot(normNorm, monoLight));

		reflection = 2.0 * max(0.0, dot(normNorm, monoLight)) * normNorm - monoLight;

		specular = max(dot(viewVec, reflection), 0.0);
		//power 32
		specular *= specular; //2
		specular *= specular; //4
		specular *= specular; //8
		specular *= specular; //16
		specular *= specular; //32

		specularSum += specular * uLightCol[i];
	}

	return specularSum;
}

void main()
{
	vPhong = phongLightClump();
	vViewPos = viewPos;
	vViewNorm = normalize(outNorm);
	vTextCoordr = lightTextCoord;
	vDiffuseM = textureProj(uTex_dm, lightTextCoord);
	vSpecularM = textureProj(uTex_sm, lightTextCoord);
	vDiffuseT = phongDiffuse();
	vSpecularT = phongSpecular();
}
