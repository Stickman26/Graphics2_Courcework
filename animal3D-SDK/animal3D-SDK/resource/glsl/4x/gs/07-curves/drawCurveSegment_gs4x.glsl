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
	
	drawCurveSegment_gs4x.glsl
	Draw curve segment based on waypoints being passed from application.
*/

#version 430

// (16 samples/segment * 1 segment + 4 samples/handle * 2 handles)
#define MAX_VERTICES 24

#define MAX_WAYPOINTS 32

// ****TO-DO: 
//	1) add input layout specifications
//	2) receive varying data from vertex shader
//	3) declare uniforms: 
//		-> model-view-projection matrix (no inbound position at all)
//		-> flag to select curve type
//		-> optional: segment index and count
//		-> optional: curve color (can hard-code)
//		-> optional: other animation data
//	4) declare output layout specifications
//	5) declare outbound color
//	6) write interpolation functions to help with sampling
//	7) select curve type and sample over [0, 1] interval

// (1)
layout (lines) in;

// (4)
layout (line_strip, max_vertices = MAX_VERTICES) out;

// (3)
uniform mat4 uMVP;
uniform int uFlag;
uniform double uTime;

// (2)
in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
} vVertexData[]; //2 elements?

// (5)
out vec4 vColor;

// (6)


vec4 linearInterpolation(vec4 p0, vec4 p1, float time)
{
	return p0 + (p1 - p0) * time;
}

vec4 bezierInterpolation(vec4 p0, vec4 p1, vec4 p2, float time)
{
	vec4 q0 = linearInterpolation(p0,p1,time);
	vec4 q1 = linearInterpolation(p1,p2,time);
	return linearInterpolation(q0,q1,time);
}

void catmullRothInterpolation()
{
	
}

void cubicHermiteInterpolation()
{
	
}

void InterpLines()
{
	//maybe a for loop to loop over each waypoint?
	for(int i = 0; i < MAX_WAYPOINTS-1; ++i )
	{
		gl_Position = linearInterpolation(gl_in[i].gl_Position,gl_in[i+1].gl_Position,0.0);
	}

	// 1 = none, 2 = linear, 3 = bezier, 4 = catmull-roth, 5 = cubic hermite
	if (uFlag == 2)
	{
		linearInterpolation();
	}
	//vColor = vec4(0.0,1.0,0.0,1.0);
	//gl_Position = uMVP * vVertexData[0].vTexcoord_atlas;
	//EmitVertex();
	//gl_Position = uMVP * vVertexData[1].vTexcoord_atlas;
	//EmitVertex();
	//EndPrimitive();
}

// (7)

void main()
{
	InterpLines();
}
