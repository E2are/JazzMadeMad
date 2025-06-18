Shader "SF_AoePack/Aoe_03_BottomFire_01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _dissolveGradient("Dissolve Gradient",2d) = "white"{}
        [GAMMA][HDR]_ColorTint("ColorTint", COLOR) = (1,1,1,1)
        _EdgeThickness("Edge Thickness", float) = 0.1
        _PanningSpeed("Panning Speed",vector) = (0,6.5,0,0)
        _gradientPower("Gradient Power", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout"  "Queue" ="AlphaTest"}
        Cull off
       
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
                float4 uv : TEXCOORD0;
                float4 vertexcolor : COLOR;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                    
                float4 vertex : SV_POSITION;

                float4 vertexcolor : COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _dissolveGradient;
            float4 _ColorTint;
            float _EdgeThickness;
            float4 _PanningSpeed;
            float _gradientPower;
            CBUFFER_END


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.vertexcolor = v.vertexcolor;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                
                float age = i.uv.w;

                float fireDissolve = -0.75 + (i.uv.z - 0) * (1 +0.75) / (1 - 0);
                
                float4 tex = saturate( tex2D(_MainTex,(i.uv.xy*_MainTex_ST.xy)+_MainTex_ST.zw - age *_PanningSpeed.xy ).r ) *0.9;
                
                float4 dGradient = saturate( tex2D(_dissolveGradient, i.uv.xy)).r*1.5;

                clip((1-step(tex, dGradient+fireDissolve-_EdgeThickness))-0.1);
                
                float4 Color =  _ColorTint * i.vertexcolor;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),2.5);
                #else
                Color = 1.5*pow(Color,1.5);
                #endif
                
                return saturate(step(tex, dGradient+fireDissolve)) * Color ;
                
            }
            ENDCG
        }
    }


    SubShader
    {
        PackageRequirements {"com.unity.render-pipelines.universal"}
        Tags { "RenderType"="TransparentCutout"  "Queue" ="AlphaTest" "RenderPipeline" = "UniversalRenderPipeline" }
        Cull off
       
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
                float4 uv : TEXCOORD0;
                float4 vertexcolor : COLOR;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                    
                float4 vertex : SV_POSITION;

                float4 vertexcolor : COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _dissolveGradient;
            float4 _ColorTint;
            float _EdgeThickness;
            float4 _PanningSpeed;
            float _gradientPower;
            CBUFFER_END


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                o.vertexcolor = v.vertexcolor;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                
                float age = i.uv.w;

                float fireDissolve = -0.75 + (i.uv.z - 0) * (1 +0.75) / (1 - 0);
                
                float4 tex = saturate( tex2D(_MainTex,(i.uv.xy*_MainTex_ST.xy)+_MainTex_ST.zw - age *_PanningSpeed.xy ).r ) *0.9;
                
                float4 dGradient = saturate( tex2D(_dissolveGradient, i.uv.xy)).r*1.5;

                clip((1-step(tex, dGradient+fireDissolve-_EdgeThickness))-0.1);
                
                float4 Color =  _ColorTint * i.vertexcolor;

                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),2.5);
                #else
                Color = 1.5*pow(Color,1.5);
                #endif
                
                return saturate(step(tex, dGradient+fireDissolve)) * Color ;
                
            }
            ENDHLSL
        }
    }
}
