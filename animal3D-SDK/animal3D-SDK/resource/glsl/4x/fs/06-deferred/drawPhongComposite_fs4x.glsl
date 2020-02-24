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
	
	drawPhongComposite_fs4x.glsl
	Draw final Phong shading model by compositing lighting with textures.
*/

#version 410

// ****TO-DO: 
//	1) declare texture coordinate g-buffer to get surface UVs
//	2) declare diffuse and specular maps as uniform samplers
//	3) declare diffuse and specular light textures as uniform samplers
//	4) declare ambient color as uniform vector
//	5) calculate Phong shading model by sampling from light buffers and 
//		multiplying by the respective surface texture sample and summing 
//		the components: 
//			PHONG =	ambient light 
//					+ diffuse light * diffuse sample 
//					+ specular light * specular sample 

in vec4 vTexcoord;
uniform sampler2D uImage03; //texCoord
uniform sampler2D uImage04; //diffuse
uniform sampler2D uImage05; //specular
uniform sampler2D uImage06;//diffuselight
uniform sampler2D uImage07;//speclight

layout (location = 0) out vec4 rtFragColor;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;

void main()
{
	vec4 sampledTextCoord = texture(uImage03, vTexcoord.xy);

	vec4 diffuseMap = textureProj(uImage04,sampledTextCoord);
	vec4 specularMap = textureProj(uImage05,sampledTextCoord);
	vec4 diffuseLight = textureProj(uImage06,sampledTextCoord);
	vec4 specularLight = textureProj(uImage07,sampledTextCoord);

	vec4 diffuseCalc = diffuseLight * diffuseMap;
	vec4 specularCalc = specularLight * specularMap;


	// DUMMY OUTPUT: all fragments are OPAQUE YELLOW (and others)
	rtFragColor = diffuseCalc + specularCalc;
	rtDiffuseMapSample = diffuseCalc;
	rtSpecularMapSample = specularCalc;
}
