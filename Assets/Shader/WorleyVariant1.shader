Shader "Unlit/WorleyVariant1Noise"
{
   
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("Scale", Range(1, 12)) = 2
        _Periodic("Periodic", Range(2, 4)) = 2
        _FbmStep("FBM step", Range(1, 8)) = 4
        _Offset("Offset", float) = 0
        _Tilable("Tilable", float) = 0
        _FbmEnabled("_FbmEnabled", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Library/classicnoise.cginc"
            #include "Library/worleynoise.cginc"
            #include "Library/simpleNoise.cginc"

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
            float4 _MainTex_ST;
            float _Scale;
            float _Tilable;
            float _Periodic;
            float _EditorTime;
            float _FbmEnabled;
            float _FbmStep;
            float _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float2 random2( float2 p ) 
            {
                return frac(sin(float2(dot(p,float2(127.1,311.7)),dot(p,float2(269.5,183.3))))*43758.5453);
            }

            float fbm(float2 pos) {
                float total = 0.0;
                float factor = 1.0;
                for (int i = 0; i < floor(_FbmStep); ++i) {
                    factor *= 0.5;
                    float2 w = lerp(cellular(pos), cellular(pos, floor(pow(2,_Periodic)).xx), _Tilable);
                    float noise = w.x;
                    total += factor * noise;
                    pos *= 2.0;
                }
                return total;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 st = i.vertex.xy / pow(2, floor(_Scale));
                st += _Offset;
                if(_FbmEnabled > 0)
                {
                    return fbm(st);
                }

                float2 w = lerp(cellular(st), cellular(st, floor(pow(2,_Periodic)).xx), _Tilable);
                float noise = w.x;
                return noise;

            }
            ENDCG
        }
    } 
}
