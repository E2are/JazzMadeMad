Shader "SF_AoePack/Aoe_05_Geometry"
{
    Properties
    {
        _FresnelPower("Fresnel Power", float) = 1
        [GAMMA][HDR]_ColorTint("ColorTint", COLOR) = (1,1,1,1)
    }
        SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue" ="Transparent" }
        
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
                float4 vertexcolor : COLOR;
                float3 normal : NORMAL;
                
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 vertexcolor : COLOR;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD0;

            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorTint;
            float _FresnelPower;
            CBUFFER_END



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertexcolor = v.vertexcolor;
                o.normal = mul(unity_ObjectToWorld,v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz- mul(unity_ObjectToWorld,v.vertex).xyz);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                
                float4 fresnelEffect = pow((1 - saturate(dot(normalize(i.normal), normalize(i.viewDir)))), _FresnelPower);
                
                float3 Color = _ColorTint.rgb * i.vertexcolor.rgb;
                float Alpha = _ColorTint.a * i.vertexcolor.a;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = pow(Color,1.2);
                #endif
                
                return fresnelEffect *float4(Color,Alpha) ;
                

                
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
                float4 vertexcolor : COLOR;
                float3 normal : NORMAL;
                
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 vertexcolor : COLOR;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD0;

            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorTint;
            float _FresnelPower;
            CBUFFER_END



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.vertexcolor = v.vertexcolor;
                o.normal = TransformObjectToWorldNormal(v.normal);     
                o.normal = mul(unity_ObjectToWorld,v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz- mul(unity_ObjectToWorld,v.vertex).xyz);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                
                float4 fresnelEffect = pow((1 - saturate(dot(normalize(i.normal), normalize(i.viewDir)))), _FresnelPower);
                
                float3 Color = _ColorTint.rgb * i.vertexcolor.rgb;
                float Alpha = _ColorTint.a * i.vertexcolor.a;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = pow(Color,1.2);
                #endif
                
                return fresnelEffect *float4(Color,Alpha) ;
                

                
            }
            ENDHLSL
        }
    }
}
