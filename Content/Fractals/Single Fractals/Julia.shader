Shader "Fractals/Single Fractals/Julia"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Iter ("Iterations", Range(0, 250)) = 100
		_Dividend ("Dividend", Range (1, 100)) = 15
		_Pow ("Power", Range (2, 5)) = 2
		
		_Zoom ("Zoom", Range (0.1, 1000)) = 0.65
		_Position ("Offset", Vector) = (0.7, 0, 0, 0)

		_Background ("Background", Color) = (0, 0.25, 1, 0)

		_Julia ("Julia", Vector) = (0.5, 0, 0, 0)
		[MaterialToggle] _JuliaSingle ("Julia Single", Float) = 0
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

			float2 _Julia;
			bool _JuliaSingle;

			int _Pow;

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

				float2 c;

				if (_JuliaSingle)
					c = _Julia.xx;
				else
					c = _Julia.xy;

				float2 z = float2(x0, y0);

				int iteration = 0;
				while (IsBounded(z, 4) && iteration < _Iter)
				{	
					z = cpow(z, _Pow);
					z += c;					
					iteration++;
				}

				return _Background * iteration / _Dividend;
			}		    
			ENDCG
		}
	}
	CustomEditor "FractalEditor"
}
