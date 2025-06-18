Shader "SF_AoePack/Aoe_03_FireRay_01"
{
    Properties
    {
        _StepThreshold("Step Threshold",Range(0,1)) = 1
        [GAMMA][HDR]_ColorTint("Color Tint", color) = (1,1,1,1)
        _NoiseTex_01 ("Noise Texture_01", 2D) = "white" {}
        _Pow_01("Power_01", float) = 1
        _Panning_01("Panning Speed_01", vector) = (0,0,0,0)
        _NoiseTex_02("Noise Texture_02",2D ) = "white"{}
        _Pow_02("Power_02", float) = 1
        _Panning_02("Panning Speed_02", vector) = (0,0,0,0)
    }
        SubShader
    {
        Tags { "RenderType"="Opaque"  "Queue" ="Geometry"  }
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
            float4 _ColorTint;
            sampler2D _NoiseTex_01;
            float4 _NoiseTex_01_ST;
            sampler2D _NoiseTex_02;
            float4 _NoiseTex_02_ST;
            float _Pow_01;
            float _Pow_02;
            float4 _Panning_01;
            float4 _Panning_02;
            float _StepThreshold;
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
                float4 NoiseTex_01 = tex2D(_NoiseTex_01, (i.uv.xy * _NoiseTex_01_ST.xy)+_NoiseTex_01_ST.zw+age*_Panning_01.xy).r;
                float4 NoiseTex_02 = tex2D(_NoiseTex_02, (i.uv.xy * _NoiseTex_02_ST.xy)+_NoiseTex_02_ST.zw+age*_Panning_02.xy).r;
                float4 ClipMask = tex2D(_NoiseTex_01,(i.uv.xy *_NoiseTex_01_ST.xy)+_NoiseTex_01_ST.zw).r;
                float4 NoiseMultiply = saturate( pow(NoiseTex_01,_Pow_01)* pow(NoiseTex_02,_Pow_02));
                float4 NoiseClip = step(_StepThreshold,NoiseMultiply);
                clip(ClipMask- (1-i.uv.z*1.01));

                float4 Color = _ColorTint * i.vertexcolor;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = pow(Color,1.2);
                #endif
                
                return NoiseClip * Color;
            }
            ENDCG
        }
    }

    SubShader
    {
        PackageRequirements {"com.unity.render-pipelines.universal"}
        Tags { "RenderType"="Opaque"  "Queue" ="Geometry" "RenderPipeline" = "UniversalRenderPipeline" }
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
            float4 _ColorTint;
            sampler2D _NoiseTex_01;
            float4 _NoiseTex_01_ST;
            sampler2D _NoiseTex_02;
            float4 _NoiseTex_02_ST;
            float _Pow_01;
            float _Pow_02;
            float4 _Panning_01;
            float4 _Panning_02;
            float _StepThreshold;
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
                float4 NoiseTex_01 = tex2D(_NoiseTex_01, (i.uv.xy * _NoiseTex_01_ST.xy)+_NoiseTex_01_ST.zw+age*_Panning_01.xy).r;
                float4 NoiseTex_02 = tex2D(_NoiseTex_02, (i.uv.xy * _NoiseTex_02_ST.xy)+_NoiseTex_02_ST.zw+age*_Panning_02.xy).r;
                float4 ClipMask = tex2D(_NoiseTex_01,(i.uv.xy *_NoiseTex_01_ST.xy)+_NoiseTex_01_ST.zw).r;
                float4 NoiseMultiply = saturate( pow(NoiseTex_01,_Pow_01)* pow(NoiseTex_02,_Pow_02));
                float4 NoiseClip = step(_StepThreshold,NoiseMultiply);
                clip(ClipMask- (1-i.uv.z*1.01));

                float4 Color = _ColorTint * i.vertexcolor;
                
                #if UNITY_COLORSPACE_GAMMA
                Color = 0.9*pow((Color/0.9),1.8);
                #else
                Color = pow(Color,1.2);
                #endif
                
                return NoiseClip * Color;
            }
            ENDHLSL
        }
    }
}

