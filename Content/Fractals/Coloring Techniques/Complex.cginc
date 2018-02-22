float cabs (in float2 complex)
{
	float x = complex.x;
	float y = complex.y;

	return sqrt(x*x + y*y);
}

float2 csqrt (in float2 complex)
{
	float a = complex.x;
	float b = complex.y;
	if (b == 0)
		return float2(sqrt(a), 0);

	float real = sqrt ( (a + sqrt(a*a + b*b)) / 2);
	float imaginary = sign(b) * sqrt ( (-a + sqrt (a*a + b*b)) / 2  );

	return float2 (real, imaginary);
}

// Division's Formula:
// Real : (ac + bd) / (c*c + d*d)
// Imaginary : (bc - ad) / (c*c + d*d)
float2 cdiv (in float2 c1, in float2 c2)
{
	float a = c1.x;
	float b = c1.y;
	float c = c2.x;
	float d = c2.y;	

	float real = ((a * c) + (b * d)) / (c*c + d*d);
	float imaginary = ((b * c) - (a * d)) / (c*c + d*d);

	return float2 (real, imaginary);
}
			
//To get the conjugate of a Complex number, make the imaginary part equal to its simetric
float2 ConjugateComplex (in float2 c1)
{
	return float2(c1.x, -c1.y);
}

// The reciprocal or inverse of a complex number (1/C) is given by the expression
// Real : x / x^2 + y^2 
// Imaginary : - (y / x^2 + y^2)
float2 cinverse (in float2 c1)
{
	float x = c1.x;
	float y = c1.y;
				
	float real = x / ((x*x) + (y*y));

	float imaginary = y / ((x*x) + (y*y));

	return float2(real, -imaginary);
}

// (a, b) * (c, d) = (ac - bd, bc + ad)
float2 cmul (float2 c1, float2 c2)
{
	float a = c1.x;
	float b = c1.y;
	float c = c2.x;
	float d = c2.y;

	return float2 (a * c - b * d, b * c + a * d);
}

float2 cpow (float2 c, int exponent)
{
	float2 complex = c;

	if (exponent == 2)
		return cmul(c, c);

	for (int i = 0; i < abs(exponent) - 1; i++)
	{
		complex = cmul(c, complex);
	}

	if (exponent < 0)
	{
		complex = cinverse(complex);
	}
	return complex;
}

bool IsReal (float2 c1)
{
	return c1 == ConjugateComplex(c1);
}	
