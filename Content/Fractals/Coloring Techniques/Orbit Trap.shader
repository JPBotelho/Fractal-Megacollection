Shader "Fractals/Coloring Techniques/Orbit Trap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Iter ("Iterations", Range(0, 250)) = 100
		
		_Zoom ("Zoom", Range (0.1, 1000)) = .65
		_Position ("Offset", Vector) = (0.4, 0, 0, 0)

		_Background ("Background", Color) = (0, 0.25, 1, 0)

		_OrbitPosition ("Orbit Position", Vector) = (0, 0, 0, 0)
		_OrbitDividend ("Orbit Dividend", Range (.1, 5)) = 0.1
	}	
	SubShader
	{
		// No culling or depth
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
			float2 _Position;

			fixed4 _Background;
			float2 _OrbitPosition;

			fixed _OrbitDividend;



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

				float trapDistance = 1000000;
				int iteration = 0;
				while (IsBounded(z, 4) && iteration < _Iter)
				{					
					z = cmul(z, z);
					z += c;					
				
					float distanceToTrap = distanceToOrbit (z, _OrbitPosition.xy);

					if (distanceToTrap < trapDistance)
						trapDistance = distanceToTrap;

					iteration++;
				}

				return trapDistance * _Background / _OrbitDividend;
			}		    
			ENDCG
		}
	}
	CustomEditor "FractalEditor"
}
