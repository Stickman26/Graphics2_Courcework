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
	
	drawPhong_multi_deferred_fs4x.glsl
	Draw Phong shading model by sampling from input textures instead of 
		data received from vertex shader.
*/

#version 410

#define MAX_LIGHTS 4

// ****TO-DO: 
//	0) copy original forward Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare light data as uniform block  same lighting as forward
//	3) replace geometric information normally received from fragment shader 
//		with samples from respective g-buffer textures; use to compute lighting
//			-> position calculated using reverse perspective divide; requires 
//				inverse projection-bias matrix and the depth map
//			-> normal calculated by expanding range of normal sample
//			-> surface texture coordinate is used as-is once sampled

uniform sampler2D uImage00; //depth
uniform sampler2D uImage01; //position
uniform sampler2D uImage02; //normal
uniform sampler2D uImage03; //texCoord
uniform sampler2D uImage04; //diffuse
uniform sampler2D uImage05; //specular

uniform mat4 uPB_inv; //for pos

uniform vec4 uLightPos[MAX_LIGHTS];
uniform vec4 uLightCol[MAX_LIGHTS];
uniform int uLightCt;

in vec4 vTexcoord;

layout (location = 0) out vec4 rtFragColor;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;

vec4 phongDiffuse()
{
	vec4 diffuseSum = vec4 (0.0,0.0,0.0,1.0);

	//Convert Images to vec4 data
	vec4 viewPos = texture(uImage01, vTexcoord.xy);
	viewPos = uPB_inv * viewPos;
	viewPos = viewPos / viewPos.w;
	vec4 norm = texture(uImage02, vTexcoord.xy);

	vec4 monoLight;
	float dotVal;
	vec4 normNorm = (norm * 2.0) - 1.0;
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

	//Convert Images to vec4 data
	vec4 viewPos = texture(uImage01, vTexcoord.xy);
	viewPos = uPB_inv * viewPos;
	viewPos = viewPos / viewPos.w;
	vec4 norm = texture(uImage02, vTexcoord.xy);

	vec4 monoLight;
	float dotVal;
	vec4 normNorm = (norm * 2.0) - 1.0;
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


vec4 phongLightClump()
{
	float depthCheck = texture(uImage00, vTexcoord.xy).x;
	if(depthCheck == 1.0)
		discard;

	vec4 lightSum = vec4 (0.0,0.0,0.0,0.0);

	vec4 lightTextCoord = texture(uImage03, vTexcoord.xy);

	lightSum += textureProj(uImage04, lightTextCoord) * phongDiffuse();
	lightSum += textureProj(uImage05, lightTextCoord) * phongSpecular();

	return lightSum;
}

void main()
{
	//convert texcoord
	vec4 sampledTextCoord = texture(uImage03, vTexcoord.xy);
	
	rtFragColor = phongLightClump();
	rtDiffuseMapSample = textureProj(uImage04, sampledTextCoord);
	rtSpecularMapSample = textureProj(uImage05, sampledTextCoord);
	rtDiffuseLightTotal = phongDiffuse();
	rtSpecularLightTotal = phongSpecular();
}
