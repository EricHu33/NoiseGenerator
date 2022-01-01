//
// GLSL textureless classic 2D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-08-22
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/stegu/webgl-noise
//
#include "common_func.cginc"

half4 fmod289(half4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

half4 permute(half4 x)
{
  return fmod289(((x*34.0)+10.0)*x);
}

half4 taylorInvSqrt(half4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

half2 fade(half2 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise
half cnoise(half2 P)
{
  half4 Pi = floor(P.xyxy) + half4(0.0, 0.0, 1.0, 1.0);
  half4 Pf = frac(P.xyxy) - half4(0.0, 0.0, 1.0, 1.0);
  Pi = fmod289(Pi); // To avoid truncation effects in permutation
  half4 ix = Pi.xzxz;
  half4 iy = Pi.yyww;
  half4 fx = Pf.xzxz;
  half4 fy = Pf.yyww;

  half4 i = permute(permute(ix) + iy);

  half4 gx = frac(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
  half4 gy = abs(gx) - 0.5 ;
  half4 tx = floor(gx + 0.5);
  gx = gx - tx;

  half2 g00 = half2(gx.x,gy.x);
  half2 g10 = half2(gx.y,gy.y);
  half2 g01 = half2(gx.z,gy.z);
  half2 g11 = half2(gx.w,gy.w);

  half4 norm = taylorInvSqrt(half4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;  
  g01 *= norm.y;  
  g10 *= norm.z;  
  g11 *= norm.w;  

  half n00 = dot(g00, half2(fx.x, fy.x));
  half n10 = dot(g10, half2(fx.y, fy.y));
  half n01 = dot(g01, half2(fx.z, fy.z));
  half n11 = dot(g11, half2(fx.w, fy.w));

  half2 fade_xy = fade(Pf.xy);
  half2 n_x = lerp(half2(n00, n01), half2(n10, n11), fade_xy.x);
  half n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

// Classic Perlin noise, periodic variant
half pnoise(half2 P, half2 rep)
{
  half4 Pi = floor(P.xyxy) + half4(0.0, 0.0, 1.0, 1.0);
  half4 Pf = frac(P.xyxy) - half4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, rep.xyxy); // To create noise with explicit period
  Pi = fmod289(Pi);        // To avoid truncation effects in permutation
  half4 ix = Pi.xzxz;
  half4 iy = Pi.yyww;
  half4 fx = Pf.xzxz;
  half4 fy = Pf.yyww;

  half4 i = permute(permute(ix) + iy);

  half4 gx = frac(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
  half4 gy = abs(gx) - 0.5 ;
  half4 tx = floor(gx + 0.5);
  gx = gx - tx;

  half2 g00 = half2(gx.x,gy.x);
  half2 g10 = half2(gx.y,gy.y);
  half2 g01 = half2(gx.z,gy.z);
  half2 g11 = half2(gx.w,gy.w);

  half4 norm = taylorInvSqrt(half4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;  
  g01 *= norm.y;  
  g10 *= norm.z;  
  g11 *= norm.w;  

  half n00 = dot(g00, half2(fx.x, fy.x));
  half n10 = dot(g10, half2(fx.y, fy.y));
  half n01 = dot(g01, half2(fx.z, fy.z));
  half n11 = dot(g11, half2(fx.w, fy.w));

  half2 fade_xy = fade(Pf.xy);
  half2 n_x = lerp(half2(n00, n01), half2(n10, n11), fade_xy.x);
  half n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}