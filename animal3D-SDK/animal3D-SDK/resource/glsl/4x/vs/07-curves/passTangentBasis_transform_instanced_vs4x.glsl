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
	
	passTangentBasis_transform_instanced_vs4x.glsl
	Transforms all attributes by their respective matrix, sends full 
		tangent basis and other lighting data.
*/

#version 430

#define MAX_INSTANCES	16
#define MAX_MODELS		 8

// ****TO-DO: 
//	0) nothing

layout (location = 8)	in vec4 aTexcoord;
layout (location = 10)	in vec4 aTangent;
layout (location = 11)	in vec4 aBitangent;
layout (location = 2)	in vec4 aNormal;
layout (location = 0)	in vec4 aPosition;

uniform mat4 uMVPB_other;

struct sMatrixStack
{
	mat4 modelMat, modelMatInverse, modelNormalMat;
	mat4 modelViewMat, modelViewMatInverse, modelViewNormalMat;
	mat4 modelViewProjectionMat;
	mat4 atlasMat;
};

uniform ubTransformStack {
	sMatrixStack uTransform[MAX_INSTANCES][MAX_MODELS];
};
uniform int uIndex;


out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
};

out vec3 reflectedVector; //direction of the reflected ray
out vec3 rayOrigin; //origin point of reflected ray

//Doing Cool Things
const float waveLength = 3.0;
const float waveAmp = 0.9;
const float PI = 3.14159;

uniform double uTime;

float generateOffset(float x, float z)
{
	float radiansX = (x / waveLength) * 2.0 * PI;
	float radiansZ = (z / waveLength) * 2.0 * PI;
	return waveAmp * 0.5 * (sin(radiansZ + (float(uTime))) + cos(radiansX + (float(uTime))));
}

vec3 applyDistortion(vec3 vertex)
{
	float xDistort = generateOffset(vertex.x, vertex.y);
	float yDistort = generateOffset(vertex.y, vertex.z);
	float zDistort = generateOffset(vertex.z, vertex.x);
	return vertex + vec3(xDistort, yDistort, zDistort);
}

out vec4 viewSpace;

void main()
{
	vVertexID = gl_VertexID;
	int i = vInstanceID = gl_InstanceID;
	int m = vModelID = uIndex;

	mat4 tangentBasis_object = mat4(aTangent, aBitangent, aNormal, aPosition);

	sMatrixStack t = uTransform[i][m];
	vTexcoord_atlas = t.atlasMat * aTexcoord;
	vTangentBasis_view = t.modelViewNormalMat * tangentBasis_object;
	vTangentBasis_view[3] = t.modelViewMat * aPosition;
	gl_Position = t.modelViewProjectionMat * aPosition;

	//Doing Cool Stuff
	vec3 currentVertex = vec3(aPosition.x, aPosition.y, aPosition.z);
	currentVertex = applyDistortion(currentVertex);
	viewSpace = t.modelViewMat * vec4(currentVertex, 1.0);

	rayOrigin = (t.modelViewProjectionMat * aPosition).xyz;
	vec3 viewVector = normalize(aPosition.xyz - rayOrigin);
	vec4 normNormal = normalize(t.modelViewNormalMat * aNormal);
	reflectedVector = reflect(viewVector, normNormal.xyz).xyz;

	
}
