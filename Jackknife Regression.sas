﻿
data a;
input income1 income2 house stand double prop;
cards;
  521.502    118.348    735.779     920.53      0     1215.86
   14.116    457.801    413.522     690.15      0      917.67
  308.237    205.341    567.238     903.11      1     1201.16
  449.589    157.470    496.226     659.05      1     1099.73
   47.286    555.871    414.292     769.92      0     1077.25
   12.702    400.744    283.223     539.62      1      973.28
  303.539    360.630    671.121     934.58      0     1206.01
  325.548    369.610    284.473     707.85      0     1071.03
  328.079     17.192    492.552     699.23      0      834.60
  479.735     34.212    767.408    1097.32      0     1102.11
   70.381    319.148    373.140     760.19      0      774.12
  232.232    255.517    238.515     577.39      0      828.64
   56.125    326.705    589.865     930.42      0     1020.10
  510.569     36.773    461.059     920.65      0     1044.39
   15.890    353.851    345.385     655.05      1      932.65
  298.906    126.398    531.592    1093.24      0     1036.68
  280.401    105.089    497.296     727.87      0      867.00
  188.411    419.229    383.097     903.32      0     1114.49
   11.004    462.602    351.969     575.44      0      833.46
  408.952    119.757    650.882     950.26      0     1044.39
  114.999    253.868    439.853     849.32      0      831.60
  200.932    141.234    400.907     571.64      0      773.70
  276.907    350.366    554.191     948.33      1     1273.24
  271.076    109.235    734.862     970.72      1     1124.66
  357.141    324.151    507.147     686.02      0     1146.86
   74.029    403.535    372.881     520.79      0      836.79
  112.752    195.755    550.987    1048.71      0     1023.95
  189.496    273.100    400.458     550.31      0      834.02
  283.516    395.697    445.404     600.35      0     1064.84
  255.701    154.743    535.123    1078.51      0     1075.30
  ;
run ;



proc iml;

start reg;
	k = ncol(x);
	n = nrow(x);
	bh = inv(x`*x)*x`*y;
	res = y - x*bh;
	ess = res`*res;
	tss = (y-y[:,])[##,]; /* Sum of (yi - ybar)^2 */ /*y[:] = average */ /*## gives sum of squares */
	rss = tss - ess;
	df_m = k;
	df_e = n-k;
	df_t = n-1;

	ms_m = rss/df_m;
	ms_e = ess / df_e;

	F = ms_m / ms_e; /*all parameters jointly equal to 0 */
	pval_F = 1 - probf(F,df_m,df_e); /* prob of type 1 error */

	rmse = SQRT(ms_e); /*root mean square error */

	ybar = y[:];

	RSQ = rss / tss;
	Rsq_a = 1 - (((1-Rsq)*(n-1))/(n-k-1));

	std_bh = sqrt(vecdiag(ms_e * inv(x`*x)));
	t=bh/std_bh;

	probt=2*(1-probt(abs(t),df_e));
	tval = tinv(.90,df_e);
	ci_beta_l=bh-tval*std_bh;
	ci_beta_u=bh+tval*std_bh;
finish reg;

do i= 1 to 30;
	use a;
	read all into xy;
	n = nrow(xy);
	x1 = J(n,1,1);
	x2 = (xy[,1]+xy[,2]);
	x3 = xy[,4];
	x4 = (xy[,3]/xy[,4]);
	x5=xy[,5];

		x1 = (remove(x1,i))`;
		x2 = (remove(x2,i))`;
		x3 = (remove(x3,i))`;
		x4 = (remove(x4,i))`;
		x5 = (remove(x5,i))`;
	x = x1 || x2 || x3 || x4 || x5;
	y = xy[,ncol(xy)];
	y = (remove(y,i))`;
		/*x = J(n,1,1) || xy[,1]+xy[,2] || xy[,4] ||xy[,3]/xy[,4]||xy[,5];*/
	n = nrow(x);
	print i;
	run reg;
	resj = resj // (bh` || rsq);	
end;
nm = {"bh1","bh2","bh3","bh4","bh5","RSQ"};
print resj[colname=nm];
