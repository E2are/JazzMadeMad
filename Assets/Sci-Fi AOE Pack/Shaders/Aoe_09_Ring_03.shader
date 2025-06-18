Shader "SF_AoePack/Aoe_09_Ring_03"
{
    Properties
    {
        [GAMMA][HDR]_ColorTint("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset]_MaskTex ("Mask Texture", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue" ="Transparent"}
        ZWrite off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
                float4 vertexcolor : COLOR;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 vertexcolor: COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorTint;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            CBUFFER_END


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertexcolor = v.vertexcolor;
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float charge = 0.1298701 + (i.uv.z) * (0.9610389 - 0.1298701);
                float4 col = tex2D(_MainTex, (i.uv.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
                float4 mask = saturate( tex2D(_MaskTex,(i.uv* _MainTex_ST.xy) + _MainTex_ST.zw));
                
                float3 Color = col.rgb * _ColorTint.rgb * i.vertexcolor.rgb;
                float Alpha = col.a * _ColorTint.a * i.vertexcolor.a;
                

                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow(abs(Color/0.9),1.8);
                #else
                Color = Color;
                #endif
                
                return  step(mask.r,charge) *float4(Color,Alpha) ;
                
                
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
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
                float4 vertexcolor : COLOR;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 vertexcolor: COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorTint;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            CBUFFER_END


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.vertexcolor = v.vertexcolor;
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float charge = 0.1298701 + (i.uv.z) * (0.9610389 - 0.1298701);
                float4 col = tex2D(_MainTex, (i.uv.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
                float4 mask = saturate( tex2D(_MaskTex,(i.uv* _MainTex_ST.xy) + _MainTex_ST.zw));
                
                float3 Color = col.rgb * _ColorTint.rgb * i.vertexcolor.rgb;
                float Alpha = col.a * _ColorTint.a * i.vertexcolor.a;

                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow(abs(Color/0.9),1.8);
                #else
                Color = Color;
                #endif
                
                return  step(mask.r,charge) *float4(Color,Alpha) ;
                
            }
            ENDHLSL
        }
    }
}

