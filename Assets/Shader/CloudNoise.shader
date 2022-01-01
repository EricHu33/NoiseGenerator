Shader "Unlit/CloudNoise"
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
            #include "Library/cloudyFBM.cginc"

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

            fixed4 frag (v2f i) : SV_Target
            {
                float2 st = i.vertex.xy / pow(2, floor(_Scale));
                st += _Offset;
                // st += st * abs(sin(u_time*0.1)*3.0);
                if(_Tilable > 0)
                {
                    float2 q = float2(0. + _Offset, 0. +_Offset);
                    float per = pow(2, floor(_Periodic));
                    q.x += fbmP(st + 0.00*0, _FbmStep, per);
                    q.y += fbmP(st + float2(1.0, 1.0), _FbmStep, per);

                    float2 r = float2(0., 0.);
                    r.x = fbmP( st + 1.0*q, _FbmStep, per);
                    r.y = fbmP( st + 1.0*q, _FbmStep, per);

                    float f = fbmP(st+r + _EditorTime, _FbmStep, per);
                    return f;
                }
                else
                {
                    float2 q = float2(0. + _Offset, 0. +_Offset);
                    q.x += fbm(st + 0.00*0, _FbmStep);
                    q.y += fbm(st + float2(1.0, 1.0), _FbmStep);

                    float2 r = float2(0., 0.);
                    r.x = fbm( st + 1.0*q, _FbmStep);
                    r.y = fbm( st + 1.0*q, _FbmStep);

                    float f = fbm(st+r + _EditorTime, _FbmStep);
                    return f;
                }
            }
            ENDCG
        }
    } 
}