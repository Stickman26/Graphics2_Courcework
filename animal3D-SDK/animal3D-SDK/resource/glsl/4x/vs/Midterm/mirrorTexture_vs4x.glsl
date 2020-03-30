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
	
	mirrorTexture_vs4x.glsl
	vertex data for scene objects which are reflective.
*/

#version 410

uniform mat4 uMVP;
uniform mat4 uMV;

layout (location = 8)	in vec4 aTexcoord;
layout (location = 2)	in vec4 aNormal;
layout (location = 0)	in vec4 aPosition;

out vec4 passTexcoord;
out vec4 passNorm;
out vec3 reflectedVector;
out vec3 rayOrigin;

void main() {
	
	vec4 worldPos = aPosition;
	gl_Position = uMVP * worldPos;
	rayOrigin = gl_Position.xyz;

	passTexcoord = aTexcoord;
	passNorm = aNormal;
	vec4 normNormal = normalize(aNormal);

	vec3 cameraPos = (uMV * aPosition).xyz;
	vec3 viewVector = normalize(worldPos.xyz - cameraPos);
	reflectedVector = reflect(viewVector, normNormal.xyz).xyz;
}