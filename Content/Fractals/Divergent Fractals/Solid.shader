Shader "NewtonComplex"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color1 ("Color 1", Color) = (1, 0, 0.7, 0)
		_Color2 ("Color 2", Color) = (1, 1, 0.1, 0)
		_Color3 ("Color 3", Color) = (0, 0.7, 1, 0)

		_Iter ("Iterations", Range(0, 250)) = 0
		_Zoom ("Zoom", Range (0.1, 1000)) = 1

		_Tolerance ("Tolerance", Range (0, 1)) = 0.0001
		_Position ("Offset", Vector) = (0, 0, 0, 0)
		_Background ("Background", Color) = (0, 0, 0, 0)
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
			fixed _Pow;
			fixed _Zoom;
			float2 _Position;

			float _Tolerance;

			fixed4 _Background;

			fixed4 _Color1;
			fixed4 _Color2;
			fixed4 _Color3;


			float2 Function (in float2 z)
			{
				return cpow(z, 3) - float2(1, 0);
			}

			float2 Derivatice (in float2 z)
			{
				return 3 * cmul(z, z); 
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

				float2 z = float2(x0, y0);

				float2 roots[3] = 
				{
					float2(1, 0), 
					float2(-.5, sqrt(3)/2), 
					float2(-.5, -sqrt(3)/2)
				};
				
				float4 colors[3] = 
				{
					_Color1, 
					_Color2, 
					_Color3
				};

				int iteration = 0;
				while (iteration < _Iter)
				{
					z -=  cdiv(Function(z), Derivatice(z));

					for (int i = 0; i < 3; i++)
					{
						if (hasConverged (z, roots[i], _Tolerance))
						{
							return colors[i];
						}						
					}
					iteration++;
				}
				
				return _Background;
			}		    
			ENDCG
		}
	}
	CustomEditor "FractalEditor"
}
