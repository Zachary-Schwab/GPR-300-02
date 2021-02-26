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
	
	postBlend_fs4x.glsl
	Blending layers, composition.
*/

#version 450

// ****TO-DO:
//	-> declare texture coordinate varying and set of input textures
//	-> implement some sort of blending algorithm that highlights bright areas
//		(hint: research some Photoshop blend modes)

in vec4 vTexcoord_atlas;

layout (location = 0) out vec4 rtFragColor;

layout (binding = 0) uniform sampler2D sceneTexture;
layout (binding = 0) uniform sampler2D verticalBlur2;
layout (binding = 0) uniform sampler2D verticalBlur4;
layout (binding = 0) uniform sampler2D verticalBlur8;

void main()
{
/*
	vec4 composite = vec4(0.0);
	vec4 sceneWeightedColor = (1.0 - texture2D(sceneTexture,vTexcoord_atlas.xy));
	vec4 verticalBlurHalfWeightedColor = (1.0 - texture2D(verticalBlur2,vTexcoord_atlas.xy));
	vec4 verticalBlurQuarterWeightedColor = (1.0 - texture2D(verticalBlur4,vTexcoord_atlas.xy));
	vec4 verticalBlurEighthWeightedColor = (1.0 - texture2D(verticalBlur8,vTexcoord_atlas.xy));
	composite = 1.0 - (sceneWeightedColor * verticalBlurHalfWeightedColor * verticalBlurQuarterWeightedColor * verticalBlurEighthWeightedColor);
	*/
	vec4 composite = 1.0 - (1.0 - texture2D(sceneTexture,vTexcoord_atlas.xy)) * (1.0 - texture2D(verticalBlur2,vTexcoord_atlas.xy)) * (1.0 - texture2D(verticalBlur4,vTexcoord_atlas.xy));
	vec4 verticalBlurEighthWeightedColor = (1.0 - texture2D(verticalBlur8,vTexcoord_atlas.xy));
	// DUMMY OUTPUT: all fragments are OPAQUE PURPLE
	rtFragColor = composite;
}
