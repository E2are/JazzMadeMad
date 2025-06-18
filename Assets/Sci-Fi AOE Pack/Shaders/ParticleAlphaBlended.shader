Shader "SF_AoePack/ParticleAlphaBlended"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [GAMMA][HDR]_ColorTint("Color Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue" ="Transparent"}
        ZWrite off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Cull off
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
                float4 vertexcolor : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 vertexcolor: COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorTint;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertexcolor = v.vertexcolor;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float3 Color = col.rgb * _ColorTint.rgb * i.vertexcolor.rgb;
                float Alpha = col.a * _ColorTint.a * i.vertexcolor.a;
                
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow(abs(Color/0.9),1.8);
                #else
                Color = 0.6*pow(abs(Color),1.1);
                #endif
                
                return float4(Color,Alpha);

            }
            ENDCG
        }
    }
    SubShader
    {
        PackageRequirements {"com.unity.render-pipelines.universal"}
        Tags { "RenderType"="Transparent"  "Queue" ="Transparent" "RenderPipeline" = "UniversalRenderPipeline" }
        ZWrite off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Cull off
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexcolor : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 vertexcolor: COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorTint;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertexcolor = v.vertexcolor;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float3 Color = col.rgb * _ColorTint.rgb * i.vertexcolor.rgb;
                float Alpha = col.a * _ColorTint.a * i.vertexcolor.a;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow(abs(Color/0.9),1.8);
                #else
                Color = 0.6*pow(abs(Color),1.1);
                #endif


                
                return float4(Color,Alpha);
            }
            ENDHLSL
        }
    }
}

