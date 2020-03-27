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
uniform int uCount;
uniform int uIndex;

struct sWaypoint
{
	mat4 modelMat;	// model matrix: transform relative to scene
	mat4 modelMatInv;	// inverse model matrix: scene relative to this
	vec3 euler;		// euler angles for direct rotation control
	vec3 position;	// scene position for direct control
	vec3 scale;		// scale (not accounted for in update)
	int scaleMode;		// 0 = off; 1 = uniform; other = non-uniform (nightmare)
};

uniform ubCurveWaypoint{
	sWaypoint uWaypoint[MAX_WAYPOINTS];
};

// (2)
flat in int vInstanceID[];
// (5)
out vec4 vColor;

// (6)


vec4 linearInterpolation(vec4 p0, vec4 p1, float time)
{
	return p0 + (p1 - p0) * time;
}

vec4 bezierInterpolation(vec4 p0, vec4 p1, vec4 p2, vec4 p3, float time)
{
//	vec4 q0 = linearInterpolation(p0,p1,time);
//	vec4 q1 = linearInterpolation(p1,p2,time);
//	return linearInterpolation(q0,q1,time);
    float time2 = time * time;
    float one_minus_time = 1.0 - time;
    float one_minus_time2 = one_minus_time * one_minus_time;
    return (p0 * one_minus_time2 * one_minus_time + p1 * 3.0 * time * one_minus_time2 + p2 * 3.0 * time2 * one_minus_time + p3 * time2 * time);
}

void catmullRothInterpolation()
{
	
}

void cubicHermiteInterpolation()
{
	
}

void InterpLines()
{
	//if(uFlag >= 2 && uFlag < 6)
	//{
		int segmentIndex = vInstanceID[0];
		for(int i = 0; i < 16; ++i)
		{
			float t = i/16;
	//		int current = uIndex;
	//		int next = (uIndex + 1) % uCount;
			int i0 = uIndex;
			int i1 = (i0 + 1) % uCount;
			int i2 = (i1 + 1) % uCount;
			int i3 = (i2 + 1) % uCount;
	//		iN = (uCount + i0 - 1) % uCount;
			vColor = vec4(1.0,0.5,0.0,1.0);
			vec4 location = bezierInterpolation(vec4(uWaypoint[i0].position,0.0),vec4(uWaypoint[i1].position,0.0),vec4(uWaypoint[i2].position,0.0),vec4(uWaypoint[i3].position,0.0),t);

			//Notes
			//Need to take the location and then add it to the current location of the object, I think.
			//Not quite sure how, as trying to set the position of uWaypoint will not work due to it being a uniform
			//Unsure if there are any returns here other than color, and is the line drawing necessary to have it working?

			gl_Position = uMVP * gl_in[0].gl_Position;
			EmitVertex();
			gl_Position = uMVP * gl_in[1].gl_Position;
			EmitVertex();
			EndPrimitive();
			
		}
		
	//}
	//maybe a for loop to loop over each waypoint?
//	for(int i = 0; i < MAX_WAYPOINTS-1; ++i )
//	{
//		gl_Position = linearInterpolation(gl_in[i].gl_Position,gl_in[i+1].gl_Position,0.0);
//	}

	// 1 = none, 2 = linear, 3 = bezier, 4 = catmull-roth, 5 = cubic hermite
//	if (uFlag == 2)
//	{
//		linearInterpolation();
//	}
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
