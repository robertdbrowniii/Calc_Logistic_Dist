#### ---- Piecewise Logistic Distribution ----
Calc_Logistic_Dist <-
  function(lb = -Inf,
           p10 = 10,
           p50 = 20,
           p90 = 40,
           ub = Inf,
           trials = 1000) {
    # Generate a sample of simulated percentiles of size trials from the uniform distribution.
    U <-  runif(trials, 0, 1)
    
    # Determine the 40th percentile semi-distances below and above the p50.
    semidist1050 <- p50 - p10
    semidist5090 <- p90 - p50
    
    # find growth factors for each semi-distance on either side of the p50 in the
    # case of an asymmetric assessment. If the semi-distances are equal, the g1050
    # will work for the whole function.
    g1050 <- log(9) / semidist1050
    g5090 <- log(9) / semidist5090
    
    # Generate the growth function over the range of U. The growth function will
    # be equal to the growth factor for the longest semi-distance up to the p50.
    # The growth function will converge linearly on the growth factor for the
    # shortest semi-distance from the p50.
    g <- sapply(U, function(u)
      (semidist1050 > semidist5090) * min(g5090, max(
        g1050, g1050 + 2.5 *
          (u - 0.5) * abs(g1050 - g5090)
      )) +
        (semidist1050 < semidist5090) * min(g1050, max(
          g5090, g5090 - 2.5 *
            (u - 0.5) * abs(g1050 - g5090)
        )) +
        (semidist1050 == semidist5090) * g1050)
    
    # Apply the growth function to the inverse logistic function in the place of
    # the normal growth factor used in symmetric logistic functions.
    X <-
      sapply(1:trials, function(t)
        min(ub, max(lb, -log(1 / U[t] - 1) / g[t] + p50)))
    
    return(X)
  }
