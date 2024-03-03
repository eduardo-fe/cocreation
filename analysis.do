cd "/Users/user/Dropbox/Econometrics/MarioCocreating/code"
 
use "/Users/user/Dropbox/Econometrics/MarioCocreating/new_data/id_name.dta"
merge 1:1 id using "/Users/user/Dropbox/Econometrics/MarioCocreating/new_data/timeuse.dta"
drop _merge
merge 1:1 id using "/Users/user/Dropbox/Econometrics/MarioCocreating/new_data/survey.dta"
drop _merge
merge 1:1 id using "/Users/user/Dropbox/Econometrics/MarioCocreating/new_data/grades.dta"
drop _merge
merge 1:1 id using "/Users/user/Dropbox/Econometrics/MarioCocreating/new_data/micro2.dta"
drop _merge


gen originalSample = 1

keep if originalSample == 1
//drop lastName firstName treatment

gen UK = country=="United Kingdom"
gen China = country =="China"
gen female = sex ==2
gen BAEcon = program=="3 BA(Econ) Economics"
gen BAEconFin =program== "5 BA(Econ)Economics and Finance"


* Outcome Variables

gen aveBeforeE1 = (timeE1m2+timeE1m1)/2
gen timeE1_tot = (timeE1 + timeE1p1)/2

gen aveBeforeE2 = (timeE2m2+timeE2m1)/2
gen timeE2_tot = (timeE2 + timeE2p1)/2


* Descriptive statistics

estpost sum female age UK China  BAEcon BAEconFin  markMi aveBeforeE1 ///
	timeE1_tot  aveBeforeE2  timeE2_tot if treat !=.
est store des1 

estpost sum female age UK China  BAEcon BAEconFin markMi aveBeforeE1 ///
	timeE1_tot  aveBeforeE2  timeE2_tot if treat ==0
est store des2

estpost sum female age UK China  BAEcon BAEconFin markMi aveBeforeE1 ///
	timeE1_tot  aveBeforeE2  timeE2_tot if treat ==1
est store des3

esttab des1 des2 des3 using descriptives.tex, ///
mtitle("All" "Control" "Treatment") ///
	cells(mean(fmt(2))) label booktabs nonum collabels(none) gaps f noobs ///
	replace se star(* 0.1 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f)

* Randomization worked?
reg treat female age, vce(robust)
est sto m1

reg treat female UK China age, vce(robust)
est sto m2

reg treat female UK China age, vce(robust)
est sto m3

reg treat female UK China age BAEcon BAEconFin, vce(robust)
est sto m4

reg treat female UK China age BAEcon BAEconFin markMicro aveBeforeE1, vce(robust)
est sto m5

esttab m1 m2 m3 m4 m5 using randomCheck.tex, ///
	replace se star(* 0.1 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f)
	

* Test 1: within day:

gen diff1 = timeE1_tot - aveBeforeE1
reg timeE1_tot treat, vce(robust)
est sto test1

reg diff1 treat, vce(robust)
est sto test2

esttab test1 test2 using email1.tex, ///
 	mtitle("ATE" "Diff-in-Diffs") ///
	replace se star(* 0.1 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f)


* Test 2: long run

gen diff2 = aveBeforeE2 - aveBeforeE1
reg aveBeforeE2 treat, vce(robust)
est sto test3

reg diff2 treat, vce(robust)
est sto test4

esttab test3 test4 using longrun.tex, ///
 	mtitle("ATE" "Diff-in-Diffs") ///
	replace se star(* 0.1 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f)


* Test 3: Second email

gen diff3 = timeE2_tot  - aveBeforeE1
reg timeE2_tot treat, vce(robust)
est sto test5

reg diff3 treat, vce(robust)
est sto test6

esttab test5 test6 using email2.tex, ///
 	mtitle("ATE" "Diff-in-Diffs") ///
	replace se star(* 0.1 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f)


* with covariates
 
reg diff1 treat female age UK China  BAEcon BAEconFin  markMi aveBeforeE1  if treat !=., vce(robust)
est sto robustness1

reg diff2 treat female age UK China  BAEcon BAEconFin  markMi aveBeforeE1 if treat !=. , vce(robust)
est sto robustness2


reg diff3 treat female age UK China  BAEcon BAEconFin  markMi aveBeforeE1 if treat !=. , vce(robust)
est sto robustness3

esttab robustness1 robustness2 robustness3 using robustness.tex, ///
 	mtitle("Email 1" "Long term" "Email 2" ) ///
	replace se star(* 0.1 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f)


* Grades

reg formative  treat female age UK China  BAEcon BAEconFin  markMi aveBeforeE1  if treat !=., vce(robust)
est sto finalgrades1
reg midterm   treat female age UK China  BAEcon BAEconFin  markMi aveBeforeE1  if treat !=., vce(robust)
est sto finalgrades2
reg exam treat female age UK China  BAEcon BAEconFin  markMi aveBeforeE1  if treat !=., vce(robust)
est sto finalgrades3

esttab finalgrades1 finalgrades2 finalgrades3 using finalGrades.tex, ///
 	mtitle("Email 1" "Long term" "Email 2" ) ///
	replace se star(* 0.1 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f)
