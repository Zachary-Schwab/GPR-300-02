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
	
	postDeferredShading_fs4x.glsl
	Calculate full-screen deferred Phong shading.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> this one is pretty similar to the forward shading algorithm (Phong NM) 
//		except it happens on a plane, given images of the scene's geometric 
//		data (the "g-buffers"); all of the information about the scene comes 
//		from screen-sized textures, so use the texcoord varying as the UV
//	-> declare point light data structure and uniform block
//	-> declare pertinent samplers with geometry data ("g-buffers")
//	-> use screen-space coord (the inbound UV) to sample g-buffers
//	-> calculate view-space fragment position using depth sample
//		(hint: modify screen-space coord, use appropriate matrix to get it 
//		back to view-space, perspective divide)
//	-> calculate and accumulate final diffuse and specular shading

struct sLights
{
	vec4 position;					// position in rendering target space
	vec4 worldPos;					// original position in world space
	vec4 color;						// RGB color with padding
	int radius;						// radius (distance of effect from center)
	int radiusSq;					// radius squared (if needed)
	int radiusInv;					// radius inverse (attenuation factor)
	int radiusInvSq;					// radius inverse squared (attenuation factor)
};

uniform ubo_light
{
	sLights lights[MAX_LIGHTS];
};


in vec4 vTexcoord_atlas;

uniform int uCount;

uniform sampler2D uImage00; //diffuse atlas
uniform sampler2D uImage01; //specular atlas

uniform sampler2D uImage04; // textcoord g-buffer
uniform sampler2D uImage05; //normal g-buffer
uniform sampler2D uImage06; //position g-buffer
uniform sampler2D uImage07; //depth g-buffer

uniform mat4 uPB_inv; // inverse bias projection

layout (location = 0) out vec4 rtFragColor;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE ORANGE
	//rtFragColor = vec4(1.0, 0.5, 0.0, 1.0);
	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 diffuseSample = texture(uImage00, sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01, sceneTexcoord.xy);

	vec4 positon_screen = vTexcoord_atlas;
	positon_screen.z = texture(uImage07, sceneTexcoord.xy).r;

	vec4 position_view = uPB_inv * positon_screen;
	position_view /= position_view.w;

	vec4 normal = texture(uImage05, vTexcoord_atlas.xy);
	normal = (normal - 0.5) * 2.0;

	rtFragColor = diffuseSample;
	rtFragColor.a = diffuseSample.a;
}
