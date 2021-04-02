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
	
	passColor_interp_tes4x.glsl
	Pass color, outputting result of interpolation.
*/

#version 450

// ****DONE: 
//	-> declare uniform block for spline waypoint and handle data
//	-> implement spline interpolation algorithm based on scene object's path
//	-> interpolate along curve using correct inputs and project result

layout (isolines, equal_spacing) in;

uniform ubCurve
{
	vec4 uCurveWaypoint[32];
	vec4 uCurveTangent[32];
};

uniform int uCount;

uniform mat4 uP;

mat4 Mcr = mat4(0,-1,2,-1,
			2,0,-5,3,
			0,1,4,-3,
			0,0,-1,1);
			

out vec4 vColor;

void main()
{
	int i0 = gl_PrimitiveID;
	int i1 = (i0 + 1) % uCount;
	float t = gl_TessCoord.x;
	float h00 = 1 - 3*t*t + 2*t*t*t;
	float h10 = t - 2*t*t + t*t*t;
	float h01 = 3*t*t - 2*t*t*t;
	float h11 = -t*t + t*t*t;
	vec4 p = h00*t* uCurveWaypoint[i0] + h10 * t * uCurveTangent[i0] + h01 * t * uCurveWaypoint[i1] + h11 * t * uCurveTangent[i1];

	gl_Position = uP*p;

	vColor = vec4(0.5,0.5, t, 1.0);
}
