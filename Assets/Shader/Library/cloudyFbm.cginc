// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com
#include "common_func.cginc"

            float random (float2 pos) {
                return frac(sin(dot(pos.xy,
                                    float2(12.9898,78.233)))*
                    43758.5453123);
            }

            float randomP (float2 _st, float per) {
                return frac(sin(dot(mod(_st.xy, per),
                                    float2(12.9898,78.233)))*
                    43758.5453123);
            }

            float noiseP (float2 _st, float per) {
                float2 i = floor(_st);
                float2 f = frac(_st);

                // Four corners in 2D of a tile
                float a = randomP(i, per);
                float b = randomP(i + float2(1.0, 0.0), per);
                float c = randomP(i + float2(0.0, 1.0), per);
                float d = randomP(i + float2(1.0, 1.0), per);

                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(a, b, u.x) +
                        (c - a)* u.y * (1.0 - u.x) +
                        (d - b) * u.x * u.y;
            }

             float noise (float2 _st) {
                float2 i = floor(_st);
                float2 f = frac(_st);

                // Four corners in 2D of a tile
                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));

                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(a, b, u.x) +
                        (c - a)* u.y * (1.0 - u.x) +
                        (d - b) * u.x * u.y;
            }

            float fbmP ( float2 _st, float step, float per) {
                float v = 0.0;
                float a = 0.5;
                float2 shift = float2(100.0, 100.0);
                for (int i = 0; i < floor(step); ++i) {
                    v += a * noiseP(_st, per);
                    _st = 1. * _st * 2.0 + shift;
                    a *= 0.5;
                }
                return v;
            }

            float fbm ( float2 _st, float step) {
                float v = 0.0;
                float a = 0.5;
                float2 shift = float2(100.0, 100.0);
                for (int i = 0; i < floor(step); ++i) {
                    v += a * noise(_st);
                    _st = 1. * _st * 2.0 + shift;
                    a *= 0.5;
                }
                return v;
            }