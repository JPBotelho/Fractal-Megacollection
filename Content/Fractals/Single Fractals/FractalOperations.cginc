// Conditions for the while loops to break

bool IsBounded (float2 z, float bailout)
{
	return (z.x * z.x + z.y * z.y < bailout);
}

bool hasConverged (float2 z, float2 root, float tolerance)
{
	float2 difference = z - root;

	return (abs(difference.x) < tolerance && abs(difference.y) < tolerance);
}

float distanceToOrbit (float2 z, float2 trap)
{
	return cabs(z - trap);
}

// Fractal-specific iteration formulas

float2 BurningShip (float2 z)
{
	return cpow(abs(z), 2) * float2 (1, -1);
}

float2 Tricorn (float2 z, float power)
{
	float2 c = ConjugateComplex(z);
	return cpow(c, power);
}

float2 Mandelbrot (float2 z, float power)
{
	return cpow(z, power);
}

// Coordinate Clamping

float CalcPercent(in float min, in float max, in float input)
{
	return ((input - min) * 100 ) / (max-min);
}

float ValueFromPercent (in float min, in float max, in float percent)
{
	return (percent * (max - min) / 100) + min;
}

float ConvertRange (in float2 originalRange, in float2 targetRange, in float value)
{
	float originalPercentage = CalcPercent (originalRange.x, originalRange.y, value);
	return ValueFromPercent (targetRange.x, targetRange.y, originalPercentage);
}	

float2 ClampScaleX(in float2 uv)
{
	return ConvertRange(float2(0, 1), float2(-2.5, 1), uv.x);
}

float2 ClampScaleY (in float2 uv)
{
	return ConvertRange(float2(0, 1), float2(-1, 1), uv.y);
}

// Coloring functions (smooth)

float rounddown (in float value)
{
	float roundV = round (value);

	return roundV > value ? round (value - 0.5) : roundV;
}

float LinearColoring (in float2 z, in int iteration, in float power)
{
	return iteration + 1 - log( log ( cabs(z) )   ) / log (rounddown(power));
}

float4 newtonColor (in float smoothIndex, in int channel)
{
	float4 color;

	color[channel] = smoothIndex;

	return color;
}