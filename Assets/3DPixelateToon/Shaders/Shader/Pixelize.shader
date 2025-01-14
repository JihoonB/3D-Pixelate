Shader "Hidden/Pixelize"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white"
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        HLSLINCLUDE
        #pragma vertex vert
        #pragma fragment frag

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        struct Attributes
        {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct Varyings
        {
            float4 positionHCS : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        TEXTURE2D(_MainTex);
        float4 _MainTex_TexelSize;
        float4 _MainTex_ST;

        SamplerState sampler_point_clamp;

        uniform float2 _BlockCount;
        uniform float2 _BlockSize;
        uniform float2 _HalfBlockSize;

        Varyings vert(Attributes IN)
        {
            Varyings OUT;
            OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
            OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
            return OUT;
        }

        ENDHLSL

        Pass
        {
            Name "Pixelation"

            HLSLPROGRAM
            half4 frag(Varyings IN) : SV_TARGET
            {
                // Calculate the block position in the UV space
                float2 blockUV = IN.uv * _BlockCount;

                // Snap the block UV coordinates to the nearest integer
                float2 snappedBlockUV = floor(blockUV);

                // Calculate the center of the block
                float2 blockCenterUV = (snappedBlockUV + 0.5) / _BlockCount;

                // Sample the texture at the center of the block
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_point_clamp, blockCenterUV);

                return tex;
            }
            ENDHLSL
        }
    }
}
