Shader "Fractals/Coloring Techniques/Hue"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Iter ("Iterations", Range(0, 1000)) = 100
		_Dividend ("Dividend", Range (0.1, 10)) = 0.31
		
		_Zoom ("Zoom", Range (0.1, 1000)) = 0.65
		_Position ("Offset", Vector) = (0.4, 0, 0, 0)

		_Background ("Background", Color) = (0, 0.25, 1, 0)

		_Saturation ("Saturation", Range(0, 1)) = 1
		_Luminance ("Luminance", Range(0, 1)) = 1
	}	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Complex.cginc"
			#include "FractalOperations.cginc"

			#define black float4(0, 0, 0, 1)

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float3 hsv2rgb(float3 c)
			{
            	c = float3(c.x, clamp(c.yz, 0.0, 1.0));
            	float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            	float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
            	return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
            }

			sampler2D _MainTex;

			int _Iter;
			fixed _Zoom;
			fixed _Dividend;
			float2 _Position;
			fixed4 _Background;

			half _Saturation;
			half _Luminance;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float x0 = (ConvertRange(float2(0, 1), float2(-2.5, 1), i.uv.x) + _Position.x) / _Zoom;
				float y0 = (ConvertRange(float2(0, 1), float2(-1, 1), i.uv.y) + _Position.y) / _Zoom;

				float2 c = float2(x0, y0);
				float2 z = float2(x0, y0);

				int iteration = 0;
				while (IsBounded(z, 40) && iteration < _Iter)
				{	
					z = cmul(z, z);
					z += c;					

					iteration++;
				}


				if (iteration == _Iter)
				{
					float hue = atan (z.y/z.x);
					hue = ConvertRange (float2(0, 1), float2(0, _Dividend), hue);

					float3 hsl = hsv2rgb (float3(hue, _Saturation, _Luminance));

					return float4(hsl, 0);
				}
				else
				{
					return black;
				}
				//return _Background * iteration / _Dividend;
			}		    
			ENDCG
		}
	}
	CustomEditor "FractalEditor"
}
