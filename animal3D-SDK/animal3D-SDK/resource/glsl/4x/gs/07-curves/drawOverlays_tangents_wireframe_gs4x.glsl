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
	
	drawOverlays_tangents_wireframe_gs4x.glsl
	Draw tangent bases of vertices and faces, and/or wireframe shapes, 
		based on flag passed to program.
*/

#version 430

// (2 verts/axis * 3 axes/basis * (3 vertex bases + 1 face basis) + 4 or 8 wireframe verts = 28 or 32 verts)
#define MAX_VERTICES 32

// ****TO-DO: 
//	1) add input layout specifications
//	2) receive varying data from vertex shader
//	3) declare uniforms: 
//		-> projection matrix (inbound position is in view-space)
//		-> optional: wireframe color (can hard-code)
//		-> optional: size of tangent bases (ditto)
//		-> optional: flags to decide whether or not to draw bases/wireframe
//	4) declare output layout specifications
//	5) declare outbound color
//	6) draw tangent bases
//	7) draw wireframe

// (1)
layout (triangles) in;

// (4)
layout (triangle_strip, max_vertices = MAX_VERTICES) out;

// (3)
uniform mat4 uP;
uniform double uTime;
uniform sampler2D uTex_dm;

// (2)
in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
} vVertexData[]; // 3 elements

// (5)
out vec4 vColor;

out vec4 vTexCoord;

// (6)
in vec4 viewSpace[];

vec4 explosion(vec4 pos, vec3 norm)
{
	float magnitude = 2.0;
	vec3 direction = norm * ((sin(float(uTime)) - 0.25) * 0.5) * magnitude;
	return pos + vec4(direction, 0.0);
}

vec3 GetNormal()
{
	vec3 a = vec3(gl_in[0].gl_Position) - vec3(gl_in[1].gl_Position);
	vec3 b = vec3(gl_in[1].gl_Position) - vec3(gl_in[2].gl_Position);
	return normalize(cross(a, b));
}

// (7)
void drawWireFrame()
{
	vColor = vec4(1.0,0.5,0.0,1.0); //orange
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[1].gl_Position;
	EmitVertex();
	gl_Position = gl_in[2].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	EndPrimitive();
}

void CauseExplosion()
{
	vec3 normal = GetNormal();

	vColor = texture(uTex_dm, vVertexData[0].vTexcoord_atlas.xy);

	gl_Position = uP * explosion(viewSpace[0], normal);
	vTexCoord = vVertexData[0].vTexcoord_atlas;
	EmitVertex();
	gl_Position = uP * explosion(viewSpace[1], normal);
	vTexCoord = vVertexData[1].vTexcoord_atlas;
	EmitVertex();
	gl_Position = uP * explosion(viewSpace[2], normal);
	vTexCoord = vVertexData[2].vTexcoord_atlas;
	EmitVertex();

	EndPrimitive();
}

void main()
{
	//drawWireFrame();
	CauseExplosion();
}
