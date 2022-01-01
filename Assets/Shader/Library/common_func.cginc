#ifndef COMMON_FUNC_INCLUDED
#define COMMON_FUNC_INCLUDED
float2 mod(float2 x, float y)
{
    return x - y * floor(x/y);
}

float3 mod(float3 x, float y)
{
    return x - y * floor(x/y);
}

float4 mod(float4 x, float y)
{
    return x - y * floor(x/y);
}
#endif //COMMON_FUNC_INCLUDED
