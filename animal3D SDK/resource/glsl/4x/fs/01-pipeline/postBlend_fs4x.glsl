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

//Zachary Schwab
#version 450

// ****DONE:
//	-> declare texture coordinate varying and set of input textures
//	-> implement some sort of blending algorithm that highlights bright areas
//		(hint: research some Photoshop blend modes)

in vec4 vTexcoord_atlas;

layout (location = 0) out vec4 rtFragColor;

layout (binding = 0) uniform sampler2D sceneTexture;
layout (binding = 1) uniform sampler2D verticalBlur2;
layout (binding = 2) uniform sampler2D verticalBlur4;
layout (binding = 3) uniform sampler2D verticalBlur8;

void main()
{
	//grab the color of each frag from the 4 previous passes
	vec4 sceneColor = (1.0 - texture2D(sceneTexture,vTexcoord_atlas.xy));
	vec4 verticalBlur2Color = (1.0 - texture2D(verticalBlur2,vTexcoord_atlas.xy));
	vec4 verticalBlur4Color = (1.0 - texture2D(verticalBlur4,vTexcoord_atlas.xy));
	vec4 verticalBlur8Color = (1.0 - texture2D(verticalBlur8,vTexcoord_atlas.xy));
	vec4 composite = 1.0 - (sceneColor * verticalBlur2Color * verticalBlur4Color * verticalBlur8Color);	//composite them all together
	//output
	rtFragColor = composite;
}
