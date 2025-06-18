// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "SF_AoePack/Aoe_03_FireCover_01"
{
    Properties
    {
        _FresnelPower("Fresnel Power", float) = 1
        [GAMMA][HDR]_ColorTint("ColorTint", COLOR) = (1,1,1,1)
        _NoiseTex("Noise Texture",2D) ="white"{}
        _Pow("Noise Power", float) = 1
        _PanningSpeed("Panning Speed",vector) = (0,0,0,0)
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
                float3 uv : TEXCOORD;
                float4 vertex : POSITION;
                float4 vertexcolor : COLOR;
                float3 normal : NORMAL;
                
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 vertexcolor : COLOR;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;

            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorTint;
            float _FresnelPower;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float4 _PanningSpeed;
            float _Pow;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.vertexcolor = v.vertexcolor;
                o.normal = mul(unity_ObjectToWorld, v.normal);
                o.normal = mul(unity_ObjectToWorld,v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz- mul(unity_ObjectToWorld,v.vertex).xyz);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float age = i.uv.z;
                float4 NoiseTex = tex2D(_NoiseTex,(i.uv.xy*_NoiseTex_ST.xy)+_NoiseTex_ST.zw + age *_PanningSpeed.xy);
                NoiseTex =  pow(NoiseTex,_Pow);
                float4 fresnelEffect = pow((1 - saturate(dot(normalize(i.normal), normalize(i.viewDir)))), _FresnelPower);
                float4 NoiseColor = (NoiseTex * _ColorTint * i.vertexcolor) +  _ColorTint * i.vertexcolor;
                float Alpha = _ColorTint.a * i.vertexcolor.a;  
                float3 Color = NoiseColor + NoiseColor*fresnelEffect;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = 2*pow(Color,1.7);
                Alpha = Alpha * (fresnelEffect+0.3);
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

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float3 uv : TEXCOORD;
                float4 vertex : POSITION;
                float4 vertexcolor : COLOR;
                float3 normal : NORMAL;
                
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 vertexcolor : COLOR;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;

            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorTint;
            float _FresnelPower;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float4 _PanningSpeed;
            float _Pow;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                o.vertexcolor = v.vertexcolor;
                o.normal = TransformObjectToWorldNormal(v.normal);     
                o.normal = mul(unity_ObjectToWorld,v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz- mul(unity_ObjectToWorld,v.vertex).xyz);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float age = i.uv.z;
                float4 NoiseTex = tex2D(_NoiseTex,(i.uv.xy*_NoiseTex_ST.xy)+_NoiseTex_ST.zw + age *_PanningSpeed.xy);
                NoiseTex =  pow(NoiseTex,_Pow);
                float4 fresnelEffect = pow((1 - saturate(dot(normalize(i.normal), normalize(i.viewDir)))), _FresnelPower);
                float4 NoiseColor = (NoiseTex * _ColorTint * i.vertexcolor) +  _ColorTint * i.vertexcolor;
                float Alpha = _ColorTint.a * i.vertexcolor.a;  
                float3 Color = NoiseColor + NoiseColor*fresnelEffect;

                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = 2*pow(Color,1.7);
                Alpha = Alpha * (fresnelEffect+0.3);
                #endif
                
                return float4(Color,Alpha);
                

                
            }
            ENDHLSL
        }
    }
}
