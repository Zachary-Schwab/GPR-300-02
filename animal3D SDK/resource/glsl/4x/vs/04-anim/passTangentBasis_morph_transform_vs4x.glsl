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
	
	passTangentBasis_morph_transform_vs4x.glsl
	Calculate and pass morphed tangent basis.
*/

#version 450

#define MAX_OBJECTS 128

// ****DONE:
//	-> declare morph target attributes
//	-> declare and implement morph target interpolation algorithm
//	-> declare interpolation time/param/keyframe uniform
//	-> perform morph target interpolation using correct attributes
//		(hint: results can be stored in local variables named after the 
//		complete tangent basis attributes provided before any changes)

//layout 15 as 0-14 are taken by the 15 attributes from the 5 morph targets.
layout (location = 15) in vec4 aTexcoord;

//what is part of a single morph target:
// -> position, normal, tangent
// -> 16 available, 16 / 3 = 5 (int)

// what is not part of a single morph target
// -> texcoord - shared because 2D render is always the same
// bitangent: normal x tangent
struct sMorphTarget
{
	vec4 position;
	vec3 normal;
	vec3 tangent;
};

layout (location = 0) in sMorphTarget aMorphTarget[5];


struct sModelMatrixStack
{
	mat4 modelMat;						// model matrix (object -> world)
	mat4 modelMatInverse;				// model inverse matrix (world -> object)
	mat4 modelMatInverseTranspose;		// model inverse-transpose matrix (object -> world skewed)
	mat4 modelViewMat;					// model-view matrix (object -> viewer)
	mat4 modelViewMatInverse;			// model-view inverse matrix (viewer -> object)
	mat4 modelViewMatInverseTranspose;	// model-view inverse transpose matrix (object -> viewer skewed)
	mat4 modelViewProjectionMat;		// model-view-projection matrix (object -> clip)
	mat4 atlasMat;						// atlas matrix (texture -> cell)
};

uniform ubTransformStack
{
	sModelMatrixStack uModelMatrixStack[MAX_OBJECTS];
};
uniform int uIndex;

out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
};

flat out int vVertexID;
flat out int vInstanceID;

uniform float uTime;

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	//gl_Position = aPosition;
	
	int index = int(uTime);
	float param = uTime - index;

	vec4 aPosition;
	vec3 aTangent, aBitangent, aNormal;

	//testing: copy the first morph target only
	
	//interpolate between the current index and the next morph target, mod 5 in order to keep it within bounds of the array
	aPosition =  mix(aMorphTarget[index % 5].position, aMorphTarget[(index + 1) % 5].position, param);
	aTangent = mix(aMorphTarget[index % 5].tangent, aMorphTarget[(index + 1) % 5].tangent, param);
	aNormal = mix(aMorphTarget[index % 5].normal, aMorphTarget[(index + 1) % 5].normal, param);
	//cross multiply the normal and tangent to get the bitangent
	aBitangent = cross(aNormal,aTangent);
	

	sModelMatrixStack t = uModelMatrixStack[uIndex];
	
	vTangentBasis_view = t.modelViewMatInverseTranspose * mat4(aTangent, 0.0, aBitangent, 0.0, aNormal, 0.0, vec4(0.0));
	vTangentBasis_view[3] = t.modelViewMat * aPosition;
	gl_Position = t.modelViewProjectionMat * aPosition;
	
	vTexcoord_atlas = t.atlasMat * aTexcoord;

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}
