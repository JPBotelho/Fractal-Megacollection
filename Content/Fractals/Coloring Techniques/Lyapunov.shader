Shader "Fractals/Coloring Techniques/Escape-Time"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Iter ("Iterations", Range(0, 250)) = 100
		_Dividend ("Dividend", Range (0, 0.5)) = 15
		
		_Zoom ("Zoom", Range (0.1, 1000)) = 0.65
		_Position ("Offset", Vector) = (0.4, 0, 0, 0)

		_Background ("Background", Color) = (0, 0.25, 1, 0)
		_Origin ("Origin", Color) = (0, 0, 0, 0)
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
			fixed4 _Background;
			fixed4 _Origin;

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
				
				float2 z = float2(x0, y0);
				float2 c = float2(x0, y0);
				
				int iteration = 0;

				float l = 0;

				while (IsBounded(z, 40) && iteration < _Iter)
				{	
					l += log (cabs(2 * z));

					z = cmul(z, z);
					z += c;					

					iteration++;
				}

				l /= iteration;

				if (l > 0)
					return _Background;

                float3 color = tanh(l >= 0 ? 
											float3(0, 0.7 * log(1 + l), log(1 + l)) : 
											3 * float3(_Origin.x-l, _Origin.y-l * 0.1, _Origin.z));

				return float4(color + _Dividend, 1);


			}		    
			ENDCG
		}
	}
	CustomEditor "FractalEditor"
}
