Shader "SF_AoePack/Aoe_06_ObjectFormation"
{
    Properties
    {
        [GAMMA][HDR]_ColorTint("Color Tint", color) = (1,1,1,1)
        _MinHeight("Minimum Height", float) = 0
        _MaxHeight("Maximum Height", float) = 1
        _EdgeThickness("Edge Thickness",float) = 0
        _FresnelPower("Fresnel Power", float) = 1
        [HideInInspector]_Position("Position", vector) = (0,0,0,0)
    }
        SubShader
    {
        Tags { "RenderType"="Opaque"   }
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
                float3 normals : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 Object : TEXCOORD1;
                float4 vertexcolor : COLOR;
                float3 normals : NORMAL;
                float3 viewDir : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorTint;
            float _MinHeight;
            float _MaxHeight;
            float _EdgeThickness;
            float _FresnelPower;
            float4 _Position;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.vertexcolor = v.vertexcolor;
                o.Object = mul(unity_ObjectToWorld, v.vertex);
                o.normals = mul(unity_ObjectToWorld, v.normals);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz- mul(unity_ObjectToWorld,v.vertex).xyz);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float VPosition = _Position.y;
                float4 fresnelEffect = pow((1 - saturate(dot(normalize(i.normals), normalize(i.viewDir)))), _FresnelPower);

                float FormationGradient =  (i.Object.y + 0.5 ) - VPosition;

                float Threshold = _MinHeight + (i.uv.x ) * (_MaxHeight - _MinHeight) / (1);

                clip(Threshold- (FormationGradient));
                float4 Color = i.vertexcolor * _ColorTint;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = 0.5*pow(Color,1.2);
                #endif
                
                return  saturate( (step(Threshold-_EdgeThickness ,FormationGradient) +fresnelEffect/2)) * Color ;
            }
            ENDCG
        }
    }
    SubShader
    {
        PackageRequirements {"com.unity.render-pipelines.universal"}
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalRenderPipeline"  }
        LOD 100
        Cull off    

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexcolor : COLOR;
                float3 normals : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 Object : TEXCOORD1;
                float4 vertexcolor : COLOR;
                float3 normals : NORMAL;
                float3 viewDir : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorTint;
            float _MinHeight;
            float _MaxHeight;
            float _EdgeThickness;
            float _FresnelPower;
            float4 _Position;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                o.vertexcolor = v.vertexcolor;
                o.Object = mul(unity_ObjectToWorld, v.vertex);
                o.normals = mul(unity_ObjectToWorld, v.normals);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz- mul(unity_ObjectToWorld,v.vertex).xyz);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float VPosition = _Position.y;
                float4 fresnelEffect = pow((1 - saturate(dot(normalize(i.normals), normalize(i.viewDir)))), _FresnelPower);

                float FormationGradient =  (i.Object.y + 0.5 ) - VPosition;

                float Threshold = _MinHeight + (i.uv.x ) * (_MaxHeight - _MinHeight) / (1);

                clip(Threshold- (FormationGradient));
                float4 Color = i.vertexcolor * _ColorTint;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = 0.5*pow(Color,1.2);
                #endif
                
                return  saturate( (step(Threshold-_EdgeThickness ,FormationGradient) +fresnelEffect/2)) * Color ;
            }
            ENDHLSL
        }
    }
}
