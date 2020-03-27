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
	
	mirrorTexture_fs4x.glsl
	Draw textures to scene objects which are reflective.
*/

// Notes to self:
// Generate a cube map using skybox
// build a reflect function
// build a refract function
// mix them

#version 410

//Uniform skybox as a samplerCube
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform sampler2D uImage02;

//Need texture coords, normal, and a reflected vector in
in vec4 passTexcoord;
in vec4 passNorm;
in vec3 reflectedVector;
in vec3 rayOrigin;

out vec4 rtFragColor;

//Matrixes for using the skybox texture in a pseduo cube map fasion
mat4 frontFaceAtlas = mat4(
0.25, 0.0, 0.0, 0.0, 
0.0, 0.25, 0.0, 0.0, 
0.0, 0.0, 1.0, 0.0, 
0.375, 0.0, 0.0, 1.0); // Mid Sun

mat4 topFaceAtlas = mat4(
0.25, 0.0, 0.0, 0.0,
0.0, 0.25, 0.0, 0.0,
0.0, 0.0, 1.0, 0.0,
0.375, 0.25, 0.0, 1.0); //Above the Sun

mat4 backFaceAtlas = mat4(
0.25, 0.0, 0.0, 0.0,
0.0, 0.25, 0.0, 0.0,
0.0, 0.0, 1.0, 0.0,
0.375, 0.5, 0.0, 1.0); //Below Vortex

mat4 bottomFaceAtlas = mat4(
0.25, 0.0, 0.0, 0.0,
0.0, 0.25, 0.0, 0.0, 
0.0, 0.0, 1.0, 0.0, 
0.375, 0.75, 0.0, 1.0); // Mid Vortex

mat4 rightFaceAtlas = mat4(
0.25, 0.0, 0.0, 0.0,
0.0, 0.25, 0.0, 0.0,
0.0, 0.0, 1.0, 0.0,
0.625, 0.0, 0.0, 1.0); //Right of Sun

mat4 leftFaceAtlas = mat4(
0.25, 0.0, 0.0, 0.0,
0.0, 0.25, 0.0, 0.0,
0.0, 0.0, 1.0, 0.0,
0.125, 0.0, 0.0, 1.0); //Left of Sun

//Ray-Plane Intersection Test
//https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-plane-and-ray-disk-intersection
bool rayPlaneIntersection(vec3 rayDir, vec3 rayOri, vec3 planePt, vec3 planeNrm)
{
	float denom = dot(normalize(planeNrm), normalize(rayDir));
	if (abs(denom) > .000001)
	{
		vec3 CmRo = planePt - rayOri;
		float t = dot(CmRo, planeNrm) / denom;
		if (t >= 0)
		{
			return true;
		}
	}
	return false;
}

vec4 reflectiveTexture(vec4 regTex, float mixVal)
{
	vec4 reflectionCoord = passTexcoord;

	//Check each of the normal planes
	//Top
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(0.0, 50.0, 0.0), vec3(0.0, 1.0, 0.0)))
	{
		reflectionCoord = topFaceAtlas * passTexcoord;
	}
	//Bottom
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(0.0, -50.0, 0.0), vec3(0.0, -1.0, 0.0)))
	{
		reflectionCoord = bottomFaceAtlas * passTexcoord;
	}
	//Left
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(-50.0, 0.0, 0.0), vec3(-1.0, 0.0, 0.0)))
	{
		reflectionCoord = leftFaceAtlas * passTexcoord;
	}
	//Right
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(50.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0)))
	{
		reflectionCoord = rightFaceAtlas * passTexcoord;
	}
	//Front
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(0.0, 0.0, 50.0), vec3(0.0, 0.0, 1.0)))
	{
		reflectionCoord = frontFaceAtlas * passTexcoord;
	}
	//Back
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(0.0, 0.0, -50.0), vec3(0.0, 0.0, -1.0)))
	{
		reflectionCoord = backFaceAtlas * passTexcoord;
	}

	vec4 reflectionCol = texture(uImage02, reflectionCoord.xy);

	//return mix(regTex, reflectionCol, mixVal);

	//DUMMY OUTPUT ONLY MIRROR OR SOLID COLOR
	return reflectionCol;//vec4(1.0,0.0,1.0,1.0);
}

//Insert phong here

void main() 
{
	vec4 phongVal = vec4(0.0,0.0,0.0,1.0);
	rtFragColor = reflectiveTexture(phongVal , 0.6);
}