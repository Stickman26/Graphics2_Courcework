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
	
	drawPhong_multi_forward_mrt_fs4x.glsl
	Draw Phong shading model using forward light set.
*/

#version 430

#define MAX_LIGHTS 4

// ****TO-DO: 
//	0) nothing

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
};

struct sPointLight
{
	vec4 worldPos;
	vec4 viewPos;
	vec4 color;
	float radius;
	float radiusInvSq;
	float radiusInv;
	float radiusSq;
};


uniform ubPointLight {
	sPointLight uPointLight[MAX_LIGHTS];
};

uniform int uLightCt;
uniform vec4 uColor;
uniform sampler2D uTex_dm, uTex_sm, uImage02;


// final color
layout (location = 0) out vec4 rtFragColor;

// attribute data
layout (location = 1) out vec4 rtAtlasTexcoord;
layout (location = 2) out vec4 rtViewTangent;
layout (location = 3) out vec4 rtViewBitangent;
layout (location = 4) out vec4 rtViewNormal;
layout (location = 5) out vec4 rtViewPosition;

// lighting data
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;


float pow64(float v)
{
	v *= v;	// ^2
	v *= v;	// ^4
	v *= v;	// ^8
	v *= v;	// ^16
	v *= v;	// ^32
	v *= v;	// ^64
	return v;
}


vec3 refl(in vec3 v, in vec3 n, in float d)
{
	return ((2.0 * d) * n - v);
}


float calcDiffuseCoefficient(
	out vec3 lightVec, out float lightDist, out float lightDistSq,
	in vec3 lightPos, in vec3 fragPos, in vec3 fragNrm)
{
	lightVec = lightPos - fragPos;
	lightDistSq = dot(lightVec, lightVec);
	lightDist = sqrt(lightDistSq);
	lightVec /= lightDist;
	return dot(lightVec, fragNrm);
}


float calcSpecularCoefficient(
	out vec3 reflVec, out vec3 eyeVec,
	in vec3 lightVec, in float diffuseCoefficient,
	in vec3 fragPos, in vec3 fragNrm, in vec3 eyePos)
{
	reflVec = refl(lightVec, fragNrm, diffuseCoefficient);
	eyeVec = normalize(eyePos - fragPos);
	return dot(reflVec, eyeVec);
}


float calcAttenuation(
	float lightDist, float lightDistSq,
	float lightSz, float lightSzInvSq, float lightSzInv, float lightSzSq)
{
//	float atten = max(0.0, (1.0 - lightDistSq * lightSzInvSq));
	float atten = (1.0 / (1.0 + 2.0 * lightDist * lightSzInv + lightDistSq * lightSzInvSq));
	return atten;
}


void addPhongComponents(
	inout vec3 diffuseLightTotal, out float diffuseCoefficient,
	inout vec3 specularLightTotal, out float specularCoefficient,
	in vec3 lightPos, in vec3 lightCol,
	in float lightSz, in float lightSzInvSq, in float lightSzInv, in float lightSzSq,
	in vec3 fragPos, in vec3 fragNrm, in vec3 eyePos)
{
	float lightDist, lightDistSq, attenuation;
	vec3 lightVec, reflVec, eyeVec;
	vec3 attenuationColor;

	diffuseCoefficient = calcDiffuseCoefficient(
		lightVec, lightDist, lightDistSq,
		lightPos, fragPos, fragNrm);
	specularCoefficient = calcSpecularCoefficient(
		reflVec, eyeVec,
		lightVec, diffuseCoefficient,
		fragPos, fragNrm, eyePos);
	attenuation = calcAttenuation(
		lightDist, lightDistSq,
		lightSz, lightSzInvSq, lightSzInv, lightSzSq);

	diffuseCoefficient = max(0.0, diffuseCoefficient);
	specularCoefficient = pow64(max(0.0, specularCoefficient));

	attenuationColor = attenuation * lightCol;
	diffuseLightTotal += attenuationColor * diffuseCoefficient;
	specularLightTotal += attenuationColor * specularCoefficient;
}

