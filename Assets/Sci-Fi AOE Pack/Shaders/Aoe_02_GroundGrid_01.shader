Shader "SF_AoePack/Aoe_02_GroundGrid_01"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        [GAMMA][HDR]_ColorTint("ColorTint", COLOR) = (1,1,1,1)
        _Intensity("Intensity", float) = 1
        _PanningSpeed("Panning Speed", float) = 1
        _MaskTex("Mask Texture", 2D) = "while" {}
        _MaskPower("Mask Power", float) = 1
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue" ="Transparent" }
        Cull off
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

                float4 vertexcolor : COLOR;
            };


            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorTint;
            float _Intensity;
            float _PanningSpeed;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _MaskPower;
            CBUFFER_END


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv =v.uv;
                o.vertexcolor = v.vertexcolor;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float age = i.uv.z;

                float4 masktex = tex2D(_MaskTex,i.uv.xy).r;
                float4 mask = pow(masktex, _MaskPower);
                i.uv.y = i.uv.y + age * _PanningSpeed;
                float4 col = tex2D(_MainTex, i.uv);
                
                float AlphaMask  = mask;

                float3 Color = col.rgb * _ColorTint.rgb * i.vertexcolor.rgb * _Intensity ;

                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = 0.9*Color;
                #endif
                
                float Alpha = col.a * _ColorTint.a * i.vertexcolor.a * _Intensity *AlphaMask;
                return float4(Color,Alpha);
            }
            ENDCG
        }
    }

    
    SubShader
    {
        PackageRequirements {"com.unity.render-pipelines.universal"}
        Tags { "RenderType"="Transparent"  "Queue" ="Transparent" "RenderPipeline" = "UniversalRenderPipeline" }
        Cull off
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

                float4 vertexcolor : COLOR;
            };


            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorTint;
            float _Intensity;
            float _PanningSpeed;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _MaskPower;
            CBUFFER_END


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv =v.uv;
                o.vertexcolor = v.vertexcolor;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float age = i.uv.z;

                float4 masktex = tex2D(_MaskTex,i.uv.xy).r;
                float4 mask = pow(masktex, _MaskPower);
                i.uv.y = i.uv.y + age * _PanningSpeed;
                float4 col = tex2D(_MainTex, i.uv);
                
                float AlphaMask  = mask;

                float3 Color = col.rgb * _ColorTint.rgb * i.vertexcolor.rgb * _Intensity ;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = 0.9*Color;
                #endif

                float Alpha = col.a * _ColorTint.a * i.vertexcolor.a * _Intensity *AlphaMask;
                return float4(Color,Alpha);
            }
            ENDHLSL
        }
    }
}
