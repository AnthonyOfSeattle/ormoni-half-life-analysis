#' Fit a two-phase (bi-exponential) decay: y = baseline + A1*exp(-k1*x) + A2*exp(-k2*x)
#'
#' baseline is a fixed offset you supply (not estimated), e.g. an assay LOD
#' or pre-dose blank. halflife1/halflife2 are optional: if given, that
#' component's rate constant is fixed rather than fit, which is useful when
#' you already know (or want to force) one phase's half-life.
fit_two_phase_decay <- function(x, y, baseline = 0,
                                halflife1 = NULL, halflife2 = NULL,
                                start = list(),
                                control = nls.control(maxiter = 200)) {
  keep <- is.finite(x) & is.finite(y)
  df <- data.frame(x = x[keep], y = y[keep])
  stopifnot(nrow(df) >= 3, length(unique(df$x)) >= 2)
  
  fixed1 <- !is.null(halflife1)
  fixed2 <- !is.null(halflife2)
  
  k1_expr <- if (fixed1) sprintf("(log(2)/%g)", halflife1) else "k1"
  k2_expr <- if (fixed2) sprintf("(log(2)/%g)", halflife2) else "k2"
  
  form <- as.formula(sprintf(
    "y ~ %g + A1 * exp(-%s * x) + A2 * exp(-%s * x)",
    baseline, k1_expr, k2_expr
  ))
  
  y_adj <- max(df$y - baseline, na.rm = TRUE)
  if (!is.finite(y_adj) || y_adj <= 0) y_adj <- 1
  x_range <- diff(range(df$x))
  default_start <- list(A1 = y_adj, A2 = y_adj / 2) # guess: fast phase starts above later phase
  if (!fixed1) default_start$k1 <- log(2) / (x_range / 10)   # guess: fast phase
  if (!fixed2) default_start$k2 <- log(2) / x_range # guess: slow phase
  
  start <- modifyList(default_start, start)
  needed <- intersect(names(start), all.vars(form[[3]]))
  start <- start[needed]
  
  # Bound amplitudes/rates at >= 0 so a bad trial step can't send k negative
  # and blow exp(-k*x) up to Inf for large x (the usual cause of
  # "Missing value or an infinity produced when evaluating the model").
  lower <- setNames(rep(0, length(start)), names(start))
  
  fit <- nls(form, data = df, start = start, lower = lower,
             algorithm = "port", control = control)
  
  co <- coef(fit)
  hl1 <- if (fixed1) halflife1 else log(2) / co[["k1"]]
  hl2 <- if (fixed2) halflife2 else log(2) / co[["k2"]]
  
  ss_res <- sum(residuals(fit)^2)
  ss_tot <- sum((df$y - mean(df$y))^2)
  r_squared <- 1 - ss_res / ss_tot
  
  list(
    model = fit,
    coefficients = co,
    baseline = baseline,
    halflife1 = hl1,
    halflife2 = hl2,
    r_squared = r_squared
  )
}

#' Evaluate a fit_two_phase_decay() result at new x values
predict_two_phase_decay <- function(fit, x) {
  co <- fit$coefficients
  k1 <- log(2) / fit$halflife1
  k2 <- log(2) / fit$halflife2
  fit$baseline + co[["A1"]] * exp(-k1 * x) + co[["A2"]] * exp(-k2 * x)
}