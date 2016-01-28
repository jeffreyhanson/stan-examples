data {
	// trainning variables
	int train_n;
	int train_n_id;
	vector[n]<lower=0,upper=1> train_y; 
	vector[n] train_x;
	int<lower=1; upper=n_id> train_x_ranef_id[n];
	
	// prediction variables
	int predict_n;
	vector[n] predict_x;
}

parameters {
	// hyper-parameters for model coefficients
	real a_mu;
	real<lower=0> a_sigma;
	real r_mu;
	real<lower=0> r_sigma;
}

transformed parameters {
	// declare parameters
	real phi<lower=0>;
	real e_a_ranef[n_id];
	real e_r_ranef[n_id];
}

transformed parameters {
	// declare parameters
	vector[n_id] a_ranef;
	vector[n_id] r_ranef;

	// sample random effects from hyper-parameters
	a_ranef <- a_mu + e_a_ranef * a_sigma;
	r_ranef <- r_mu + e_r_ranef * r_sigma;
}

model {
	// declare variables
	vector[n] train_a_ranef_id;
	vector[n] train_r_ranef_id;
	vector[n] mu;
	vector[n] beta_a;
	vector[n] beta_b;
	
	// calculations
	for (i in 1:n) {
		train_a_ranef_id <- a_ranef[train_x_ranef_id[i]]; 
		train_r_ranef_id <- r_ranef[train_x_ranef_id[i]]; 
	}
	mu <- inv_logit(train_a_ranef_id - (train_a_ranef_id * exp(train_r_ranef * train_x)))
	beta_a <- mu * phi;
	beta_b <- (1.0-mu) * phi;
	
	// prior
	a_mu ~ normal(0, 1);
	a_sigma ~ cauchy(0, 5);
	r_mu ~ normal(0, 1);
	r_sigma ~ cauchy(0, 5);
	phi ~ gamma(0.001, 0.001);
	
	// likelihood
	e_a_ranef ~ normal(0,1);
	e_r_ranef ~ normal(0,1);
	y ~ beta(beta_a, beta_b);
}

generated quantities {
	// declare variables
	real predict_y[predict_n];
	real predict_y_ranef[predict_n,train_n_id];

	{
		// declare local variables
		vector[predict_n] predict_beta_a;
		vector[predict_n] predict_beta_ranef_a;
		vector[predict_n] predict_beta_b;
		vector[predict_n] predict_ranef_b;
		vector[predict_n] predict_mu;
		vector[predict_n] predict_ranef_mu; 
	
		// population level predictions
		predict_mu <- inv_logit(a_mu - (a_mu * exp(r_mu * predict_x))
		predict_beta_a <- predict_mu * phi;
		predict_beta_b <- (1.0-predict_mu) * phi;
		predict_y <- beta_rng(predict_a, predict_b);
		
		// random effect level predictions
		for (i in 1:train_n_id) {
			predict_ranef_mu <- inv_logit(a_ranef[i] - (a_ranef[i] * exp(r_ranef[i] * predict_x))
			predict_ranef_beta_a <- predict_ranef_mu * phi;
			predict_ranef_beta_b <- (1.0-predict_ranef_mu) * phi;
			col(predict_ranef_y, i) <- beta_rng(predict_ranef_a, predict_ranef_b);
		}
	}
}
