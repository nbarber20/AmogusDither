Shader "Amogus/AmogusDither"
{
    Properties
    {
        [NoScaleOffset]_MainTex("Texture", 2D) = "white" {}
        [NoScaleOffset]_DitherTex1("Dither Texture Low", 2D) = "white" {}
        [NoScaleOffset]_DitherTex2("Dither Texture Mid", 2D) = "white" {}
        [NoScaleOffset]_DitherTex3("Dither Texture High", 2D) = "white" {}
        _PixelScale("Pixel Scale", Float) = 1
        _DitherScale("Dither Scale", Float) = 1
        _DitherRangeLow("RangeLow", Float) = 0
        _DitherRangeHigh("RangeHigh", Float) = 0
        _Strength("Strength", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _DitherTex1;
            sampler2D _DitherTex2;
            sampler2D _DitherTex3;
            float _PixelScale;
            float _DitherScale;
            float _DitherRangeLow;
            float _DitherRangeHigh;
            float _Strength;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed3 frag(v2f i) : COLOR
            {
                float r = 5.0 / 4.0;
                float2 s = float2(_PixelScale * r, _PixelScale / r);
                float2 dUV = (i.uv * s - 0.5) * _DitherScale;

                float3 col = tex2D(_MainTex, round(i.uv * s) / s);
                float d1 = tex2D(_DitherTex1, dUV);
                float d2 = tex2D(_DitherTex2, dUV);
                float d3 = tex2D(_DitherTex3, dUV);

                float g = 1 - saturate((col.r + col.g + col.b) / 3.0);

                if (g <= lerp(_DitherRangeLow, _DitherRangeHigh, 0.25))
                {
                    return col;
                }

                float dither = 0.0;
                if (g <= lerp(_DitherRangeLow, _DitherRangeHigh, 0.5)) // 0.25 -> 0.5
                {
                    dither = d1;
                }
                else if (g <= lerp(_DitherRangeLow, _DitherRangeHigh, 0.75))  // 0.5 -> 0.75
                {
                    dither = d2;
                }
                else
                {
                    dither = d3;
                }

                if (dither == 0) //Not a dither pixel
                {
                    return col;
                }
                return saturate(col * col * dither * _Strength);
            }
            ENDCG
        }
    }
}
