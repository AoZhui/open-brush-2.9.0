// Copyright 2020 The Tilt Brush Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

Shader "Unlit/Blended" {
Properties {
  _MainTex ("Texture", 2D) = "white" {}
}

Category {
  Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
  Blend SrcAlpha OneMinusSrcAlpha
  AlphaTest Greater .01
  ColorMask RGB
  Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }

  SubShader {
    Pass {

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile __ AUDIO_REACTIVE
      #include "UnityCG.cginc"
      #include "Assets/Shaders/Include/Brush.cginc"

      sampler2D _MainTex;

      struct appdata_t {
        float4 vertex : POSITION;
        fixed4 color : COLOR;
        float3 normal : NORMAL;
        float2 texcoord : TEXCOORD0;

        UNITY_VERTEX_INPUT_INSTANCE_ID
      };

      struct v2f {
        float4 vertex : POSITION;
        fixed4 color : COLOR;
        float2 texcoord : TEXCOORD0;

        UNITY_VERTEX_OUTPUT_STEREO
      };

      float4 _MainTex_ST;

      v2f vert (appdata_t v)
      {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
#ifdef AUDIO_REACTIVE
        o.color = musicReactiveColor(v.color, _BeatOutput.w);
        v.vertex = musicReactiveAnimation(v.vertex, v.color, _BeatOutput.w, o.texcoord.x);
#else
        o.color = v.color;
#endif
        o.vertex = UnityObjectToClipPos(v.vertex);

        return o;

      }

      fixed4 frag (v2f i) : COLOR
      {
         half4 c = tex2D(_MainTex, i.texcoord);
        // RGB output only, no HDR support.
        return i.color * c;
      }
      ENDCG
    }
  }
}
}