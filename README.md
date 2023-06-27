# Calc_Logistic_Dist
Generate a continuous distribution using p10, p50, p90 SME assessments composed of two piecewise logistic functions.

Analysts often need to generate a simulation of a continuous distribution across its entire domain in which the distribution is not specified by a known canonical distribution (e.g., a Gaussian distribution) but rather one that conforms to the uncertainty expressed by a subject matter expert (SME). In this case, the parameters for the distribution cannot be readily derived from a statistically informative empircal data set. Rather, the SME assesses three parameters of an eightieth percentile prediction interval (the p10, p50, and p90) of a cumulative probability function.

This <b>Calc_Logistic_Dist()</b> function provides a means to fit a continuous mapping function through the SME parameters based on two piecewise logistic functions. The following explains how this is achieved.

To begin, the logistic function is a symmetric sigmoid function takes the form

    Y = 1/(1 + exp(-g * (X - b))), where

* X has support in the domain of real numbers;
* Y takes on values in the interval (0, 1);
* b is a bias term that shifts the center of the sigmoid where X = p50 and Y = 0.5. The dy/dx function around this point of the sigmoid is symmetric;
* g is a shape factor that controls the slope of the sigmoid. The larger g is, the faster the sigmoid moves from 0 to 1.

Determining the value of g is a simple matter if b is known along with a tuple (X, Y). In this simple case, either the p10 or p90 will suffice to specifiy the g for a symmetric sigmoid.

    g = -ln(1/0.1 - 1) / (p10 - p50)
      = ln(9) / (p50 - p10), or
      
    g = -ln(1/0.9 - 1) / (p90 - p50)
      = ln(9) / (p90 - p50)

In the case that the SME assesses p10-p50-p90 values such that the distance from the p10 to the p50 is not equal to the distance from the p50 to the p90 (i.e., some hybrid sigmoid that is not symmetric around the p50), the prior solution for g will not work. This is because the shape factor for the lower half of the sigmoid will not be the same for the upper half.

A first approximate solution might be to find distinct shape factors for each half of the hybrid sigmoid.

    g1 = -ln(1/0.1 - 1) / (p10 - p50)
       = ln(9) / (p50 - p10), and
       
    g2 = -ln(1/0.9 - 1) / (p90 - p50)
       = ln(9) / (p90 - p50)

Then provide the piecewise function for the sigmoid as

    Y = 1/(1 + exp(-g * (X - p50))), where
        {g = g1 for X ≤ p50;
        g = g2 for X > p50}

Unfortunately, this approach creates a discontinuity at the p50 that becomes even more pronounced the as the disparity between the semi-distances of p50 - p10 and p90 - p50 increases.

The solution provided here incorporates a linear scaling between the shape factors such that the sigmoid remains continuous through all points regardless of the disparity between the semi-distances. However, the scaling cannot occur from the p10 to the p90. Care is taken to apply the scaling only between the p50 and the percentile parameter associated with the shortest semi-distance, that is, the section of the sigmoid with the higest slope. The following conditional applies.

    if |p10 - p50| > |p90 - p50| then
        min(g2, max(g1, g1 + 2.5 * (Y - 0.5) * |g1 - g2|))
    else  if |p10 - p50| < |p90 - p50| then
        min(g1, max(g2, g2 - 2.5 * (Y - 0.5) * |g1 - g2|))
    else g1 (or g2).

To run a simulaton with this approach, the logistic function is inverted to solve for X using samples drawn uniformly from the interval Y = (0, 1).

    X = -ln(1 / Y - 1) / g(Y) + p50
