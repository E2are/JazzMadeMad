Shader "Treasured/SeeThroughShader"
{
    Properties
    {
        [NoScaleOffset]_MainTexture("MainTexture", 2D) = "white" {}
        _Tint("Tint", Color) = (0, 0, 0, 0)
        _Position("PlayerPos", Vector) = (0.5, 0.5, 0, 0)
        _Size("Size", Float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Opacity("Opacity", Range(0, 1)) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW
        #pragma multi_compile_fragment _ _SHADOWS_SOFT_MEDIUM
        #pragma multi_compile_fragment _ _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_098944bc7b4c47b7905774b6dfd1e787_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTexture);
            float4 _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_098944bc7b4c47b7905774b6dfd1e787_Out_0_Texture2D.tex, _Property_098944bc7b4c47b7905774b6dfd1e787_Out_0_Texture2D.samplerstate, _Property_098944bc7b4c47b7905774b6dfd1e787_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_R_4_Float = _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4.r;
            float _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_G_5_Float = _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4.g;
            float _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_B_6_Float = _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4.b;
            float _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_A_7_Float = _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4.a;
            float4 _Property_56af4e133fd1451db72199e2ec065b98_Out_0_Vector4 = _Tint;
            float4 _Multiply_421723c1c8a246be856616e74dd2a0af_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4, _Property_56af4e133fd1451db72199e2ec065b98_Out_0_Vector4, _Multiply_421723c1c8a246be856616e74dd2a0af_Out_2_Vector4);
            float _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2 = _Position;
            float2 _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2;
            Unity_Remap_float2(_Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2);
            float2 _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2, _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2);
            float2 _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), float2 (1, 1), _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2, _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2);
            float2 _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2, float2(2, 2), _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2);
            float2 _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2, float2(1, 1), _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2);
            float _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float);
            float _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float = _Size;
            float _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float;
            Unity_Multiply_float_float(_Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float, _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float);
            float2 _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2 = float2(_Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float);
            float2 _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2, _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2, _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2);
            float _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float;
            Unity_Length_float2(_Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2, _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float);
            float _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float;
            Unity_OneMinus_float(_Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float, _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float);
            float _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float;
            Unity_Saturate_float(_OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float);
            float _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float, _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float);
            float _Property_88a620822d5647078d135b4cb180556e_Out_0_Float = _Opacity;
            float _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float, _Property_88a620822d5647078d135b4cb180556e_Out_0_Float, _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float);
            float _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            Unity_OneMinus_float(_Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float, _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = (_Multiply_421723c1c8a246be856616e74dd2a0af_Out_2_Vector4).x;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW
        #pragma multi_compile_fragment _ _SHADOWS_SOFT_MEDIUM
        #pragma multi_compile_fragment _ _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_098944bc7b4c47b7905774b6dfd1e787_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTexture);
            float4 _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_098944bc7b4c47b7905774b6dfd1e787_Out_0_Texture2D.tex, _Property_098944bc7b4c47b7905774b6dfd1e787_Out_0_Texture2D.samplerstate, _Property_098944bc7b4c47b7905774b6dfd1e787_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_R_4_Float = _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4.r;
            float _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_G_5_Float = _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4.g;
            float _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_B_6_Float = _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4.b;
            float _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_A_7_Float = _SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4.a;
            float4 _Property_56af4e133fd1451db72199e2ec065b98_Out_0_Vector4 = _Tint;
            float4 _Multiply_421723c1c8a246be856616e74dd2a0af_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f6c354f1143d4f00a3ce3e859951ce19_RGBA_0_Vector4, _Property_56af4e133fd1451db72199e2ec065b98_Out_0_Vector4, _Multiply_421723c1c8a246be856616e74dd2a0af_Out_2_Vector4);
            float _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2 = _Position;
            float2 _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2;
            Unity_Remap_float2(_Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2);
            float2 _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2, _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2);
            float2 _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), float2 (1, 1), _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2, _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2);
            float2 _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2, float2(2, 2), _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2);
            float2 _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2, float2(1, 1), _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2);
            float _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float);
            float _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float = _Size;
            float _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float;
            Unity_Multiply_float_float(_Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float, _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float);
            float2 _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2 = float2(_Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float);
            float2 _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2, _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2, _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2);
            float _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float;
            Unity_Length_float2(_Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2, _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float);
            float _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float;
            Unity_OneMinus_float(_Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float, _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float);
            float _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float;
            Unity_Saturate_float(_OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float);
            float _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float, _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float);
            float _Property_88a620822d5647078d135b4cb180556e_Out_0_Float = _Opacity;
            float _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float, _Property_88a620822d5647078d135b4cb180556e_Out_0_Float, _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float);
            float _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            Unity_OneMinus_float(_Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float, _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = (_Multiply_421723c1c8a246be856616e74dd2a0af_Out_2_Vector4).x;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2 = _Position;
            float2 _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2;
            Unity_Remap_float2(_Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2);
            float2 _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2, _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2);
            float2 _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), float2 (1, 1), _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2, _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2);
            float2 _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2, float2(2, 2), _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2);
            float2 _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2, float2(1, 1), _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2);
            float _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float);
            float _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float = _Size;
            float _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float;
            Unity_Multiply_float_float(_Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float, _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float);
            float2 _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2 = float2(_Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float);
            float2 _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2, _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2, _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2);
            float _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float;
            Unity_Length_float2(_Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2, _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float);
            float _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float;
            Unity_OneMinus_float(_Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float, _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float);
            float _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float;
            Unity_Saturate_float(_OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float);
            float _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float, _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float);
            float _Property_88a620822d5647078d135b4cb180556e_Out_0_Float = _Opacity;
            float _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float, _Property_88a620822d5647078d135b4cb180556e_Out_0_Float, _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float);
            float _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            Unity_OneMinus_float(_Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float, _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float);
            surface.Alpha = _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2 = _Position;
            float2 _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2;
            Unity_Remap_float2(_Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2);
            float2 _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2, _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2);
            float2 _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), float2 (1, 1), _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2, _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2);
            float2 _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2, float2(2, 2), _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2);
            float2 _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2, float2(1, 1), _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2);
            float _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float);
            float _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float = _Size;
            float _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float;
            Unity_Multiply_float_float(_Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float, _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float);
            float2 _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2 = float2(_Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float);
            float2 _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2, _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2, _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2);
            float _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float;
            Unity_Length_float2(_Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2, _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float);
            float _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float;
            Unity_OneMinus_float(_Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float, _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float);
            float _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float;
            Unity_Saturate_float(_OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float);
            float _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float, _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float);
            float _Property_88a620822d5647078d135b4cb180556e_Out_0_Float = _Opacity;
            float _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float, _Property_88a620822d5647078d135b4cb180556e_Out_0_Float, _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float);
            float _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            Unity_OneMinus_float(_Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float, _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2 = _Position;
            float2 _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2;
            Unity_Remap_float2(_Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2);
            float2 _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2, _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2);
            float2 _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), float2 (1, 1), _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2, _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2);
            float2 _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2, float2(2, 2), _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2);
            float2 _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2, float2(1, 1), _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2);
            float _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float);
            float _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float = _Size;
            float _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float;
            Unity_Multiply_float_float(_Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float, _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float);
            float2 _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2 = float2(_Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float);
            float2 _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2, _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2, _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2);
            float _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float;
            Unity_Length_float2(_Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2, _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float);
            float _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float;
            Unity_OneMinus_float(_Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float, _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float);
            float _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float;
            Unity_Saturate_float(_OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float);
            float _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float, _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float);
            float _Property_88a620822d5647078d135b4cb180556e_Out_0_Float = _Opacity;
            float _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float, _Property_88a620822d5647078d135b4cb180556e_Out_0_Float, _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float);
            float _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            Unity_OneMinus_float(_Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float, _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2 = _Position;
            float2 _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2;
            Unity_Remap_float2(_Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2);
            float2 _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2, _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2);
            float2 _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), float2 (1, 1), _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2, _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2);
            float2 _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2, float2(2, 2), _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2);
            float2 _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2, float2(1, 1), _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2);
            float _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float);
            float _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float = _Size;
            float _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float;
            Unity_Multiply_float_float(_Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float, _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float);
            float2 _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2 = float2(_Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float);
            float2 _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2, _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2, _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2);
            float _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float;
            Unity_Length_float2(_Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2, _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float);
            float _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float;
            Unity_OneMinus_float(_Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float, _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float);
            float _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float;
            Unity_Saturate_float(_OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float);
            float _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float, _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float);
            float _Property_88a620822d5647078d135b4cb180556e_Out_0_Float = _Opacity;
            float _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float, _Property_88a620822d5647078d135b4cb180556e_Out_0_Float, _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float);
            float _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            Unity_OneMinus_float(_Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float, _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float);
            surface.Alpha = _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2 = _Position;
            float2 _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2;
            Unity_Remap_float2(_Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2);
            float2 _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2, _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2);
            float2 _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), float2 (1, 1), _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2, _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2);
            float2 _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2, float2(2, 2), _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2);
            float2 _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2, float2(1, 1), _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2);
            float _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float);
            float _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float = _Size;
            float _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float;
            Unity_Multiply_float_float(_Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float, _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float);
            float2 _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2 = float2(_Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float);
            float2 _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2, _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2, _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2);
            float _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float;
            Unity_Length_float2(_Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2, _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float);
            float _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float;
            Unity_OneMinus_float(_Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float, _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float);
            float _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float;
            Unity_Saturate_float(_OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float);
            float _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float, _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float);
            float _Property_88a620822d5647078d135b4cb180556e_Out_0_Float = _Opacity;
            float _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float, _Property_88a620822d5647078d135b4cb180556e_Out_0_Float, _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float);
            float _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            Unity_OneMinus_float(_Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float, _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float);
            surface.Alpha = _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2 = _Position;
            float2 _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2;
            Unity_Remap_float2(_Property_77c92307dfff43bab7febc0571da5623_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2);
            float2 _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), _Remap_8204c84c0342493fb0d0450f944b6213_Out_3_Vector2, _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2);
            float2 _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_44b6d2759f7b407e85322b09c280eb48_Out_0_Vector4.xy), float2 (1, 1), _Add_b1b405e4966f47cfa3462c27a7cad2ec_Out_2_Vector2, _TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2);
            float2 _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_affd4dc6fc7744c6a400e60574380278_Out_3_Vector2, float2(2, 2), _Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2);
            float2 _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_cc10db06c7ac4930b30cf0c926788c20_Out_2_Vector2, float2(1, 1), _Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2);
            float _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float);
            float _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float = _Size;
            float _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float;
            Unity_Multiply_float_float(_Divide_2a3e5fb322ba403b93a5566ee1ac6af9_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float, _Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float);
            float2 _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2 = float2(_Multiply_61a192fe05614a33ac83177cc16b0d44_Out_2_Float, _Property_670e99e6d06a4098a622e85e6c590473_Out_0_Float);
            float2 _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_fb7ac92a9e054417a6261700fc9b16ed_Out_2_Vector2, _Vector2_e1e0bf0cd9eb4298b941975725050595_Out_0_Vector2, _Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2);
            float _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float;
            Unity_Length_float2(_Divide_38c5ef936d0f40d5b0b4ef55f2ccc41f_Out_2_Vector2, _Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float);
            float _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float;
            Unity_OneMinus_float(_Length_1fc34dd3eb4c4e59bbf3b70fe08ed0eb_Out_1_Float, _OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float);
            float _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float;
            Unity_Saturate_float(_OneMinus_5d40fbb4cf2e4623a7f9ddfc393df3cc_Out_1_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float);
            float _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_d051df7abe1041ef94db639a46691b21_Out_0_Float, _Saturate_2a5aec9c6ff849a88be2b70d50fc4668_Out_1_Float, _Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float);
            float _Property_88a620822d5647078d135b4cb180556e_Out_0_Float = _Opacity;
            float _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_135212f7ede244498a8cb19d6d31b9cf_Out_3_Float, _Property_88a620822d5647078d135b4cb180556e_Out_0_Float, _Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float);
            float _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            Unity_OneMinus_float(_Multiply_5131c32818654722b45ee7b4041c68a9_Out_2_Float, _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Alpha = _OneMinus_d6cbf923ccbb41b7ac6e20f3bb816e10_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}