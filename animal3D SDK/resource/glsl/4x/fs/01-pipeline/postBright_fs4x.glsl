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
	
	postBright_fs4x.glsl
	Bright pass filter.
*/

#version 450

// ****TO-DO:
//	-> declare texture coordinate varying and input texture
//	-> implement relative luminance function
//	-> implement simple "tone mapping" such that the brightest areas of the 
//		image are emphasized, and the darker areas get darker

//Zachary Schwab

layout (location = 0) out vec4 rtFragColor;

layout (binding = 0) uniform sampler2D hdr_image;

in vec4 vTextcoord_atlas;

void main()
{
	//formula taken from https://learnopengl.com/Advanced-Lighting/Bloom
	vec3 color = texelFetch(hdr_image, 2 * ivec2(gl_FragCoord.xy),0).rgb;
	//using color inherent brightness to the human eye determine how bright the color is.
	float brightness = dot(color.rgb,vec3(0.2126, 0.7152, 0.0722));
	vec4 brightPassColor;
	
	//if brightness is greater than one then multiply color by 2 and if its less than one then divide the color vector by 10

	float brightnessMultiplier = step(1,brightness);
	brightnessMultiplier = 2*brightnessMultiplier + -0.1 * brightnessMultiplier + 0.1;
	brightPassColor = vec4(color.rgb * brightnessMultiplier, 1.0);

	//output the dimmed or brightened color
	rtFragColor = brightPassColor;
}