//Need texture coords, normal, and a reflected vector in
in vec3 reflectedVector;
in vec3 rayOrigin;


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
	vec4 reflectionCoord = vTexcoord_atlas;

	//Check each of the normal planes
	//Top
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(0.0, -50.0, 0.0), vec3(0.0, 1.0, 0.0)))
	{
		reflectionCoord = topFaceAtlas * vTexcoord_atlas;
	}
	//Bottom
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(0.0, 50.0, 0.0), vec3(0.0, -1.0, 0.0)))
	{
		reflectionCoord = bottomFaceAtlas * vTexcoord_atlas;
	}
	//Left
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(50.0, 0.0, 0.0), vec3(-1.0, 0.0, 0.0)))
	{
		reflectionCoord = leftFaceAtlas * vTexcoord_atlas;
	}
	//Right
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(-50.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0)))
	{
		reflectionCoord = rightFaceAtlas * vTexcoord_atlas;
	}
	//Front
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(0.0, 0.0, -50.0), vec3(0.0, 0.0, 1.0)))
	{
		reflectionCoord = frontFaceAtlas * vTexcoord_atlas;
	}
	//Back
	if (rayPlaneIntersection(reflectedVector.xyz, rayOrigin.xyz, vec3(0.0, 0.0, 50.0), vec3(0.0, 0.0, -1.0)))
	{
		reflectionCoord = backFaceAtlas * vTexcoord_atlas;
	}

	vec4 reflectionCol = texture(uImage02, reflectionCoord.xy);

	//return mix(regTex, reflectionCol, mixVal);

	//DUMMY OUTPUT ONLY MIRROR OR SOLID COLOR
	return reflectionCol;
}

void main()
{
	// DUMMY OUTPUT: all fragments are colored based on model index
//	vec4 color[6] = vec4[6] ( vec4(1.0, 0.0, 0.0, 1.0), vec4(1.0, 1.0, 0.0, 1.0), vec4(0.0, 1.0, 0.0, 1.0), vec4(0.0, 1.0, 1.0, 1.0), vec4(0.0, 0.0, 1.0, 1.0), vec4(1.0, 0.0, 1.0, 1.0) );
//	rtFragColor = color[vModelID % 6];

	mat4 tangentBasis_view = mat4(
		normalize(vTangentBasis_view[0]),
		normalize(vTangentBasis_view[1]),
		normalize(vTangentBasis_view[2]),
		vTangentBasis_view[3]
	);

	vec4 T = tangentBasis_view[0];
	vec4 B = tangentBasis_view[1];
	vec4 N = tangentBasis_view[2];
	vec4 P = tangentBasis_view[3];

	int i;
	sPointLight light;
	float kd, ks;
	vec3 eyePos = vec3(0.0);
	vec3 ambient = uColor.rgb * 0.1,
		diffuseLightTotal = vec3(0.0),
		specularLightTotal = diffuseLightTotal;

	for (i = 0; i < uLightCt; ++i)
	{
		light = uPointLight[i];
		addPhongComponents(
			diffuseLightTotal, kd,
			specularLightTotal,ks,
			light.viewPos.xyz, light.color.rgb,
			light.radius, light.radiusInvSq, light.radiusInv, light.radiusSq,
			P.xyz, N.xyz, eyePos);
	}


	// textures
	vec4 sample_dm = texture(uTex_dm, vTexcoord_atlas.xy);
	vec4 sample_sm = texture(uTex_sm, vTexcoord_atlas.xy);


	// final color
	vec4 phongColor;
	phongColor.rgb = ambient
					+ sample_dm.rgb * diffuseLightTotal
					+ sample_sm.rgb * specularLightTotal;
	phongColor.a = sample_dm.a;

	rtFragColor = reflectiveTexture(phongColor, 0.6);
	rtFragColor.a = sample_dm.a;

	// output attributes
	rtAtlasTexcoord = vTexcoord_atlas;
	rtViewTangent = vec4(T.xyz * 0.5 + 0.5, 1.0);
	rtViewBitangent = vec4(B.xyz * 0.5 + 0.5, 1.0);
	rtViewNormal = vec4(N.xyz * 0.5 + 0.5, 1.0);
	rtViewPosition = P;

	// output lighting
	rtDiffuseLightTotal = vec4(diffuseLightTotal, 1.0);
	rtSpecularLightTotal = vec4(specularLightTotal, 1.0);
}
