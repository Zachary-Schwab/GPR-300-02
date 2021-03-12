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
	
	drawPhongNM_fs4x.glsl
	Output Phong shading with normal mapping.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> declare view-space varyings from vertex shader
//	-> declare point light data structure and uniform block
//	-> declare uniform samplers (diffuse, specular & normal maps)
//	-> calculate final normal by transforming normal map sample
//	-> calculate common view vector
//	-> declare lighting sums (diffuse, specular), initialized to zero
//	-> implement loop in main to calculate and accumulate light
//	-> calculate and output final Phong sum

uniform int uCount;

// location of viewer in its own space is the origin
const vec4 kEyePos_view = vec4(0.0, 0.0, 0.0, 1.0);

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

// declaration of Phong shading model
//	(implementation in "utilCommon_fs4x.glsl")
//		param diffuseColor: resulting diffuse color (function writes value)
//		param specularColor: resulting specular color (function writes value)
//		param eyeVec: unit direction from surface to eye
//		param fragPos: location of fragment in target space
//		param fragNrm: unit normal vector at fragment in target space
//		param fragColor: solid surface color at fragment or of object
//		param lightPos: location of light in target space
//		param lightRadiusInfo: description of light size from struct
//		param lightColor: solid light color
void calcPhongPoint(
	out vec4 diffuseColor, out vec4 specularColor,
	in vec4 eyeVec, in vec4 fragPos, in vec4 fragNrm, in vec4 fragColor,
	in vec4 lightPos, in vec4 lightRadiusInfo, in vec4 lightColor
);

layout (location = 0) out vec4 rtFragColor;

in vec4 vTexcoord_atlas;

vec4 diffuseColor = vec4(0);
vec4 SpecularColor = vec4(0);

uniform sampler2D uImage00; //diffuse atlas
uniform sampler2D uImage04; // textcoord g-buffer
uniform sampler2D uImage05; //normal g-buffer
uniform sampler2D uImage06; //position g-buffer

void main()
{

	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 color  = texture(uImage00, sceneTexcoord.xy);
	vec4 normal   = texture(uImage05, sceneTexcoord.xy);
	vec4 pos   = texture(uImage06, sceneTexcoord.xy);


	vec4 diffuseColorTemp;
	vec4 specularColorTemp;

	for(int i = 0; i < uCount; i++)
	{
		calcPhongPoint(diffuseColorTemp,specularColorTemp, kEyePos_view, pos, normal, color,
		lights[i].worldPos, vec4(lights[i].radius), lights[i].color);
		diffuseColor += diffuseColorTemp;
		SpecularColor += specularColorTemp;
	}
	diffuseColor /= uCount;
	diffuseColor = vec4(diffuseColor.rgb,1.0);
	SpecularColor /= uCount;
	SpecularColor = vec4(SpecularColor.rgb,1.0);

	rtFragColor = (diffuseColor + SpecularColor) /2;
}
