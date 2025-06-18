Shader "SF_AoePack/Aoe_02_ExplosionBody_01"
{
    Properties
    {
        _NoiseTex_01 ("Noise Texture_01", 2D) = "white" {}
        _NoiseTex_02 ("Noise Texture_02", 2D) = "white" {}
        [GAMMA][HDR]_ColorTint("ColorTint", COLOR) = (1,1,1,1)
        _PanningSpeed("Panning Speed", vector) = (1,0.2,0,0)
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
            sampler2D _NoiseTex_01;
            float4 _NoiseTex_01_ST;
            sampler2D _NoiseTex_02;
            float4 _NoiseTex_02_ST;
            float4 _ColorTint;
            vector _PanningSpeed;
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
                float age = i.uv.z;
                float4 noise_01 = tex2D(_NoiseTex_01, (i.uv.xy*_NoiseTex_01_ST.xy)+_NoiseTex_01_ST.zw+ age * _PanningSpeed.xy);
                float4 noise_02 = tex2D(_NoiseTex_02, (i.uv.xy*_NoiseTex_02_ST.xy) +_NoiseTex_02_ST.zw - age *_PanningSpeed.xy);
                float4 tex =  noise_01 * noise_02;
                clip(tex - (1-i.uv.w));
                float3 Color =  _ColorTint.rgb * i.vertexcolor.rgb;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = 0.8*pow(Color,1.1);
                #endif
                
                float Alpha = _ColorTint.a * i.vertexcolor.a;
                return float4(Color,Alpha);
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
            sampler2D _NoiseTex_01;
            float4 _NoiseTex_01_ST;
            sampler2D _NoiseTex_02;
            float4 _NoiseTex_02_ST;
            float4 _ColorTint;
            vector _PanningSpeed;
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
                float age = i.uv.z;
                float4 noise_01 = tex2D(_NoiseTex_01, (i.uv.xy*_NoiseTex_01_ST.xy)+_NoiseTex_01_ST.zw+ age * _PanningSpeed.xy);
                float4 noise_02 = tex2D(_NoiseTex_02, (i.uv.xy*_NoiseTex_02_ST.xy) +_NoiseTex_02_ST.zw - age *_PanningSpeed.xy);
                float4 tex =  noise_01 * noise_02;
                clip(tex - (1-i.uv.w));
                float3 Color =  _ColorTint.rgb * i.vertexcolor.rgb;

                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = 0.8*pow(Color,1.1);
                #endif
                
                float Alpha = _ColorTint.a * i.vertexcolor.a;
                return float4(Color,Alpha);
            }
            ENDHLSL
        }
    }
}
