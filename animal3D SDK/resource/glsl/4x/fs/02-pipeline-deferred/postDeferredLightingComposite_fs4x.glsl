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
	
	postDeferredLightingComposite_fs4x.glsl
	Composite results of light pre-pass in deferred pipeline.
*/

#version 450

// ****TO-DO:
//	-> declare samplers containing results of light pre-pass
//	-> declare samplers for texcoords, diffuse and specular maps
//	-> implement Phong sum with samples from the above
//		(hint: this entire shader is about sampling textures)

uniform int uCount;

uniform sampler2D uImage00; //diffuse atlas
uniform sampler2D uImage01; //specular atlas

uniform sampler2D uImage04; // textcoord g-buffer
uniform sampler2D uImage05; //normal g-buffer
uniform sampler2D uImage06; //position g-buffer
uniform sampler2D uImage07; //depth g-buffer
uniform sampler2D uImage08; //ligh prepass g-buffer

uniform mat4 uPB_inv; // inverse bias projection

in vec4 vTexcoord_atlas;

layout (location = 0) out vec4 rtFragColor;

void main()
{
	// grab diffuse and specular sample
	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 diffuseSample = texture(uImage00, sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01, sceneTexcoord.xy);
	
	//grap postion and do a perspective divide
	vec4 positon_screen = vTexcoord_atlas;
	positon_screen.z = texture(uImage07, sceneTexcoord.xy).r;

	vec4 position_view = uPB_inv * positon_screen;
	position_view /= position_view.w;
	//grab normal and position
	vec4 normal = texture(uImage05, vTexcoord_atlas.xy);
	normal = (normal - 0.5) * 2.0;

	positon_screen = texture(uImage08, sceneTexcoord.xy);

	rtFragColor = diffuseSample;
}
