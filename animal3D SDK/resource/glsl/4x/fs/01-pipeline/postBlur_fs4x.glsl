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
	
	postBlur_fs4x.glsl
	Gaussian blur.
*/

#version 450

// ****TO-DO:
//	-> declare texture coordinate varying and input texture
//	-> declare sampling axis uniform (see render code for clue)
//	-> declare Gaussian blur function that samples along one axis
//		(hint: the efficiency of this is described in class)

//Zachary Schwab

in vec4 vTexcoord_atlas;

uniform vec2 uAxis;

layout (location = 0) out vec4 rtFragColor;
layout (binding = 0) uniform sampler2D hdr_image;
uniform float weight[5] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);



void main()
{
	//formula taken from https://learnopengl.com/Advanced-Lighting/Bloom modified by Zack
	//get texture size of single fragment
	vec2 texOffset = 1.0 / textureSize(hdr_image,0);
	//intial color value
	vec3 color = texture(hdr_image, vTexcoord_atlas.xy).rgb * weight[0];

	for(int i = 1; i < weight.length(); i++)
	{
		//combine the nearby pixels on a single axis by multiplying by the axis as one of the axis is set to 0;
		color += (texture(hdr_image, vTexcoord_atlas.xy + vec2(texOffset.x * i * uAxis.x, texOffset.y * i * uAxis.y)).rgb * weight[i]);
		color += (texture(hdr_image, vTexcoord_atlas.xy - vec2(texOffset.x * i * uAxis.x, texOffset.y * i * uAxis.y)).rgb * weight[i]);
	}

	//output blurred color
	rtFragColor = vec4(color,1.0);
}
