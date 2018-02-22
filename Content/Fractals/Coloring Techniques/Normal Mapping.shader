Shader "Fractals/Coloring Techniques/Normal Mapping"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Iter ("Iterations", Range(0, 250)) = 100
		_Dividend ("Dividend", Range (1, 100)) = 15
		
		_Zoom ("Zoom", Range (0.1, 1000)) = 0.65
		_Position ("Offset", Vector) = (0.4, 0, 0, 0)

		_Height ("Height", Range(0.1, 2)) = 1.5
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

			#define pi 3.141592
			#define black float4(0, 0, 0, 0)
			#define white float4(1, 1, 1, 1)

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

			sampler2D _MainTex;

			int _Iter;
			fixed _Zoom;
			fixed _Dividend;
			float2 _Position;
			float _Height;

			float CalculateLighting(in float2 z, in float2 der)
			{
				float v = exp(0 * 2 * pi/360);
				float2 u = cdiv(z, der);
				u = cdiv(u, cabs(u));

				float t = u.x * v + u.y * -v + _Height; //dot(u, v)*0.5+0.5 + _Height; //This also works
				t = t / (1 + _Height);

				t = max(t, 0);

				return t;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float x0 = (ClampScaleX(i.uv) + _Position.x) / _Zoom;
				float y0 = (ClampScaleY(i.uv) + _Position.y) / _Zoom;

				float2 der = float2(1, 1);
				float2 z = float2(x0, y0);
				float2 c = float2(x0, y0);

				int iteration = 0;
				while (IsBounded(z, 100) && iteration < _Iter)
				{
					der = 2 * cmul(der, z) + 1;	

					z = cmul(z, z);
					z += c;					

					iteration++;
				}

				if (iteration == _Iter)
					return white;
				else
					return lerp(black, white, CalculateLighting(z, der)); 
			}		    
			ENDCG
		}
	}
	CustomEditor "FractalEditor"
}
