/*
	Copyright 2011-2021 Daniel S. Buckstein

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
	
	passTangentBasis_displace_tes4x.glsl
	Pass interpolated and displaced tangent basis.
*/

#version 450

#define MAX_OBJECTS 128

// ****TO-DO: 
//	-> declare inbound and outbound varyings to pass along vertex data
//		(hint: inbound matches TCS naming and is still an array)
//		(hint: outbound matches GS/FS naming and is singular)
//	-> copy varying data from input to output
//	-> displace surface along normal using height map, project result
//		(hint: start by testing a "pass-thru" shader that only copies 
//		gl_Position from the previous stage to get the hang of it)

layout (triangles, equal_spacing) in;

struct sModelMatrixStack
{
	mat4 modelMat;						// model matrix (object -> world)
	mat4 modelMatInverse;				// model inverse matrix (world -> object)
	mat4 modelMatInverseTranspose;		// model inverse-transpose matrix (object -> world skewed)
	mat4 modelViewMat;					// model-view matrix (object -> viewer)
	mat4 modelViewMatInverse;			// model-view inverse matrix (viewer -> object)
	mat4 modelViewMatInverseTranspose;	// model-view inverse transpose matrix (object -> viewer skewed)
	mat4 modelViewProjectionMat;		// model-view-projection matrix (object -> clip)
	mat4 atlasMat;					// atlas matrix (texture -> cell)
};

uniform ubTransformStack
{
	sModelMatrixStack uModelMatrixStack[MAX_OBJECTS];
};
uniform int uIndex;

uniform sampler2D uTex_hm;

out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData;

in vbVertexData_tess {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData_tess[];

void main()
{
	vVertexData.vTangentBasis_view = vVertexData_tess[0].vTangentBasis_view;
	vVertexData.vTexcoord_atlas = vVertexData_tess[0].vTexcoord_atlas;

	vec4 nrm_view = normalize(vVertexData_tess[0].vTangentBasis_view[2]);
	vec4 pos_view = vVertexData_tess[0].vTangentBasis_view[3];
	vec4 sample_hm = texture(uTex_hm, vVertexData_tess[0].vTexcoord_atlas.xy);


	gl_Position = (gl_TessCoord.x + gl_in[0].gl_Position +
				   gl_TessCoord.y + gl_in[1].gl_Position +
				   gl_TessCoord.z + gl_in[2].gl_Position);
				   //nrm_view*pos_view*sample_hm*um
}
