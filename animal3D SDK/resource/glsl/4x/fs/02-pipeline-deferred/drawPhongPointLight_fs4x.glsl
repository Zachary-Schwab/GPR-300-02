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
	
	drawPhongPointLight_fs4x.glsl
	Output Phong shading components while drawing point light volume.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> declare biased clip coordinate varying from vertex shader
//	-> declare point light data structure and uniform block
//	-> declare pertinent samplers with geometry data ("g-buffers")
//	-> calculate screen-space coordinate from biased clip coord
//		(hint: perspective divide)
//	-> use screen-space coord to sample g-buffers
//	-> calculate view-space fragment position using depth sample
//		(hint: same as deferred shading)
//	-> calculate final diffuse and specular shading for current light only

struct sLights
{
	vec4 position;					// position in rendering target space
	vec4 worldPos;					// original position in world space
	vec4 color;						// RGB color with padding
	int radius;						// radius (distance of effect from center)
	int radiusSq;					// radius squared (if needed)
	int radiusInv;					// radius inverse (attenuation factor)
	int radiusInvSq;				// radius inverse squared (attenuation factor)
};

uniform ubo_light
{
	sLights lights[MAX_LIGHTS];
};

flat in int vInstanceID; //only this light

in vec4 vLightPosition;
in vec4 vNormal;
in vec4 vPosition_screen;

uniform sampler2D uImage00; //diffuse atlas
uniform sampler2D uImage04; //specular atlas

in vec4 vTexcoord_atlas;

layout (location = 0) out vec4 rtDiffuseLight;
layout (location = 1) out vec4 rtSpecularLight;

void calcPhongPoint(
	out vec4 diffuseColor, out vec4 specularColor,
	in vec4 eyeVec, in vec4 fragPos, in vec4 fragNrm, in vec4 fragColor,
	in vec4 lightPos, in vec4 lightRadiusInfo, in vec4 lightColor
);

void main()
{
	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 diffuseSample = texture(uImage00, sceneTexcoord.xy);

	rtDiffuseLight = vec4(0); 
	rtSpecularLight = vec4(0); 
	//calc and return phone fragment
	calcPhongPoint(rtDiffuseLight,rtSpecularLight, vPosition_screen, vPosition_screen / vPosition_screen.w, vNormal, diffuseSample,
		lights[vInstanceID].worldPos, vec4(lights[vInstanceID].radius), lights[vInstanceID].color);

}
