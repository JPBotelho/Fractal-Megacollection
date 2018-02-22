Shader "Fractals/Coloring Techniques/Pickover Stalk"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Iter ("Iterations", Range(0, 250)) = 100
		
		_Zoom ("Zoom", Range (0.1, 1000)) = .65
		_Position ("Offset", Vector) = (.4, 0, 0, 0)

		_TrapColor ("Trap Color", Color) = (0, 0.25, 1, 0)
		_Background ("Background", Color) = (1, 1, 1, 0)

		_OrbitPosition ("Orbit Position", Vector) = (0, 0, 0, 0)
		_OrbitDividend ("Orbit Dividend", Range (.05, 5)) = .05

		[MaterialToggle] _OrbitInside ("Orbit Inside Only", Float) = 0

		[MaterialToggle] _OrbitX ("Show Orbit X", Float) = 1
		[MaterialToggle] _OrbitY ("Show Orbit Y", Float) = 1
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
			fixed4 _TrapColor;

			float4 _OrbitPosition;

			bool _OrbitInside;
			bool _OrbitX;
			bool _OrbitY;
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

				while (IsBounded(z, 70) && iteration < _Iter)
				{					
					z = cmul(z, z);
					z += c;

					float distanceToTrap = abs(z.x + _OrbitPosition.x) + _OrbitPosition.z; //Vertical Axis
					float distanceToY = abs(z.y + _OrbitPosition.y) + _OrbitPosition.w; //Horizontal Axis

					if (_OrbitX == false)
					{
						distanceToTrap = 10000000;
					}
					if (_OrbitY == false)
					{
						distanceToY = 10000000;
					}

					distanceToTrap = min(distanceToTrap, distanceToY);
					
					trapDistance = min(trapDistance, distanceToTrap);

					iteration++;
				}

				if (_OrbitInside)
				{
					if (iteration == _Iter)
					{
						return trapDistance * _TrapColor / _OrbitDividend;
					}
					else
					{
						return _Background;
					}
				}
				else
				{
					return trapDistance * _TrapColor / _OrbitDividend;
				}	


				return _Background;
			}		    
			ENDCG
		}
	}
	CustomEditor "FractalEditor"
}
