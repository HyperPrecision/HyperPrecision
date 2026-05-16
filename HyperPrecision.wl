(* ::Package:: *)

(* ::Title:: *)
(*HyperPrecision*)


(* ::Subtitle:: *)
(*a Mathematica package for high-precision numerical evaluation of Hypergeometric functions*)


(* ::Section::Closed:: *)
(*Package Initiation*)


BeginPackage["HyperPrecision`"];
Needs["FiniteFlow`"];
Get["DESolver.m"];
If[$KernelCount===0,LaunchKernels[$ProcessorCount*2]];
ParallelEvaluate[Get["DESolver.m"]];
LastUpdate="\!\(\*SuperscriptBox[\(11\), \(th\)]\) May, 2026";


(* ::Section::Closed:: *)
(*Author Credits*)


Print[Style["HyperPrecision 1.0",Blue,14,FontFamily->"Courier",Bold],Style[" - a Mathematica package for high-precision numerical evaluation of hypergeometric functions.",Blue,14,FontFamily->"Courier"]];
Print[Style["Authors: ",Black,Bold],Style["  Sumit Banik, Souvik Bera",Brown,Bold,12.5]];
Print[Style["Last updated: ",Black,Bold], LastUpdate];


(* ::Section::Closed:: *)
(*Usage Messages*)


(* ::Subsection::Closed:: *)
(*Global Variables*)


eta::usage = 
"eta is the auxiliary variable, shared with DESolver.m, used to parameterise the contour from origin to target.
 The origin corresponds to eta \[Rule] Infinity and the target to eta \[Rule] 0. It should not be assigned a value by the user.";


(* ::Subsection::Closed:: *)
(*Pre-defined Hypergeometric Functions*)


(* ---- Appell F2  a ; b1,b2 ; c1,c2 ---------------------------- *)
If[!StringQ[AppellF2::usage],
  AppellF2::usage =
    "AppellF2[a, b1, b2, c1, c2, x, y] represents the Appell \
hypergeometric function F2(a; b1,b2; c1,c2; x,y), defined by the \
double series\n\n  \
F2 = Sum_{m,n>=0} (a)_(m+n) (b1)_m (b2)_n / ((c1)_m (c2)_n m! n!)  x^m y^n\n\n\
Standard notation:  F2(a; b1,b2; c1,c2; x,y)\n\
Parameters:  upper = {a, b1, b2},  lower = {c1, c2}\n\n\
Note: coincides with LauricellaFA at n=2.\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[AppellF2[a, b1, b2, c1, c2, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Appell F3  a1,a2 ; b1,b2 ; c ---------------------------- *)
If[!StringQ[AppellF3::usage],
  AppellF3::usage =
    "AppellF3[a1, a2, b1, b2, c, x, y] represents the Appell \
hypergeometric function F3(a1,a2; b1,b2; c; x,y), defined by the \
double series\n\n  \
F3 = Sum_{m,n>=0} (a1)_m (a2)_n (b1)_m (b2)_n / ((c)_(m+n) m! n!)  x^m y^n\n\n\
Standard notation:  F3(a1,a2; b1,b2; c; x,y)\n\
Parameters:  upper = {a1, a2, b1, b2},  lower = {c}\n\n\
Note: coincides with LauricellaFB at n=2.\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[AppellF3[a1, a2, b1, b2, c, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Appell F4  a,b ; c1,c2 ---------------------------------- *)
If[!StringQ[AppellF4::usage],
  AppellF4::usage =
    "AppellF4[a, b, c1, c2, x, y] represents the Appell \
hypergeometric function F4(a,b; c1,c2; x,y), defined by the \
double series\n\n  \
F4 = Sum_{m,n>=0} (a)_(m+n) (b)_(m+n) / ((c1)_m (c2)_n m! n!)  x^m y^n\n\n\
Standard notation:  F4(a,b; c1,c2; x,y)\n\
Parameters:  upper = {a, b},  lower = {c1, c2}\n\n\
Note: coincides with LauricellaFC at n=2.\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[AppellF4[a, b, c1, c2, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn G1  a,b,c  (no lower parameters) ------------------- *)
If[!StringQ[HornG1::usage],
  HornG1::usage =
    "HornG1[a, b, c, x, y] represents the Horn hypergeometric \
function G1(a,b,c; x,y), defined by the double series\n\n  \
G1 = Sum_{m,n>=0} (a)_(m+n) (b)_(n-m) (c)_(m-n) / (m! n!)  x^m y^n\n\n\
Standard notation:  G1(a,b,c; x,y)\n\
Parameters:  upper = {a, b, c},  lower = {} (none)\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornG1[a, b, c, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn G2  a,b,c,d  (no lower parameters) ----------------- *)
If[!StringQ[HornG2::usage],
  HornG2::usage =
    "HornG2[a, b, c, d, x, y] represents the Horn hypergeometric \
function G2(a,b,c,d; x,y), defined by the double series\n\n  \
G2 = Sum_{m,n>=0} (a)_m (b)_n (c)_(n-m) (d)_(m-n) / (m! n!)  x^m y^n\n\n\
Standard notation:  G2(a,b,c,d; x,y)\n\
Parameters:  upper = {a, b, c, d},  lower = {} (none)\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornG2[a, b, c, d, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn G3  a,b  (no lower parameters) --------------------- *)
If[!StringQ[HornG3::usage],
  HornG3::usage =
    "HornG3[a, b, x, y] represents the Horn hypergeometric \
function G3(a,b; x,y), defined by the double series\n\n  \
G3 = Sum_{m,n>=0} (a)_(2n-m) (b)_(2m-n) / (m! n!)  x^m y^n\n\n\
Standard notation:  G3(a,b; x,y)\n\
Parameters:  upper = {a, b},  lower = {} (none)\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornG3[a, b, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn H1  a,b,c ; d -------------------------------------- *)
If[!StringQ[HornH1::usage],
  HornH1::usage =
    "HornH1[a, b, c, d, x, y] represents the Horn hypergeometric \
function H1(a,b,c; d; x,y), defined by the double series\n\n  \
H1 = Sum_{m,n>=0} (a)_(m-n) (b)_(m+n) (c)_n / ((d)_m m! n!)  x^m y^n\n\n\
Standard notation:  H1(a,b,c; d; x,y)\n\
Parameters:  upper = {a, b, c},  lower = {d}\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornH1[a, b, c, d, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn H2  a,b,c,d ; e ------------------------------------ *)
If[!StringQ[HornH2::usage],
  HornH2::usage =
    "HornH2[a, b, c, d, e, x, y] represents the Horn hypergeometric \
function H2(a,b,c,d; e; x,y), defined by the double series\n\n  \
H2 = Sum_{m,n>=0} (a)_(m-n) (b)_m (c)_n (d)_n / ((e)_m m! n!)  x^m y^n\n\n\
Standard notation:  H2(a,b,c,d; e; x,y)\n\
Parameters:  upper = {a, b, c, d},  lower = {e}\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornH2[a, b, c, d, e, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn H3  a,b ; c ---------------------------------------- *)
If[!StringQ[HornH3::usage],
  HornH3::usage =
    "HornH3[a, b, c, x, y] represents the Horn hypergeometric \
function H3(a,b; c; x,y), defined by the double series\n\n  \
H3 = Sum_{m,n>=0} (a)_(2m+n) (b)_n / ((c)_(m+n) m! n!)  x^m y^n\n\n\
Standard notation:  H3(a,b; c; x,y)\n\
Parameters:  upper = {a, b},  lower = {c}\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornH3[a, b, c, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn H4  a,b ; c,d -------------------------------------- *)
If[!StringQ[HornH4::usage],
  HornH4::usage =
    "HornH4[a, b, c, d, x, y] represents the Horn hypergeometric \
function H4(a,b; c,d; x,y), defined by the double series\n\n  \
H4 = Sum_{m,n>=0} (a)_(2m+n) (b)_n / ((c)_m (d)_n m! n!)  x^m y^n\n\n\
Standard notation:  H4(a,b; c,d; x,y)\n\
Parameters:  upper = {a, b},  lower = {c, d}\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornH4[a, b, c, d, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn H5  a,b ; c ---------------------------------------- *)
If[!StringQ[HornH5::usage],
  HornH5::usage =
    "HornH5[a, b, c, x, y] represents the Horn hypergeometric \
function H5(a,b; c; x,y), defined by the double series\n\n  \
H5 = Sum_{m,n>=0} (a)_(2m+n) (b)_(n-m) / ((c)_n m! n!)  x^m y^n\n\n\
Standard notation:  H5(a,b; c; x,y)\n\
Parameters:  upper = {a, b},  lower = {c}\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornH5[a, b, c, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn H6  a,b,c  (no lower parameters) ------------------- *)
If[!StringQ[HornH6::usage],
  HornH6::usage =
    "HornH6[a, b, c, x, y] represents the Horn hypergeometric \
function H6(a,b,c; x,y), defined by the double series\n\n  \
H6 = Sum_{m,n>=0} (a)_(2m-n) (b)_(n-m) (c)_n / (m! n!)  x^m y^n\n\n\
Standard notation:  H6(a,b,c; x,y)\n\
Parameters:  upper = {a, b, c},  lower = {} (none)\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornH6[a, b, c, x, y], {\[Epsilon],Nterms}, NPrec]"
]


(* ---- Horn H7  a,b,c ; d -------------------------------------- *)
If[!StringQ[HornH7::usage],
  HornH7::usage =
    "HornH7[a, b, c, d, x, y] represents the Horn hypergeometric \
function H7(a,b,c; d; x,y), defined by the double series\n\n  \
H7 = Sum_{m,n>=0} (a)_(2m-n) (b)_n (c)_n / ((d)_m m! n!)  x^m y^n\n\n\
Standard notation:  H7(a,b,c; d; x,y)\n\
Parameters:  upper = {a, b, c},  lower = {d}\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[HornH7[a, b, c, d, x, y], {\[Epsilon],Nterms}, NPrec]"
]

(* ---- Lauricella FA  a ; b1..bn ; c1..cn ---------------------- *)
If[!StringQ[LauricellaFA::usage],
  LauricellaFA::usage =
    "LauricellaFA[{a, b1,...,bn}, {c1,...,cn}, {x1,...,xn}] represents \
the Lauricella hypergeometric function F_A of n variables, defined by\n\n  \
F_A = Sum_{m1,...,mn>=0} \
(a)_(m1+...+mn) Prod_i (bi)_mi / (Prod_i (ci)_mi mi!)  Prod_i xi^mi\n\n\
Standard notation:  F_A^(n)(a; b1,...,bn; c1,...,cn; x1,...,xn)\n\
Parameters:  upper = {a, b1,...,bn},  lower = {c1,...,cn}\n\
The number of variables n is inferred from Length[{x1,...,xn}].\n\n\
Note: LauricellaFA with n=2 coincides with Appell F2.\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[LauricellaFA[{a,b1,...,bn},{c1,...,cn},{x1,...,xn}], \
{\[Epsilon],Nterms}, NPrec]"]

(* ---- Lauricella FB  a1..an, b1..bn ; c ----------------------- *)
If[!StringQ[LauricellaFB::usage],
  LauricellaFB::usage =
    "LauricellaFB[{a1,...,an, b1,...,bn}, {c}, {x1,...,xn}] represents \
the Lauricella hypergeometric function F_B of n variables, defined by\n\n  \
F_B = Sum_{m1,...,mn>=0} \
Prod_i (ai)_mi (bi)_mi / ((c)_(m1+...+mn) Prod_i mi!)  Prod_i xi^mi\n\n\
Standard notation:  F_B^(n)(a1,...,an; b1,...,bn; c; x1,...,xn)\n\
Parameters:  upper = {a1,...,an, b1,...,bn},  lower = {c}\n\
The number of variables n is inferred from Length[{x1,...,xn}].\n\n\
Note: LauricellaFB with n=2 coincides with Appell F3.\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[LauricellaFB[{a1,...,an,b1,...,bn},{c},{x1,...,xn}], \
{\[Epsilon],Nterms}, NPrec]"]

(* ---- Lauricella FC  a,b ; c1..cn ---------------------------- *)
If[!StringQ[LauricellaFC::usage],
  LauricellaFC::usage =
    "LauricellaFC[{a, b}, {c1,...,cn}, {x1,...,xn}] represents \
the Lauricella hypergeometric function F_C of n variables, defined by\n\n  \
F_C = Sum_{m1,...,mn>=0} \
(a)_(m1+...+mn) (b)_(m1+...+mn) / (Prod_i (ci)_mi mi!)  Prod_i xi^mi\n\n\
Standard notation:  F_C^(n)(a,b; c1,...,cn; x1,...,xn)\n\
Parameters:  upper = {a, b},  lower = {c1,...,cn}\n\
The number of variables n is inferred from Length[{x1,...,xn}].\n\n\
Note: LauricellaFC with n=2 coincides with Appell F4.\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[LauricellaFC[{a,b},{c1,...,cn},{x1,...,xn}], \
{\[Epsilon],Nterms}, NPrec]"]

(* ---- Lauricella FD  a ; b1..bn ; c -------------------------- *)
If[!StringQ[LauricellaFD::usage],
  LauricellaFD::usage =
    "LauricellaFD[{a, b1,...,bn}, {c}, {x1,...,xn}] represents \
the Lauricella hypergeometric function F_D of n variables, defined by\n\n  \
F_D = Sum_{m1,...,mn>=0} \
(a)_(m1+...+mn) Prod_i (bi)_mi / ((c)_(m1+...+mn) Prod_i mi!)  Prod_i xi^mi\n\n\
Standard notation:  F_D^(n)(a; b1,...,bn; c; x1,...,xn)\n\
Parameters:  upper = {a, b1,...,bn},  lower = {c}\n\
The number of variables n is inferred from Length[{x1,...,xn}].\n\n\
Note: LauricellaFD with n=2 coincides with Appell F1.\n\n\
Usage with HypFunctionExpand:\n  \
HypFunctionExpand[LauricellaFD[{a,b1,...,bn},{c},{x1,...,xn}], \
{\[Epsilon],Nterms}, NPrec]"]


(* ::Subsection::Closed:: *)
(*External Modules*)


PDEGenerator::usage = 
"PDEGenerator[HypSeries, SumVar, Vars, FuncSymbol] returns the list of PDEs satisfied by HypSeries in the variables Vars, \
derived from the shift ratios of the series coefficients in the summation indices SumVar.
HypSeries is a hypergeometric series given in terms of Pochhammer functions.
SumVar is the list of summation indices appearing in HypSeries:
  \[Bullet] {m, n, ...}
Vars is the list of kinematic variables:
  \[Bullet] {x, y, ...}
FuncSymbol (optional, default F) sets the function symbol appearing in the output PDEs.
The result is a list of PDEs in the unknown function FuncSymbol[Vars].
Examples:
  PDEGenerator[Pochhammer[a,m+n] Pochhammer[b,m] Pochhammer[b',n] / (Pochhammer[c,m+n] m! n!) x^m y^n, {m, n}, {x, y}]
  PDEGenerator[Pochhammer[a,m+n] Pochhammer[b,m] Pochhammer[b',n] / (Pochhammer[c,m+n] m! n!) x^m y^n, {m, n}, {x, y}, G]";


FindHypergeometricOrder::usage = 
"FindHypergeometricOrder[HypSeries, SumVar, Vars] returns the list of PDE orders, one per summation index, satisfied by HypSeries.
HypSeries is a hypergeometric series given in terms of Pochhammer functions.
SumVar is the list of summation indices appearing in HypSeries:
  \[Bullet] {m, n, ...}
Vars is the list of kinematic variables:
  \[Bullet] {x, y, ...}
The result is a list of integers {o_1, ..., o_k} of length k = Length[SumVar], where o_j is the PDE order in the direction associated with the j-th summation index.
Examples:
  FindHypergeometricOrder[Pochhammer[a,m+n] Pochhammer[b,m] Pochhammer[b',n] / (Pochhammer[c,m+n] m! n!) x^m y^n, {m, n}, {x, y}]";


FindPfaffianSystem::usage =
"FindPfaffianSystem[HypSeries, SumVar, Vars] derives the Pfaffian system associated with HypSeries, automatically constructing \
a basis of derivatives from the holonomic order of the system.
HypSeries is a hypergeometric series given in terms of Pochhammer functions.
SumVar is the list of summation indices appearing in HypSeries:
  \[Bullet] {m, n, ...}
Vars is the list of kinematic variables:
  \[Bullet] {x, y, ...}
The result is the 4-tuple {HypSeries, SumVar, Pfaffian, Basis}, where Pfaffian is the Association <|Var \[Rule] Matrix|> of connection matrices \
and Basis is the list of basis elements. The 4-tuple is the input format expected by TransportDE[].
Examples:
  FindPfaffianSystem[Pochhammer[a,m+n] Pochhammer[b,m] Pochhammer[b',n] / (Pochhammer[c,m+n] m! n!) x^m y^n, {m, n}, {x, y}]";


FindPfaffianSystemBasis::usage =
"FindPfaffianSystemBasis[HypSeries, SumVar, Vars, Basis] is the same as FindPfaffianSystem[], except that the basis of derivatives \
is supplied by the user as the fourth argument Basis rather than constructed automatically.
HypSeries is a hypergeometric series given in terms of Pochhammer functions.
SumVar is the list of summation indices appearing in HypSeries:
  \[Bullet] {m, n, ...}
Vars is the list of kinematic variables:
  \[Bullet] {x, y, ...}
Basis is the user-supplied list of basis elements (derivatives of the unknown function F):
  \[Bullet] {F[x,y], Derivative[0,1][F][x,y], Derivative[1,0][F][x,y], Derivative[1,1][F][x,y], ...}
The result is the 4-tuple {HypSeries, SumVar, Pfaffian, Basis} in the input format expected by TransportDE[].
Examples:
  FindPfaffianSystemBasis[Pochhammer[a,m+n] Pochhammer[b,m] Pochhammer[b',n] / (Pochhammer[c,m+n] m! n!) x^m y^n,
                          {m, n}, {x, y}, {F[x,y], Derivative[0,1][F][x,y], Derivative[1,0][F][x,y], Derivative[1,1][F][x,y]}]";


FindHolonomicRank::usage =
"FindHolonomicRank[HypSeries, SumVar, Vars] returns the holonomic rank of the Pfaffian system associated with the hypergeometric series HypSeries, \
together with an independent basis of derivatives realizing this rank.
HypSeries is a hypergeometric series given in terms of Pochhammer functions.
SumVar is the list of summation indices appearing in HypSeries:
  \[Bullet] {m, n, ...}
Vars is the list of kinematic variables:
  \[Bullet] {x, y, ...}
The result is the pair {N, Basis}, where N is the holonomic rank and Basis is a list of N independent derivatives of the unknown function F, \
sorted by total derivative order. The Basis can be passed directly to FindPfaffianSystemBasis[] as the user-supplied basis argument.
Examples:
  FindHolonomicRank[Pochhammer[a,m+n] Pochhammer[b,m] Pochhammer[b',n] / (Pochhammer[c,m+n] m! n!) x^m y^n, {m, n}, {x, y}]";


CheckIntegrability::usage =
"CheckIntegrability[PfaffianIN, Vars] checks the Frobenius integrability conditions \
d_j M_i - d_i M_j + [M_i, M_j] = 0 for every pair of variables in Vars.
PfaffianIN is the Pfaffian system (4-tuple) returned by FindPfaffianSystem[] or FindPfaffianSystemBasis[]; \
the connection matrices M_i are taken from it.
Vars is the list of kinematic variables:
  \[Bullet] {x, y, ...}
The check is performed numerically at a randomly chosen rational point. \
Prints PASSED or FAILED for each pair, and returns True if all pairs pass, False otherwise.
Examples:
  CheckIntegrability[PfaffianSystemIN, {x, y}]";


TransportDE::usage = 
"TransportDE[PfaffianIN, ParSub, VarSub, {Eps, Ord}, NPrec, opts] numerically expands the function defined by the Pfaffian system \
PfaffianIN around Eps=0 up to order Ord with NPrec correct digits.
PfaffianIN is the Pfaffian system returned by FindPfaffianSystem[] or FindPfaffianSystemBasis[].
ParSub is the list of substitution rules for the Pochhammer parameters:
  \[Bullet] {a \[Rule] 1+\[Epsilon], b \[Rule] 1/2, c \[Rule] 2-\[Epsilon], ...}
VarSub is the list of substitution rules for the kinematic variables, specifying the evaluation point:
  \[Bullet] {x \[Rule] 1/5, y \[Rule] 1/4, ...}
The result is the list of Laurent coefficients from the lowest non-vanishing order to Ord.
Options:
  \[Bullet] IDelta      (default: -I)    \[LongDash] infinitesimal imaginary shift
  \[Bullet] VerboseMode (default: False) \[LongDash] print progress information
  \[Bullet] ParallelRun (default: True)  \[LongDash] use parallel evaluation
Examples:
  TransportDE[PfaffianSystemIN, {a \[Rule] 1, b1 \[Rule] 1/2, b2 \[Rule] 1/3, c \[Rule] 2}, {x \[Rule] 1/5, y \[Rule] 1/4}, {\[Epsilon], 2}, 50]";


HypExpand::usage = 
"HypExpand[HypSeries, ParSub, VarSub, {Eps, Ord}, NPrec, opts] numerically expands a hypergeometric series \
HypSeries around Eps=0 up to order Ord with NPrec correct digits.
HypSeries is a hypergeometric series given in terms of Pochhammer functions.
ParSub is the list of substitution rules for the Pochhammer parameters:
  \[Bullet] {a \[Rule] 1+\[Epsilon], b \[Rule] 1/2, c \[Rule] 2-\[Epsilon], ...}
VarSub is the list of substitution rules for the kinematic variables, specifying the evaluation point:
  \[Bullet] {x \[Rule] 1/5, y \[Rule] 1/4, ...}
The result is the list of Laurent coefficients from the lowest non-vanishing order to Ord.
Options:
  \[Bullet] IDelta      (default: -I)    \[LongDash] infinitesimal imaginary shift
  \[Bullet] VerboseMode (default: False) \[LongDash] print progress information
  \[Bullet] ParallelRun (default: True)  \[LongDash] use parallel evaluation
Examples:
  HypExpand[Pochhammer[a,m+n] Pochhammer[b1,m] Pochhammer[b2,n] / (Pochhammer[c,m+n] m! n!) x^m y^n,
            {a \[Rule] 1, b1 \[Rule] 1/2, b2 \[Rule] 1/3, c \[Rule] 2}, {x \[Rule] 1/5, y \[Rule] 1/4}, {\[Epsilon], 2}, 50]";


HypFunctionExpand::usage = 
"HypFunctionExpand[Func, {Eps, Ord}, NPrec, opts] numerically expands the \
hypergeometric function Func around Eps=0 up to order Ord with precision NPrec.

Func can be a call to any of the following named pre-defined hypergeometric functions, \
with parameters and variables given as follows:

  Built-in (Mathematica):
  \[Bullet] Hypergeometric2F1[a, b, c, x]
  \[Bullet] HypergeometricPFQ[{a1,...,ap}, {b1,...,bq}, x]   \
(currently supported only for q = p \[Minus] 1)

  Appell functions (2 variables):
  \[Bullet] AppellF1[a, b1, b2, c, x, y]                  -- coincides with LauricellaFD at n=2
  \[Bullet] AppellF2[a, b1, b2, c1, c2, x, y]             -- coincides with LauricellaFA at n=2
  \[Bullet] AppellF3[a1, a2, b1, b2, c, x, y]             -- coincides with LauricellaFB at n=2
  \[Bullet] AppellF4[a, b, c1, c2, x, y]                  -- coincides with LauricellaFC at n=2

  Horn G- and H-series (2 variables, defined within HyperPrecision; \
   use ?HornG1, ?HornH1, etc. to see the series definition and call signature):
  \[Bullet] HornG1, HornG2, HornG3
  \[Bullet] HornH1, HornH2, HornH3, HornH4, HornH5, HornH6, HornH7

  Lauricella series (n variables, defined within HyperPrecision; \
   use ?LauricellaFA, ?LauricellaFB, etc. to see the series definition and call signature):
  \[Bullet] LauricellaFA, LauricellaFB, LauricellaFC, LauricellaFD

  Options:
  \[Bullet] IDelta      (default: -I)    \[LongDash] infinitesimal imaginary shift
  \[Bullet] VerboseMode (default: False) \[LongDash] print progress information
  \[Bullet] ParallelRun (default: True)  \[LongDash] use parallel evaluation

The result is the list of Laurent coefficients from the lowest non-vanishing \
order to Ord.

Examples:
  HypFunctionExpand[Hypergeometric2F1[1, 1/2 + \[Epsilon], 2 - \[Epsilon], 1/3], {\[Epsilon], 2}, 50]
  HypFunctionExpand[AppellF1[1, 1/2, 1/3, 2, 1/5, 1/4], {\[Epsilon], 2}, 50]
  HypFunctionExpand[HornH7[1, 1/2, 1/3, 2, 1/5, 1/4], {\[Epsilon], 3}, 50]
  HypFunctionExpand[LauricellaFD[{1, 1/2, 1/3, 1/4}, {2}, {1/5, 1/6, 1/7}], {\[Epsilon], 2}, 50]
  HypFunctionExpand[LauricellaFA[{1, 1/2, 1/3}, {2, 3}, {1/5, 1/4}], {\[Epsilon], 2}, 50, \
VerboseMode \[Rule] True]";


(* ::Subsection::Closed:: *)
(*External Module Options*)


IDelta::usage = 
"IDelta is an option of HypExpand[], HypFunctionExpand[] and TransportDE[] that fixes the side of the branch cut on which the target point is evaluated
 when the straight-line transport contour from the origin to the target encounters a real singularity of the Pfaffian system.
 The accepted values are \[PlusMinus]I, with default -I. The two prescriptions select different branches of the function and in general yield different numerical results.";


VerboseMode::usage = 
"VerboseMode is an option of HypExpand[], HypFunctionExpand[] and TransportDE[] that controls whether progress information is printed during the computation. 
The default is False. Setting it to True prints diagnostic messages and the integration progress.";


ParallelRun::usage = 
"ParallelRun is an option of HypExpand[], HypFunctionExpand[] and TransportDE[] that controls whether the evaluation of the differential equation on the 
\[Epsilon]-grid is distributed across parallel sub-kernels. The default is True. Setting it to False forces serial evaluation on the main kernel.";


(* ::Section::Closed:: *)
(*Derive Pfaffian System*)


Begin["`Private`"];


(* ::Subsection::Closed:: *)
(*Internal Modules*)


(* ::Subsubsection::Closed:: *)
(*FindCornerDerivativesN*)


FindCornerDerivativesN[list_, funcSymbol_ : F] :=
  Module[{derivTerms, orders, numVars, vars},

    (* 1. Extract all derivative orders and their variables from the list *)
    derivTerms = Cases[list, Derivative[o__][funcSymbol][v___] :> {{o}, {v}}];

    (* If no derivatives are found, return empty *)
    If[derivTerms === {}, Return[{}]];
    orders  = derivTerms[[All, 1]];
    vars    = derivTerms[[1, 2]];

    (* Extracts the variables, e.g. {x,y,z} *)
    numVars = Length[orders[[1]]];

    (* 2. Dynamically find the max pure derivative for each variable position *)
    Table[
      Module[{pureOrders, maxD, newOrders},

        (* Check for pure derivatives in the i-th position *)
        pureOrders = Select[orders, Total[#] == #[[i]] &][[All, i]];

        (* Find the maximum order, defaulting to 0 if none exist *)
        maxD = If[pureOrders === {}, 0, Max[pureOrders]];

        (* 3. Safely construct the new Derivative expression *)
        newOrders = ReplacePart[ConstantArray[0, numVars], i -> maxD];

        (* Explicitly apply Derivative to the list of numbers, then to the function and variables *)
        Apply[Derivative, newOrders][funcSymbol] @@ vars
      ],
      {i, 1, numVars}
    ]
  ];


(* ::Subsubsection::Closed:: *)
(*FindDerivativesUniversal*)


FindDerivativesUniversal[baseRules_List, targetN_Integer] :=
  Module[{lhs, funcSymbol, vars, numVars, baseInfo,
          targetTuples, rhs, diffOrders, diffArgs, compatibleRule},

    If[Length[baseRules] == 0, Return[$Failed]];

    (* 1. Auto-detect the function and variables directly from the given rules *)
    lhs        = baseRules[[1, 1]];
    funcSymbol = lhs /. Derivative[__][f_][___] :> f;
    vars       = List @@ lhs;
    numVars    = Length[vars];

    (* 2. Extract the LHS orders and RHS expression dynamically *)
    baseInfo = Cases[baseRules,
      Rule[Derivative[o__][funcSymbol][v___], rhsExpr_] :> {{o}, rhsExpr}];
    If[baseInfo === {}, Return[$Failed]];

    (* 3. Generate all possible mixed derivative tuples that sum to targetN *)
    targetTuples = Select[Tuples[Range[0, targetN], numVars],
                          Total[#] == targetN &];

    (* 4. Process each target tuple *)
    Table[
      compatibleRule = SelectFirst[baseInfo, Min[tup - #[[1]]] >= 0 &];
      If[compatibleRule =!= Missing["NotFound"],
        diffOrders = tup - compatibleRule[[1]];
        diffArgs   = Select[Transpose[{vars, diffOrders}], #[[2]] > 0 &];
        rhs        = If[diffArgs === {},
                       compatibleRule[[2]],
                       D[compatibleRule[[2]], Sequence @@ diffArgs]];
        Apply[Derivative, tup][funcSymbol][Sequence @@ vars] ->
          Collect[rhs, {__Derivative, funcSymbol @@ vars}, Simplify],
        Apply[Derivative, tup][funcSymbol][Sequence @@ vars] ->
          Apply[Derivative, tup][funcSymbol][Sequence @@ vars]
      ],
      {tup, targetTuples}
    ]
  ];


(* ::Subsubsection::Closed:: *)
(*GenerateLatticeBasis*)


GenerateLatticeBasis[funcSymbol_, vars_List, equationOrder_Integer] :=
  Module[{Nvar, derivTuples, basis},
    Nvar = Length[vars];
    (* All multi-indices with total order <= equationOrder *)
    derivTuples =
      Select[Tuples[Range[0, equationOrder], Nvar],
             Total[#] <= equationOrder &];
    derivTuples = SortBy[derivTuples, Total];
    basis = Map[Derivative[Sequence @@ #][funcSymbol] @@ vars &, derivTuples];
    basis
  ];


(* ::Subsubsection::Closed:: *)
(*Sorting Helpers*)


TotalDerivOrder[Derivative[seq__][func_][vars__]] := Total[{seq}];
TotalDerivOrder[expr_] := 0;


MaxIndexOrder[Derivative[seq__][func_][vars__]] := Max[{seq}];
MaxIndexOrder[expr_] := 0;


(* ::Subsubsection::Closed:: *)
(*ClearDenominators*)


ClearDenominators[expr : (_Equal | _Rule)] :=
  Module[{denL, denR, commonDen, newLHS, newRHS, wrapper},
    wrapper   = Head[expr];
    denL      = Denominator[Together[expr[[1]]]];
    denR      = Denominator[Together[expr[[2]]]];
    commonDen = PolynomialLCM[denL, denR];
    newLHS    = Cancel[expr[[1]] * commonDen];
    newRHS    = Cancel[expr[[2]] * commonDen];
    wrapper[newLHS, newRHS]
  ];

(* Safe fallback if an equation already evaluated to True *)
ClearDenominators[True] := Nothing[];

(* Automatically map over lists *)
ClearDenominators[list_List] := ClearDenominators /@ list;


(* ::Subsubsection:: *)
(*Series Info*)


(*updated on 12/01/2023*)
indices[exp_]:= If[Head[Denominator[exp]]===Factorial,List@@Denominator[exp],Cases[Denominator[exp],Factorial[x___]-> x]]


infotoseries[indices_List,infolist_(*info o/p*)]:=Module[{pre,serinfo,var,num,denom},
{pre,{serinfo,var}}=infolist; 
(*Print[serinfo];*)
num=Times@@(Pochhammer@@{#[[1]],(*Plus@@*)(#[[2]] . indices)}&/@serinfo[[1]]);
(*Print[num];*)
denom=Times@@(Pochhammer@@{#[[1]],(*Plus@@*)(#[[2]] . indices)}&/@serinfo[[2]]);
Return[pre num Times@@Power[var,indices]/(denom Times@@(Factorial[#]&/@indices) )];
]


generalser[indices_,infolist_]:=Module[{pre,num,denom,num1,denom1,var},
{pre,{{num,denom},var}}=infolist;
$aa = \[FormalAlpha];
$bb = \[FormalBeta];
(*denom=Select[denom,#[[1]]=!=1&];*)
num1=Table[{{ToExpression[ToString[$aa]<>ToString[i]],num[[All,2]][[i]]},ToExpression[ToString[$aa]<>ToString[i]]-> num[[All,1]][[i]]},{i,1,Length[num[[All,2]]]}];
denom1=Table[{{ToExpression[ToString[$bb]<>ToString[i]],denom[[All,2]][[i]]},ToExpression[ToString[$bb]<>ToString[i]]-> denom[[All,1]][[i]]},{i,1,Length[denom[[All,2]]]}];
Return[{infotoseries[indices,{pre,{{num1[[All,1]],denom1[[All,1]]},var}}],Join[num1[[All,2]],denom1[[All,2]]]}]]


(*updated on July 7 2022*)

info[indices_List,exp_]:=Module[{prefactor,poch,list11},
prefactor= exp/.((#-> 0)&/@indices);
(*Print[prefactor];*)
poch=(#/(#/.Table[indices[[i]]-> 0,{i,1,Length[indices]}]))&/@List@@If[Head[exp]=!=Plus,Flatten[{exp}],Expand[exp]];
(*poch=poch/.Factorial[m_]\[Rule] Pochhammer[1,m];*);
(*Print[{"info",poch}];*)
list11=Table[{{SortBy[Flatten[List@@Which[Numerator[#]===1,{},Head[Numerator[#]]=!=Times,
{Numerator[#]},True,Numerator[#]]/.Power[x_,n_]:>Table[x,{i,1,n}]]/.Pochhammer[z_,m_]:>{z, Plus@@(CoefficientRules[m,indices]/.Rule-> Times)},Last],
SortBy[Flatten[List@@Which[Denominator[#]===1,{},
Head[Denominator[#]]=!=Times,{Denominator[#]},True,Denominator[#]]/.Power[x_,n_]:> Table[x,{i,1,n}]]/.Pochhammer[z_,m_]:>{z, Plus@@(CoefficientRules[m,indices]/.Rule-> Times)},Last]}&@(poch[[i]]/(poch[[i]]/.Pochhammer[z_,m_]-> 1)),
Table[((#/.Pochhammer[z_,m_]-> 1/.Table[If[ktemp===jtemp,indices[[ktemp]]-> 1,indices[[ktemp]]-> 0],{ktemp,1,Length[indices]}]))&@poch[[i]],
{jtemp,1,Length[indices]}]}
,{i,1,Length[poch]}];
(*Print[list11];*)
Return[Prepend[list11,prefactor]]
]


(* ::Subsubsection::Closed:: *)
(*AllPDEs*)


AllPDEs[pde_List, var_List, order_List,maxOrd_] := Module[
  {allPDEs = pde, frontier = pde, frontierOrds = order,
    idx, newPDEs, newOrds},
  (*maxOrd = Max[order];*)
  While[
    (idx = Flatten@Position[frontierOrds, n_ /; n < maxOrd, {1},
                            Heads -> False]) =!= {},
    newPDEs = Flatten@Table[D[frontier[[i]], v], {i, idx}, {v, var}];
    newOrds = Flatten@Table[frontierOrds[[i]] + 1, {i, idx}, {v, var}];
    allPDEs = Join[allPDEs, newPDEs];
    frontier = newPDEs;
    frontierOrds = newOrds;
  ];
  Return[allPDEs];
]


(* ::Subsubsection::Closed:: *)
(*FFSolve*)


FFSolveNoReconstruct[ffEqs_,ffVars_, xVars_, lookfor_] := 
FFSolveNoReconstruct[ffEqs,ffVars, xVars, lookfor]= Module[
(*solves the equations ffEqs, with parameters ffVars (a,b,c,) and unknowns (x,y,z,...)
for the unknowns lookfor (y,z)*)

  {graphID, inNode, solverNode, sol, learnData, rec, M, n},

graphID = "PfaffGraph";
inNode = "Input";
solverNode = "Solver";
  
  
  sol        = {};


    FFNewGraph[graphID, inNode, ffVars];
   

    FFAlgDenseSolver[graphID, solverNode, {inNode},
      ffVars, ffEqs, xVars,
      "NeededVars" -> lookfor
    ];

    FFSolverOnlyHomogeneous[graphID, solverNode];
    FFGraphOutput[graphID, solverNode];

    learnData = FFDenseSolverLearn[graphID, xVars];
    (*Print[learnData];*)
    

    FFDeleteGraph[graphID];

    
  Return["IndepVars" /. learnData];
]


FFSolve[ffEqs_,ffVars_, xVars_, lookfor_] := 
FFSolve[ffEqs,ffVars, xVars, lookfor] = Module[
(*solves the equations ffEqs, with parameters ffVars (a,b,c,) and unknowns (x,y,z,...)
for the unknowns lookfor (y,z)*)

  {graphID, inNode, solverNode, sol, learnData, rec, M, n},

graphID = "PfaffGraph";
inNode = "Input";
solverNode = "Solver";
  
  
  sol        = {};


    FFNewGraph[graphID, inNode, ffVars];
   

    FFAlgDenseSolver[graphID, solverNode, {inNode},
      ffVars, ffEqs, xVars,
      "NeededVars" -> lookfor
    ];

    FFSolverOnlyHomogeneous[graphID, solverNode];
    FFGraphOutput[graphID, solverNode];

    learnData = FFDenseSolverLearn[graphID, xVars];
    (*Print[learnData];*)
    rec       = FFReconstructFunction[graphID, ffVars];

    FFDeleteGraph[graphID];

    If[rec =!= $Failed && rec =!= {},
      M = Partition[rec, Length["IndepVars" /. learnData]];
      AppendTo[sol,
        Thread[
          ("DepVars"   /. learnData) ->
           M . ("IndepVars" /. learnData)
        ]
      ]
    ];

  Return[sol[[-1]]];
]


FFSolveOnebyOne[ffEqs_,ffVars_, xVars_, lookfor_] := 
FFSolveOnebyOne[ffEqs,ffVars, xVars, lookfor] = Module[
(*solves the equations ffEqs, with parameters ffVars (a,b,c,) and unknowns (x,y,z,...)
for the unknowns lookfor (y,z)*)

  {graphID, inNode, solverNode, sol, learnData, rec, M, n},

graphID = "PfaffGraph";
inNode = "Input";
solverNode = "Solver";
  
  
  sol        = {};

  Do[
    FFNewGraph[graphID, inNode, ffVars];
    (*Print[lookfor[[-n ;; -1]]];*)

    FFAlgDenseSolver[graphID, solverNode, {inNode},
      ffVars, ffEqs, xVars,
      "NeededVars" -> lookfor[[-n ;; -1]]
    ];

    FFSolverOnlyHomogeneous[graphID, solverNode];
    FFGraphOutput[graphID, solverNode];

    learnData = FFDenseSolverLearn[graphID, xVars];
    (*Print[learnData];*)
    rec       = FFReconstructFunction[graphID, ffVars];

    FFDeleteGraph[graphID];

    If[rec =!= $Failed && rec =!= {},
      M = Partition[rec, Length["IndepVars" /. learnData]];
      AppendTo[sol,
        Thread[
          ("DepVars"   /. learnData) ->
           M . ("IndepVars" /. learnData)
        ]
      ]
    ],

    {n, 1, Length[lookfor]}
  ];

  Return[sol[[-1]]];
]


(* ::Subsubsection::Closed:: *)
(*Integrability Check*)


IntegrabilityCheckNum[M1_, M2_, var1_, var2_] :=
  Module[{dM2d1, dM1d2, commutator, check, PS, PassedQ=False},
  
    (*Generate rational numbers for 2 variables*)
    PS = RandomInteger[{1,999},2]/RandomInteger[{1,999},2];
    
    dM2d1      = D[M2, var1];               (* d_var1 M2 *)
    dM1d2      = D[M1, var2];               (* d_var2 M1 *)
    commutator = M1 . M2 - M2 . M1;

    (* Frobenius condition evaluated at the point PS *)
    check = (dM1d2 - dM2d1 + commutator) /. Thread[{var1,var2}-> PS] // Simplify;

    (* Safe zero check: flatten matrix and test all entries *)
    If[And @@ (# === 0 & /@ Flatten[check]),
      Print["PASSED for ", var1, " and ", var2];
      PassedQ=True;
      ,
      Print["FAILED for ", var1, " and ", var2, " \[Rule] ", check]
    ];
    Return[PassedQ]
  ];


(* ::Subsection::Closed:: *)
(*External Modules*)


(* ::Subsubsection::Closed:: *)
(*PDEGenerator*)


PDEGenerator[series_, indices_List, var_List, funcSymbol_ : F] :=
PDEGenerator[series, indices, var, funcSymbol] =
  Module[{coeff, AA, applyTheta, func},

    (* 1. Isolate the series coefficients by setting variables to 1 *)
    coeff = FullSimplify[series /. Thread[var -> 1]];

    (* 2. Compute the ratios of shifted coefficients: {Numerator, Denominator} *)
    AA = Table[
      Through[{Numerator, Denominator}[
        FullSimplify[(coeff /. indices[[j]] -> indices[[j]] + 1) / coeff]]],
      {j, 1, Length[indices]}
    ];

    (* 3. Define the Euler Theta operator (theta_x = x*d/dx).
          This maps a polynomial in the indices to differential operators on an expression. *)
    applyTheta[poly_, expr_] :=
      Module[{rules},
        rules = CoefficientRules[Expand[poly], indices];
        Total @ Map[
          #[[2]] * Fold[
            (* Apply x*D[#,x]& nested according to the index power *)
            Function[{e, vp}, Nest[vp[[1]] * D[#, vp[[1]]] &, e, vp[[2]]]],
            expr,
            Transpose[{var, #[[1]]}]
          ] &,
          rules
        ]
      ];

    (* 4. Define the generic function to apply the operators to, e.g. F[x,y] *)
    func = funcSymbol @@ var;

    (* 5. Generate the PDEs: Denominator(theta)[F/x_i] - Numerator(theta)[F] *)
    Table[
      Collect[
        Expand[
          applyTheta[AA[[i, 2]], func / var[[i]]] -
          applyTheta[AA[[i, 1]], func]
        ],
        {__Derivative, funcSymbol @@ var},
        Simplify
      ],
      {i, 1, Length[indices]}
    ]
  ];


(* ::Subsubsection::Closed:: *)
(*Find HypergeometricOrder*)


FindHypergeometricOrder[series_,indices_List, vars_List] :=
  Module[{coeff, AA, numDeg, denDeg, orderPerVar},

    (* 1. Isolate the pure coefficient by setting all variables to 1 *)
    coeff = FullSimplify[series /. Thread[vars -> 1]];

    (* 2. Compute the forward shift ratios c(n + e_i) / c(n) for each index,
          then split into {Numerator, Denominator} as polynomials in indices *)
    AA = Table[
      Through[{Numerator, Denominator}[
        Together@FunctionExpand[(coeff /. indices[[j]] -> indices[[j]] + 1) / coeff]]],
      {j, 1, Length[indices]}
    ];

    (* 3. Degree of numerator and denominator in ALL summation indices jointly *)
    numDeg = Table[
      Exponent[Expand[AA[[j, 1]]], indices, Max],
      {j, 1, Length[indices]}
    ];
    denDeg = Table[
      Exponent[Expand[AA[[j, 2]]], indices, Max],
      {j, 1, Length[indices]}
    ];

    (* 4. The PDE order in direction j is max(deg Num_j, deg Den_j) *)
    orderPerVar = MapThread[Max, {numDeg, denDeg}];

    Return[orderPerVar]
  ];


(* ::Subsubsection::Closed:: *)
(*Find HolonomicRank*)


FindHolonomicRank[exp_, indices_List, vars_List] :=
  Module[{Order, pde, rules, funcSymbol,infoser,genser,MaxDerivativeOrder,allpde,higherDerivs,xVars,
  ffVars,ffEqs,sol,rank,lookfor,seed, subs, invsubs},
     
     funcSymbol =  \[FormalF];
     (*Get the general series*)
     infoser = info[indices,exp];
     genser = generalser[indices,infoser];

    (* Automatically determine the PDE order from the generating series *)
    Order = FindHypergeometricOrder[genser[[1]],indices, vars] ;
    (*Print[Order];*)
    
    MaxDerivativeOrder = Total[Order-1]; (* the max order of derivative in the basis*)
    (*Print[MaxDerivativeOrder];*)
    
    (* Generate PDEs*)
    pde = PDEGenerator[genser[[1]],indices, vars,funcSymbol]/. genser[[2]];
    (*Print[pde];*)
    
    (*seed guess*)
    Which[
    Length[DeleteDuplicates[Order]]===1,seed = MaxDerivativeOrder+1;,
    True,
    seed = MaxDerivativeOrder+2;
    ];
    (*Print[seed];*)
    
    
    (* to find corner derivatives >>>>*)
    allpde = AllPDEs[pde,vars,Order,seed];(*<<<---- If needed change here!,*)
    
    (*Print[MaxDerivativeOrder];*)
    
    
    higherDerivs = Reverse @ SortBy[
      DeleteDuplicates @ Cases[allpde,
        expr_ /; Head[expr] === funcSymbol ||
                 MatchQ[Head[expr], Derivative[__][funcSymbol]],
        {0, Infinity}],
      {TotalDerivOrder, MaxIndexOrder}
    ];
    
    xVars = Array[\[FormalXi], Length[higherDerivs]];
    
    subs = Dispatch[Thread[higherDerivs -> xVars]];
    invsubs = Dispatch[Thread[xVars -> higherDerivs]];
    
    ffEqs=(#==0&/@allpde)/.subs;
    (*Print[ffEqs];*)
    
    ffVars = DeleteDuplicates[
      Cases[ffEqs, _Symbol(*?(Context[#] =!= "System`" &)*), Infinity]];
    ffVars = Complement[ffVars, xVars];
    ffVars = DeleteDuplicates[Join[ffVars, Flatten[{vars}]]];
    If[Length[ffVars] == 0, ffVars = {\[FormalZ]}];
    
    
    lookfor = Reverse @ SortBy[
      GenerateLatticeBasis[funcSymbol, vars, MaxDerivativeOrder],
      {TotalDerivOrder, MaxIndexOrder}
    ]/.subs;
    
    
	
	sol = FFSolveNoReconstruct[ffEqs,ffVars, xVars, lookfor]/.invsubs/.genser[[2]];
	
	
	
	Return[{sol//Length,SortBy[sol,{TotalDerivOrder, MaxIndexOrder}]}]
    
  ];


(* ::Code:: *)
(**)


(* ::Subsubsection::Closed:: *)
(*Find PfaffianSystem for auto basis*)


FindPfaffianSystem[exp_, indices_List, vars_List] := 
FindPfaffianSystem[exp, indices, vars] = 
  Module[
    {pde, infoser, genser, Order, basis, funcSymbol,
     allpde, higherDerivs, xVars, ffVars, ffEqs, rank, rawbasis, seed,
     lookfor, MaxDerivativeOrder,
     graphID, inNode, solverNode, hStackNode, hmStackNode,
     learnData, depVars, indepVars, xToDeriv, depDerivs, indepDerivs,
     DV, HV, HStack, mvec, rec, hmStackMat, hmPerDir,
     pfaffianMatrices, rawToIndep, Nbasis, AvList},

    funcSymbol = \[FormalF];

    infoser = info[indices, exp];
    genser  = generalser[indices, infoser];
    Order   = FindHypergeometricOrder[ genser[[1]],indices, vars];

    MaxDerivativeOrder = Total[Order - 1];

    pde = PDEGenerator[genser[[1]], indices, vars, funcSymbol] /. genser[[2]];

    Which[
      Length[DeleteDuplicates[Order]] === 1, seed = MaxDerivativeOrder + 1,
      True,                                  seed = MaxDerivativeOrder + 2 ];

    allpde = AllPDEs[pde, vars, Order, seed];

    higherDerivs = Reverse @ SortBy[
      DeleteDuplicates @ Cases[allpde,
        expr_ /; Head[expr] === funcSymbol ||
                 MatchQ[Head[expr], Derivative[__][funcSymbol]],
        {0, Infinity}],
      {TotalDerivOrder, MaxIndexOrder}];
    xVars = Array[\[FormalXi], Length[higherDerivs]];
    ffEqs = (# == 0 & /@ allpde) /. Thread[higherDerivs -> xVars];
    ffVars = DeleteDuplicates[Cases[ffEqs, _Symbol, Infinity]];
    ffVars = Complement[ffVars, xVars];
    ffVars = DeleteDuplicates[Join[ffVars, Flatten[{vars}]]];
    If[Length[ffVars] == 0, ffVars = {\[FormalZ]}];
    lookfor = Reverse @ SortBy[
      GenerateLatticeBasis[funcSymbol, vars, MaxDerivativeOrder],
      {TotalDerivOrder, MaxIndexOrder}
    ] /. Thread[higherDerivs -> xVars];

    rank = FFSolveNoReconstruct[ffEqs, ffVars, xVars, lookfor]
             /. Reverse /@ Thread[higherDerivs -> xVars]
             /. genser[[2]];

    rawbasis = SortBy[rank, {TotalDerivOrder, MaxIndexOrder}];
    basis = If[MatchQ[Head[#], Derivative[__][funcSymbol]],
               # Times @@ Power[vars, (List @@ (#[[0, 0]]))],
               #] & /@ rawbasis;

    (* restrict lookfor to derivatives of rawbasis *)
    lookfor = Reverse @ SortBy[
      DeleteDuplicates @ Cases[Flatten[Table[D[rawbasis, v], {v, vars}]],
        expr_ /; Head[expr] === funcSymbol ||
                 MatchQ[Head[expr], Derivative[__][funcSymbol]],
        {0, Infinity}],
      {TotalDerivOrder, MaxIndexOrder}
    ] /. Thread[higherDerivs -> xVars];

    Nbasis = Length[basis];

    (* build dense-solver graph and learn *)
    graphID     = "PfaffGraphFF";
    inNode      = "Input";
    solverNode  = "Solver";
    hStackNode  = "HStack";
    hmStackNode = "HMStack";

    FFNewGraph[graphID, inNode, ffVars];
    FFAlgDenseSolver[graphID, solverNode, {inNode}, ffVars, ffEqs, xVars,
      "NeededVars" -> lookfor];
    FFSolverOnlyHomogeneous[graphID, solverNode];
    FFGraphOutput[graphID, solverNode];

    learnData   = FFDenseSolverLearn[graphID, xVars];
    depVars     = "DepVars"   /. learnData;
    indepVars   = "IndepVars" /. learnData;

    xToDeriv    = Thread[xVars -> higherDerivs];
    depDerivs   = depVars   /. xToDeriv;
    indepDerivs = indepVars /. xToDeriv;

    (* permutation: rawbasis[[k]] == indepDerivs[[ rawToIndep[[k]] ]] *)
    rawToIndep =
      Flatten[FirstPosition[indepDerivs, #, {0}, {1}] & /@ rawbasis];
    If[MemberQ[rawToIndep, 0],
      Message[FindPfaffianSystem::mismatch]
    ];

    (* precompute D_v and H_v symbolically (polynomials in vars only) *)
    DV = Association[];
    HV = Association[];
    Module[{allDerivs = Join[indepDerivs, depDerivs]},
      Do[
        Module[{dExprList, fullCoef, nIndep = Length[indepDerivs]},
          dExprList = Table[D[basis[[i]], v], {i, Nbasis}];
          fullCoef  = Normal[CoefficientArrays[dExprList, allDerivs][[2]]];
          DV[v] = fullCoef[[All, 1 ;; nIndep]];
          HV[v] = fullCoef[[All, nIndep + 1 ;; All]];
        ],
        {v, vars}
      ]
    ];

    (* extend graph with stacked H * M *)
    HStack = Flatten[Table[HV[v], {v, vars}], 1];
    FFAlgRatFunEval[graphID, hStackNode, {inNode}, ffVars, Flatten[HStack]];
    FFAlgMatMul[graphID, hmStackNode, {hStackNode, solverNode},
      Length[vars] * Nbasis, Length[depDerivs], Length[indepDerivs]];
    FFGraphOutput[graphID, hmStackNode];

    rec = FFReconstructFunction[graphID, ffVars];

    FFDeleteGraph[graphID];

    (* assemble A_v in Mathematica *)
    hmStackMat = Partition[rec, Length[indepDerivs]];
    hmPerDir   = Partition[hmStackMat, Nbasis];
    hmPerDir   = hmPerDir /. genser[[2]];

    mvec = basis / rawbasis;

    AvList = Table[
      Module[{coefM, vCur = vars[[idx]]},
        coefM = DV[vCur] + hmPerDir[[idx]];
        coefM = coefM[[All, rawToIndep]];
        Table[coefM[[i, j]] / mvec[[j]], {i, Nbasis}, {j, Nbasis}]
      ],
      {idx, Length[vars]}
    ];

    pfaffianMatrices = AssociationThread[vars -> AvList];

    {exp, indices, pfaffianMatrices, basis}
  ];

FindPfaffianSystem::mismatch =
  "rawbasis and indepDerivs do not match as sets; result may be wrong.";


(* ::Subsubsection::Closed:: *)
(*Find PfaffianSystem for a given basis*)


FindPfaffianSystemBasis[exp_, indices_List, vars_List,basis0_] :=
FindPfaffianSystemBasis[exp, indices, vars, basis0] =
 Module[{pde,MaxOrder,rules,F,infoser,genser,result,Order,basis,funcSymbol,de,maxorder,allpde,higherDerivs,xVars,ffVars,ffEqs,rank,rawbasis,lookfor,MaxDerivativeOrder,sol,sol2,T,Tinv,weightVector,pfaffianMatrices,
 seed,subs,invsubs,graphID,inNode,solverNode,hStackNode,hmStackNode,learnData,depVars,indepVars,xToDeriv,depDerivs,indepDerivs,DV,HV,HStack,mvec,rec,hmStackMat,hmPerDir,rawToIndep,Nbasis,AvList},
  
   funcSymbol =  \[FormalF];
     (*Get the general series*)
     infoser = info[indices,exp];
     genser = generalser[indices,infoser];

    (* Automatically determine the PDE order from the generating series *)
    Order = FindHypergeometricOrder[genser[[1]],indices, vars] ;
    (*Print[Order];*)
    
    MaxDerivativeOrder = Total[Order-1]; (* the max order of derivative in the basis*)
    (*Print[MaxDerivativeOrder];*)
    
    (* Generate PDEs*)
    pde = PDEGenerator[genser[[1]],indices, vars,funcSymbol]/. genser[[2]];
    (*Print[pde];*)
    
    (*seed guess*)
    Which[
    Length[DeleteDuplicates[Order]]===1,seed = MaxDerivativeOrder+1;,
    True,
    seed = MaxDerivativeOrder+2;
    ];
    (*Print[seed];*)
    
    
    (* to find corner derivatives >>>>*)
    allpde = AllPDEs[pde,vars,Order,seed];(*<<<---- If needed change here!,*)
    
    (*Print[MaxDerivativeOrder];*)
    
    
    higherDerivs = Reverse @ SortBy[
      DeleteDuplicates @ Cases[allpde,
        expr_ /; Head[expr] === funcSymbol ||
                 MatchQ[Head[expr], Derivative[__][funcSymbol]],
        {0, Infinity}],
      {TotalDerivOrder, MaxIndexOrder}
    ];
    
    xVars = Array[\[FormalXi], Length[higherDerivs]];
    
    subs = Dispatch[Thread[higherDerivs -> xVars]];
    invsubs = Dispatch[Thread[xVars -> higherDerivs]];
    
    ffEqs=(#==0&/@allpde)/.subs;
    (*Print[ffEqs];*)
    
    ffVars = DeleteDuplicates[
      Cases[ffEqs, _Symbol(*?(Context[#] =!= "System`" &)*), Infinity]];
    ffVars = Complement[ffVars, xVars];
    ffVars = DeleteDuplicates[Join[ffVars, Flatten[{vars}]]];
    If[Length[ffVars] == 0, ffVars = {\[FormalZ]}];
    
    
    lookfor = Reverse @ SortBy[
      GenerateLatticeBasis[funcSymbol, vars, MaxDerivativeOrder],
      {TotalDerivOrder, MaxIndexOrder}
    ]/.subs;
    
    
    rank = FFSolveNoReconstruct[ffEqs,ffVars, xVars, lookfor]/.invsubs/.genser[[2]];
    
    
    
    rawbasis = SortBy[rank,{TotalDerivOrder, MaxIndexOrder}];
    
    If[Length[rawbasis]=!=Length[basis0],Print[StringTemplate["expected `n` entries"][<|"n" -> Length[rawbasis]|>]]; Abort[]];
    
    basis = basis0;
    rawbasis = 
      Table[
        First @ Cases[b,
          expr_ /; Head[expr] === funcSymbol ||
                   MatchQ[Head[expr], Derivative[__][funcSymbol]],
          {0, Infinity}],
        {b, basis}
      ];
    
    
    
    
     (* restrict lookfor to derivatives of rawbasis *)
    lookfor = Reverse @ SortBy[
      DeleteDuplicates @ Cases[Flatten[Table[D[rawbasis, v], {v, vars}]],
        expr_ /; Head[expr] === funcSymbol ||
                 MatchQ[Head[expr], Derivative[__][funcSymbol]],
        {0, Infinity}],
      {TotalDerivOrder, MaxIndexOrder}
    ] /. Thread[higherDerivs -> xVars];

    Nbasis = Length[basis];

    (* build dense-solver graph and learn *)
    graphID     = "PfaffGraphFF";
    inNode      = "Input";
    solverNode  = "Solver";
    hStackNode  = "HStack";
    hmStackNode = "HMStack";

    FFNewGraph[graphID, inNode, ffVars];
    FFAlgDenseSolver[graphID, solverNode, {inNode}, ffVars, ffEqs, xVars,
      "NeededVars" -> lookfor];
    FFSolverOnlyHomogeneous[graphID, solverNode];
    FFGraphOutput[graphID, solverNode];

    learnData   = FFDenseSolverLearn[graphID, xVars];
    depVars     = "DepVars"   /. learnData;
    indepVars   = "IndepVars" /. learnData;

    xToDeriv    = Thread[xVars -> higherDerivs];
    depDerivs   = depVars   /. xToDeriv;
    indepDerivs = indepVars /. xToDeriv;

    (* permutation: rawbasis[[k]] == indepDerivs[[ rawToIndep[[k]] ]] *)
    rawToIndep =
      Flatten[FirstPosition[indepDerivs, #, {0}, {1}] & /@ rawbasis];
    If[MemberQ[rawToIndep, 0],
      Message[FindPfaffianSystemBasis::mismatch]
    ];

    (* precompute D_v and H_v symbolically (polynomials in vars only) *)
    DV = Association[];
    HV = Association[];
    Module[{allDerivs = Join[indepDerivs, depDerivs]},
      Do[
        Module[{dExprList, fullCoef, nIndep = Length[indepDerivs]},
          dExprList = Table[D[basis[[i]], v], {i, Nbasis}];
          fullCoef  = Normal[CoefficientArrays[dExprList, allDerivs][[2]]];
          DV[v] = fullCoef[[All, 1 ;; nIndep]];
          HV[v] = fullCoef[[All, nIndep + 1 ;; All]];
        ],
        {v, vars}
      ]
    ];

    (* extend graph with stacked H * M *)
    HStack = Flatten[Table[HV[v], {v, vars}], 1];
    FFAlgRatFunEval[graphID, hStackNode, {inNode}, ffVars, Flatten[HStack]];
    FFAlgMatMul[graphID, hmStackNode, {hStackNode, solverNode},
      Length[vars] * Nbasis, Length[depDerivs], Length[indepDerivs]];
    FFGraphOutput[graphID, hmStackNode];

    rec = FFReconstructFunction[graphID, ffVars];

    FFDeleteGraph[graphID];

    (* assemble A_v in Mathematica *)
    hmStackMat = Partition[rec, Length[indepDerivs]];
    hmPerDir   = Partition[hmStackMat, Nbasis];
    hmPerDir   = hmPerDir /. genser[[2]];

    mvec = basis / rawbasis;

    AvList = Table[
      Module[{coefM, vCur = vars[[idx]]},
        coefM = DV[vCur] + hmPerDir[[idx]];
        coefM = coefM[[All, rawToIndep]];
        Table[coefM[[i, j]] / mvec[[j]], {i, Nbasis}, {j, Nbasis}]
      ],
      {idx, Length[vars]}
    ];

    pfaffianMatrices = AssociationThread[vars -> AvList];

   Return[ {exp, indices, pfaffianMatrices, basis}];
    
    
   
    
    
    
    
    
         
  ];
  
  FindPfaffianSystemBasis::mismatch =
  "rawbasis and indepDerivs do not match as sets; result may be wrong.";


(* ::Subsubsection::Closed:: *)
(*CheckIntegrability*)


CheckIntegrability[pfaffianRaw_, vars_List] :=
  Module[{pairs,pfaffian,AllPair},

If[Length@vars===1, AllPair ={True},		
    (* Generate all ordered pairs {var_i, var_j} with i < j *)
    pairs = Subsets[vars, {2}];
    pfaffian=pfaffianRaw[[3]];

    (* Call IntegrabilityCheck for every pair and collect residual matrices *)
    AllPair=(IntegrabilityCheckNum[pfaffian[#[[1]]],pfaffian[#[[2]]],#[[1]],#[[2]]] & /@ pairs);
   ]; 
If[And@@AllPair,Print["PASSED!!"],Print["FAILED!!"]];
Return[And@@AllPair]
  ];


(* ::Section::Closed:: *)
(*Numerical Evaluation of Pfaffian System*)


(* ::Subsection::Closed:: *)
(*Internal Modules*)


(* ::Subsubsection::Closed:: *)
(*Find Singular Curves*)


FindSingularCurves[Pfaffian_,Vars_]:=Module[{PfaffianFlat,AllDen,AllDenVar,AllDenProd},
PfaffianFlat=Pfaffian[[#]]&/@(Range@Length@Pfaffian)//Flatten//Together;
AllDen=Denominator[PfaffianFlat]//Flatten;
AllDenVar=Select[AllDen,ContainsAny[Variables[#],Vars]&];
AllDenProd=Times@@AllDenVar//Together;
FactorList[AllDenProd]//Transpose//First//Rest//Select[#,ContainsOnly[Variables[#],Vars]&]&]


(* ::Subsubsection::Closed:: *)
(*Catch Required Fids*)


GetRequiredFids[de_,bd_]:=Module[{sysid="Probe$"<>ToString[Unique[]]},
Catch[LoadSystem[sysid,de,bd,Infinity];
InfToRegular[sysid,1/2];
{},"RequiredFids"]]


(* ::Subsubsection::Closed:: *)
(*Re-evaluate Boundary Condition*)


GetBoundaryFids[BasisSer_,SumVar_,Vars_,Fids_,TargetVal_,OldBoundaryValInf_,ParSub_,\[Epsilon]Val_]:=
Module[{\[Eta],NewBoundaryValInf,SumList,FidsCompute,SumTemp,SumExp,NewBd,BasisID,BasisOrder,NewBdRaw,\[Epsilon]Dum,\[Epsilon]ParSub},
\[Epsilon]ParSub=Thread[Keys@ParSub->((Values@ParSub)+\[Epsilon]Dum)];
FidsCompute=Select[Fids,#[[2]]=!=0&];
NewBoundaryValInf=OldBoundaryValInf;
Do[
BasisID=FidsCompute[[i,1]];
BasisOrder=FidsCompute[[i,2]];
SumTemp=Sum[Evaluate[BasisSer[[BasisID]]],Evaluate[Sequence@@(Thread[{SumVar,0,BasisOrder}])]];
SumExp=SumTemp/.(Thread[Vars->TargetVal/(1+\[Eta])])//Series[#,{\[Eta],Infinity,BasisOrder}]&//Normal;
NewBdRaw=Coefficient[SumExp,\[Eta],-BasisOrder];
NewBd=NewBdRaw//Limit[#,ParSub]&//Limit[#,\[Epsilon]Val]&;
(*If[!NumericQ[NewBd],NewBd=NewBdRaw//Limit[#,\[Epsilon]ParSub]&//Limit[#,\[Epsilon]Val]&//Limit[#,{\[Epsilon]Dum->0}]&];*)
If[!NumericQ[NewBd],Print["The result is divergent or indeterminant. Consider adding ",Keys@\[Epsilon]Val," to the parameters."];Abort[]];
NewBoundaryValInf=ReplacePart[NewBoundaryValInf,BasisID->Append[OldBoundaryValInf[[BasisID]],-BasisOrder->NewBd]];
,{i,Length@FidsCompute}];
Return[NewBoundaryValInf]
]


(* ::Subsubsection::Closed:: *)
(*Generate Epsilon Grid Configuration*)


(* Adapted from AMFlow.m https://gitlab.com/multiloop-pku/amflow *)


GenerateNumericalConfig[goal_,order_,loop_]:=Block[{number,eps0,epslist,singlepre,workpre,xorder},(*loop=Max[Length[Loop],1];*)
number=Ceiling[5/2*order+2*loop];
eps0=Power[10,-1/2*loop-goal*(order+1)^-1];
eps0=Rationalize[N[eps0,MachinePrecision],eps0/100];
If[number>100,Print["GenerateNumericalConfig: the given order is too large to evaluate."];Abort[]];
epslist=eps0+Range[number]*eps0/100;
singlepre=Max[Ceiling[(number+2*loop)*(1/2*loop+goal*(order+1)^-1)],30];
workpre=Ceiling[1.5*singlepre];
xorder=Ceiling[2.5*singlepre];
{epslist,workpre,xorder}];


(* ::Subsubsection::Closed:: *)
(*Find Lowest Epsilon Order*)


\[Epsilon]LO[Ser_,SumVar_,ParSub_,Eps_]:=Module[{\[Epsilon]LOPow,SerSub,\[Epsilon]PocFacList,signList,\[Epsilon]PocSingFacList,contribList,sumVarAssumptions,nPoch,contribSigns,vanishPreds,allCells,cellConditions,cellNonEmpty,cellContribs,validContribs},
\[Epsilon]LOPow=0;
SerSub=Ser/.{1/Pochhammer[a_,b_]:>(-1)^b Pochhammer[1-a,-b]}/.ParSub;
\[Epsilon]PocFacList=Cases[SerSub,(Pochhammer[a_,b_]/;!FreeQ[a,Eps]):>{a,b},{0,Infinity}];
signList=Table[Join[Which[!Element[i[[1]],Integers],{Infinity},i[[1]]<=0,{-1},i[[1]]>=1,{1}],Coefficient[i[[2]],SumVar]],{i,\[Epsilon]PocFacList/.{Eps->0}}];
\[Epsilon]PocSingFacList=Table[If[ContainsExactly[DeleteCases[signList[[i]],0],{-1,1}],\[Epsilon]PocFacList[[i]],Nothing],{i,Length@\[Epsilon]PocFacList}];

contribList=Table[With[{a0=\[Epsilon]PocSing[[1]]/. Eps->0,L=\[Epsilon]PocSing[[2]]},If[a0<=0,{-1,L>=-a0+1},{+1,L<=-a0}]],{\[Epsilon]PocSing,\[Epsilon]PocSingFacList}];
     sumVarAssumptions=And@@Thread[SumVar>=0];
     nPoch=Length[\[Epsilon]PocSingFacList];

\[Epsilon]LOPow=If[nPoch==0,0,
contribSigns=contribList[[All,1]];
vanishPreds=contribList[[All,2]];
allCells=Tuples[{0,1},nPoch];
cellConditions=Table[And@@MapThread[If[#1==1,#2,!#2]&,{cell,vanishPreds}],{cell,allCells}];
cellNonEmpty=Table[Resolve[Exists[Evaluate[SumVar],sumVarAssumptions&&cond],NonNegativeIntegers],{cond,cellConditions}];
cellContribs=Table[cell . contribSigns,{cell,allCells}];
validContribs=Pick[cellContribs,cellNonEmpty];
-Max[validContribs]];

\[Epsilon]LOPow
]


(* ::Subsubsection::Closed:: *)
(*DESolver Configuration*)


TransportDESolver[StartingPoint_,InitialBoundaryVal_,TargetPoint_,Pfaffian_,Vars_,ParSub_,NPrec_,\[CapitalDelta]_,Dim_,VerboseQ_,ParallelQ_,{Eps_,Ord_},\[Epsilon]LOOut_,BasisSer_,SumVar_,SingCurves_]:=
Module[{PrintVerbose,\[Epsilon]PowList,BoundaryValList,\[Epsilon]List,WPrec,XOrder,\[Epsilon]Sub,TransportLine,DiffEq,DiffEqInf,
BoundaryValInf,DiffEq\[Epsilon]List,BoundaryVal,\[Epsilon]FitList,Fids,RealQ,OverlapSing},
\[Epsilon]PowList=Power[Eps,Range[\[Epsilon]LOOut,Ord]];
BoundaryValList={};
PrintVerbose[args___]:=If[VerboseQ,Print[args]];
{\[Epsilon]List, WPrec, XOrder}=GenerateNumericalConfig[NPrec, Ord-2\[Epsilon]LOOut,0];
If[Ord===0&&\[Epsilon]LOOut===0,WPrec=Ceiling[NPrec*1.5];XOrder=Ceiling[NPrec*2.5]];
\[Epsilon]Sub=Thread[Eps->\[Epsilon]List];
PrintVerbose["Computing ",Eps," at ",Length@\[Epsilon]List," points."];
PrintVerbose[Eps," grid values \[Rule] ",Block[{$MinPrecision,$MaxPrecision},N[\[Epsilon]List,4]]];
RealQ=({0}===DeleteDuplicates[Im/@TargetPoint]);
Block[{Print},
SetDefaultOptions[];
SetGlobalOptions["WorkingPre"->WPrec,"ChopPre"->WPrec-1,"RationalizePre"->WPrec,"SilentMode"->!VerboseQ];
	SetRunningOptions["RunRadius"->2,"RunLength"->1000,"RunDirection"->Which[\[CapitalDelta]===I&&RealQ,"NegIm",\[CapitalDelta]===-I&&RealQ,"Im",True,"Re"]];
	SetExpansionOptions["XOrder"->XOrder,"ExtraXOrder"->50,"LearnXOrder"->-1,"TestXOrder"->5]];

PrintVerbose["Transporting Differential Equation"];


TransportLine=StartingPoint+(TargetPoint-StartingPoint)*eta;
OverlapSing=Position[Expand[SingCurves/.Thread[Vars->TransportLine]],0]//Flatten;
If[OverlapSing=!={},
PrintVerbose["Original contour lies on a singular locus so using a bulged contour."];
Module[{d=TargetPoint-StartingPoint,mid=StartingPoint+(TargetPoint-StartingPoint)/2,GradVal,Bulge},
GradVal=Total[Grad[#,Vars]&/@SingCurves[[OverlapSing]]]/.Thread[Vars->mid]/.ParSub;
Bulge=(GradVal-(GradVal . d)/(d . d)*d);
TransportLine=TransportLine+eta(1-eta)*Bulge;
]];
    

DiffEq=Sum[Pfaffian[[i]]*D[TransportLine[[i]],eta],{i,Dim}]/.Thread[Vars->TransportLine]/.ParSub//Together;
DiffEqInf=(DiffEq/.{eta->(1+eta)^-1})*(-(1+eta)^-2)//Together;
BoundaryValInf=Table[{0->i},{i,InitialBoundaryVal}];

If[Length@\[Epsilon]Sub===0,DiffEq\[Epsilon]List={DiffEqInf/.Eps->0};\[Epsilon]Sub={Eps->0},DiffEq\[Epsilon]List=(DiffEqInf/.#)&/@\[Epsilon]Sub//Together];

Fids=GetRequiredFids[DiffEq\[Epsilon]List[[1]],BoundaryValInf];

PrintVerbose["Fids \[Rule] ",Fids];

BoundaryValList = If[ParallelQ&&(Length@\[Epsilon]Sub>1),

DistributeDefinitions[RegularRunDE, GetBoundaryFids];
  With[{deList = DiffEq\[Epsilon]List, eSub = \[Epsilon]Sub,
        bvInf = BoundaryValInf, delta = \[CapitalDelta], vQ = VerboseQ,
        wp = WPrec, xo = XOrder, bs = BasisSer, sv = SumVar, vs = Vars,
        tp = TargetPoint, ps = ParSub, fd = Fids},
    ParallelTable[
      Quiet[RegularRunDE[deList[[i]], eSub[[i]], bvInf, delta, vQ,
                         wp, xo, bs, sv, vs, tp, ps, fd][[1]]],
      {i, Length@deList}
    ]
  ],
  Table[
    RegularRunDE[DiffEq\[Epsilon]List[[i]], \[Epsilon]Sub[[i]], BoundaryValInf,
                 \[CapitalDelta], VerboseQ, WPrec, XOrder, BasisSer,
                 SumVar, Vars, TargetPoint, ParSub, Fids][[1]],
    {i, Length@DiffEq\[Epsilon]List}
  ]
];

If[\[Epsilon]Sub==={Eps->0},BoundaryVal=BoundaryValList[[1]],
\[Epsilon]FitList=FitEps[Thread[\[Epsilon]List->BoundaryValList],\[Epsilon]LOOut];
BoundaryVal=\[Epsilon]FitList[[Range[Ord-\[Epsilon]LOOut+1]]] . \[Epsilon]PowList];
SetGlobalOptions["WorkingPre"->NPrec];
Return[Block[{$MinPrecision,$MaxPrecision},N[BoundaryVal,NPrec]//Chop[#,10^-NPrec]&]];
];


(* ::Subsubsection::Closed:: *)
(*DESolver Runner*)


RegularRunDE[DiffEqInf_,\[Epsilon]Val_,BoundaryValInf_,\[CapitalDelta]_,VerboseQ_,WPrec_,XOrder_,BasisSer_,SumVar_,Vars_,TargetPoint_,ParSub_,Fids_]:=
Module[{PrintVerbose,DiffEq,NewPoleList,Inf2Fin,FinalBoundaryValue,SystemID,NewBoundaryValInf,RealQ},

RealQ=({0}===DeleteDuplicates[Im/@TargetPoint]);
Block[{Print},
SetDefaultOptions[];
SetGlobalOptions["WorkingPre"->WPrec,"ChopPre"->WPrec-1,"RationalizePre"->WPrec,"SilentMode"->!VerboseQ];
	SetRunningOptions["RunRadius"->2,"RunLength"->1000,"RunDirection"->Which[\[CapitalDelta]===I&&RealQ,"NegIm",\[CapitalDelta]===-I&&RealQ,"Im",True,"Re"]];
	SetExpansionOptions["XOrder"->XOrder,"ExtraXOrder"->50,"LearnXOrder"->-1,"TestXOrder"->5]];
PrintVerbose[args___]:=If[VerboseQ,Print[args]];

SystemID="Transport";
ClearSystem[SystemID]//Quiet;


If[Fids==={},
NewBoundaryValInf=BoundaryValInf,
NewBoundaryValInf=GetBoundaryFids[BasisSer,SumVar,Vars,Fids,TargetPoint,BoundaryValInf,ParSub,\[Epsilon]Val];
PrintVerbose["Recomputed Boundary Value at Origin \[Rule] ",NewBoundaryValInf];
];

LoadSystem[SystemID, DiffEqInf, NewBoundaryValInf, Infinity];
NewPoleList=GetPoles[DiffEqInf]//Sort;
Inf2Fin=RunEta[NewPoleList];
InfToRegular[SystemID, Inf2Fin[[1]]];
RegularRun[SystemID, Inf2Fin];
SolveAsyExp[SystemID];

FinalBoundaryValue=PickZeroRuleS/@AsyExp[SystemID];
ClearSystem[SystemID];
Return[FinalBoundaryValue]
];


(* ::Subsection::Closed:: *)
(*External Modules*)


(* ::Subsubsection::Closed:: *)
(*TransportDE*)


Options[TransportDE]={IDelta->-I,VerboseMode->False,ParallelRun->True};


TransportDE[PfaffianIN_,ParSubRaw_,VarsSubRaw_,{Eps_,OrdRaw_},NPrec_,OptionsPattern[]]:=
Module[{DiffEq,BoundaryVal,TransportLine,PoleList,RunSegmentOut,CurrentPoint,\[CapitalDelta],SingCurve,
Dim,DESolverQ,DiffExpQ,DimBasis,StartingQ,RecomputeBoundaryQ,BoundaryPoint,InitialBoundary,
LimList,StartingPointVal,PrintVerbose,VerboseQ,Vars,TargetPoint,ParallelQ,\[Epsilon]LOOut,Ser,Pfaffian,
SumVar,Basis,BasisPow,BasisSer,\[Epsilon]Q,Ord,SingCurves,ParSub,VarsSub},
ParSub=ParSubRaw//Rationalize[#,10^-NPrec]&;
VarsSub=VarsSubRaw//Rationalize[#,10^-NPrec]&;
VerboseQ=OptionValue[VerboseMode];
ParallelQ=OptionValue[ParallelRun];
\[CapitalDelta]=OptionValue[IDelta];
Ser=PfaffianIN[[1]];
SumVar=PfaffianIN[[2]];
Pfaffian=PfaffianIN[[3]];
Basis=PfaffianIN[[4]];
Vars=Keys@VarsSub;
TargetPoint=Values@VarsSub;
SingCurves=FindSingularCurves[Pfaffian,Vars];
If[MemberQ[SingCurves/.VarsSub,0],
Print["Warning! Target Point lies on a branch cut, so the result might be divergent in some cases."]];
BasisSer=Basis/.{\[FormalF]->Function[Evaluate@Vars,Evaluate@Ser]};
PrintVerbose[args___]:=If[VerboseQ,Print[args]];
\[Epsilon]Q=DeleteDuplicates@Cases[ExpandAll[Ser/.ParSub],s_Symbol/;Context[s]=!="System`",{0,Infinity},Heads->True]//MemberQ[#,Eps]&;
Ord=OrdRaw;
If[\[Epsilon]Q,\[Epsilon]LOOut=\[Epsilon]LO[Ser,SumVar,ParSub,Eps],Ord=0;\[Epsilon]LOOut=0];
If[\[Epsilon]LOOut>Ord,Print["Cannot expand to order ",Ord," in ",Eps," because the function's lowest non-vanishing order is ",\[Epsilon]LOOut,"."];
Abort[],PrintVerbose["Lowest Order of ",Eps,": ",\[Epsilon]LOOut]];
If[!MemberQ[{-I,I},\[CapitalDelta]],Print["IDelta can be only \[PlusMinus] I"];Abort[];];
Dim=Length@Vars;
DESolverQ=False;
DiffExpQ=False;
DimBasis=Pfaffian[[1,1]]//Length;
StartingQ=False;
RecomputeBoundaryQ=False;

BoundaryPoint=ConstantArray[0,Dim];
BoundaryVal=UnitVector[DimBasis,1];

PrintVerbose["Starting Boundary Point \[Rule] ", BoundaryPoint//N];
PrintVerbose["Starting Boundary Value \[Rule] ", BoundaryVal//N];

PrintVerbose["Running DESolver for numerical evaluation"];
BoundaryVal=TransportDESolver[BoundaryPoint,BoundaryVal,TargetPoint,Pfaffian,Vars,ParSub,NPrec,\[CapitalDelta],Dim,VerboseQ,ParallelQ,{Eps,Ord},\[Epsilon]LOOut,BasisSer,SumVar,SingCurves];
$MaxPrecision=Infinity;$MinPrecision=0;
If[ParallelQ,ParallelEvaluate[$MaxPrecision=Infinity;$MinPrecision=0;]];
BoundaryVal
]


(* ::Section::Closed:: *)
(*Pre-defined Hypergeometric Function Definitions*)


(* ::Subsection:: *)
(*Internal Modules*)


(* ::Subsubsection::Closed:: *)
(*Function Definitions*)


DefPFPm1[p_Integer /; p >= 2] := Module[{a, b},
  a = Table[Symbol["\[FormalA]" <> ToString[i]], {i, p}];
  b = Table[Symbol["\[FormalB]" <> ToString[i]], {i, p - 1}];
  {Join[a, b], {\[FormalX]},
   Product[Pochhammer[a[[i]], \[FormalN]], {i, p}] /
   (Product[Pochhammer[b[[i]], \[FormalN]], {i, p - 1}] * \[FormalN]!) *
   \[FormalX]^\[FormalN]}]


DefG1:={{\[FormalA],\[FormalB],\[FormalC]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],\[FormalM]+\[FormalN]]*Pochhammer[\[FormalB],\[FormalN]-\[FormalM]]*Pochhammer[\[FormalC],\[FormalM]-\[FormalN]]*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefG2:={{\[FormalA],\[FormalB],\[FormalC],\[FormalD]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],\[FormalM]]*Pochhammer[\[FormalB],\[FormalN]]*Pochhammer[\[FormalC],\[FormalN]-\[FormalM]]*Pochhammer[\[FormalD],\[FormalM]-\[FormalN]]*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefG3:={{\[FormalA],\[FormalB]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],2\[FormalN]-\[FormalM]]*Pochhammer[\[FormalB],2\[FormalM]-\[FormalN]]*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefH1:={{\[FormalA],\[FormalB],\[FormalC],\[FormalD]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],\[FormalM]-\[FormalN]]*Pochhammer[\[FormalB],\[FormalM]+\[FormalN]]*Pochhammer[\[FormalC],\[FormalN]]/Pochhammer[\[FormalD],\[FormalM]]*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefH2:={{\[FormalA],\[FormalB],\[FormalC],\[FormalD],\[FormalE]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],\[FormalM]-\[FormalN]]*Pochhammer[\[FormalB],\[FormalM]]*Pochhammer[\[FormalC],\[FormalN]]*Pochhammer[\[FormalD],\[FormalN]]/Pochhammer[\[FormalE],\[FormalM]]*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefH3:={{\[FormalA],\[FormalB],\[FormalC]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],2\[FormalM]+\[FormalN]]*Pochhammer[\[FormalB],\[FormalN]]/Pochhammer[\[FormalC],\[FormalM]+\[FormalN]]*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefH4:={{\[FormalA],\[FormalB],\[FormalC],\[FormalD]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],2\[FormalM]+\[FormalN]]*Pochhammer[\[FormalB],\[FormalN]]/(Pochhammer[\[FormalC],\[FormalM]]*Pochhammer[\[FormalD],\[FormalN]])*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefH5:={{\[FormalA],\[FormalB],\[FormalC]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],2\[FormalM]+\[FormalN]]*Pochhammer[\[FormalB],\[FormalN]-\[FormalM]]/Pochhammer[\[FormalC],\[FormalN]]*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefH6:={{\[FormalA],\[FormalB],\[FormalC]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],2\[FormalM]-\[FormalN]]*Pochhammer[\[FormalB],\[FormalN]-\[FormalM]]*Pochhammer[\[FormalC],\[FormalN]]*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefH7:={{\[FormalA],\[FormalB],\[FormalC],\[FormalD]},{\[FormalX],\[FormalY]},Pochhammer[\[FormalA],2\[FormalM]-\[FormalN]]*Pochhammer[\[FormalB],\[FormalN]]*Pochhammer[\[FormalC],\[FormalN]]/Pochhammer[\[FormalD],\[FormalM]]*\[FormalX]^\[FormalM]/\[FormalM]!*\[FormalY]^\[FormalN]/\[FormalN]!}

DefLauricellaFA[n_Integer?Positive]:=Module[{b,c,x,m},b=Table[Symbol["\[FormalB]"<>ToString[i]],{i,n}];
c=Table[Symbol["\[FormalC]"<>ToString[i]],{i,n}];
x=Table[Symbol["\[FormalX]"<>ToString[i]],{i,n}];
m=Table[Symbol["\[FormalM]"<>ToString[i]],{i,n}];
{Join[{\[FormalA]},b,c],x,Pochhammer[\[FormalA],Total[m]]*Product[Pochhammer[b[[i]],m[[i]]],{i,n}]/Product[Pochhammer[c[[i]],m[[i]]]*m[[i]]!,{i,n}]*Product[x[[i]]^m[[i]],{i,n}]}]

DefLauricellaFB[n_Integer?Positive]:=Module[{a,b,x,m},a=Table[Symbol["\[FormalA]"<>ToString[i]],{i,n}];
b=Table[Symbol["\[FormalB]"<>ToString[i]],{i,n}];
x=Table[Symbol["\[FormalX]"<>ToString[i]],{i,n}];
m=Table[Symbol["\[FormalM]"<>ToString[i]],{i,n}];
{Join[a,b,{\[FormalC]}],x,Product[Pochhammer[a[[i]],m[[i]]],{i,n}]*Product[Pochhammer[b[[i]],m[[i]]],{i,n}]/(Pochhammer[\[FormalC],Total[m]]*Product[m[[i]]!,{i,n}])*Product[x[[i]]^m[[i]],{i,n}]}]

DefLauricellaFC[n_Integer?Positive]:=Module[{c,x,m},c=Table[Symbol["\[FormalC]"<>ToString[i]],{i,n}];
x=Table[Symbol["\[FormalX]"<>ToString[i]],{i,n}];
m=Table[Symbol["\[FormalM]"<>ToString[i]],{i,n}];
{Join[{\[FormalA],\[FormalB]},c],x,Pochhammer[\[FormalA],Total[m]]*Pochhammer[\[FormalB],Total[m]]/Product[Pochhammer[c[[i]],m[[i]]]*m[[i]]!,{i,n}]*Product[x[[i]]^m[[i]],{i,n}]}]

DefLauricellaFD[n_Integer?Positive]:=Module[{b,x,m},b=Table[Symbol["\[FormalB]"<>ToString[i]],{i,n}];
x=Table[Symbol["\[FormalX]"<>ToString[i]],{i,n}];
m=Table[Symbol["\[FormalM]"<>ToString[i]],{i,n}];
{Join[{\[FormalA]},b,{\[FormalC]}],x,Pochhammer[\[FormalA],Total[m]]*Product[Pochhammer[b[[i]],m[[i]]],{i,n}]/(Pochhammer[\[FormalC],Total[m]]*Product[m[[i]]!,{i,n}])*Product[x[[i]]^m[[i]],{i,n}]}]


DefF1:=DefLauricellaFD[2] 
DefF2:=DefLauricellaFA[2] 
DefF3:=DefLauricellaFB[2]
DefF4:=DefLauricellaFC[2]


(* ::Section::Closed:: *)
(*HypExpand & HypFunctionExpand*)


(* ::Subsection:: *)
(*External Module*)


(* ::Subsubsection::Closed:: *)
(*HypExpand*)


Options[HypExpand0]={IDelta->-I,VerboseMode->False,ParallelRun->True};


HypExpand0[HypSeries_,ParSub_,SumVar_,VarsSub_,{Eps_,Ord_},NPrec_,opts : OptionsPattern[]]/;ParSub==={}:=
Module[{genser,infoser},

infoser = info[SumVar, HypSeries];
genser  = generalser[SumVar, infoser];

Return[HypExpand0[genser[[1]],genser[[2]],SumVar,VarsSub,{Eps,Ord},NPrec,opts]];
]


HypExpand0[HypSeries_,ParSub_,SumVar_,VarsSub_,{Eps_,Ord_},NPrec_,opts : OptionsPattern[]]/;ParSub=!={}:=
Module[{Vars,VerboseQ,\[CapitalDelta],ParallelQ,PrintVerbose,RunMaybeQuiet,Pfaffian,NumericalVal,TimeTaken,PfaffianDE},
TimeTaken=AbsoluteTiming[
VerboseQ=OptionValue[VerboseMode];
\[CapitalDelta]=OptionValue[IDelta];
ParallelQ=OptionValue[ParallelRun];
Vars=Keys[VarsSub];
PrintVerbose[args___]:=If[VerboseQ,Print[args]];
SetAttributes[RunMaybeQuiet, HoldAll];
RunMaybeQuiet[expr_] := Block[{Print}, expr];
PrintVerbose["Deriving Pfaffian Matrix"];

If[And@@((#===0)&/@(Im/@Values[ParSub])),
Pfaffian=RunMaybeQuiet[FindPfaffianSystem[HypSeries/.ParSub,SumVar,Vars]];(*for real parameters*)
,
Pfaffian=RunMaybeQuiet[FindPfaffianSystem[HypSeries,SumVar,Vars]/.ParSub];(*for complex parameters*)
];

PfaffianDE=Pfaffian[[3]];
PrintVerbose["The basis is \[Rule] ", Pfaffian[[4]]];
PrintVerbose["Pfaffian Matrix : ", Thread[Keys[PfaffianDE]->(MatrixForm[#]&/@Values[PfaffianDE])]];
Pfaffian=ReplacePart[Pfaffian,1->HypSeries];
PrintVerbose["Solving Pfaffian Numerically"];
NumericalVal=TransportDE[Pfaffian,ParSub,VarsSub,{Eps,Ord},NPrec,IDelta->\[CapitalDelta],VerboseMode->VerboseQ,ParallelRun->ParallelQ]
];
PrintVerbose["Time Taken ",TimeTaken[[1]]," seconds"];
Return[NumericalVal];
];


Options[HypExpand]={IDelta->-I,VerboseMode->False,ParallelRun->True};


HypExpand[HypSeries_, ParSubRaw_, VarsSubRaw_, {Eps_, Ord_}, NPrec_,
          opts : OptionsPattern[]] :=
  Module[{SumVar,ActualVar,VarSubKeys,VarsSub,infoser,NewVarsSubRaw,genser,newinfoser},
    SumVar = indices[HypSeries];
    VarSubKeys=Keys[VarsSubRaw];
    infoser = info[SumVar, HypSeries];
    newinfoser = ReplacePart[infoser,{2,-1}-> VarSubKeys];
    NewVarsSubRaw = Thread[VarSubKeys -> (infoser[[2,-1]]/.VarsSubRaw)];
    
    
    Return[HypExpand0[infotoseries[SumVar,newinfoser], Rationalize[ParSubRaw,10^-NPrec], SumVar, Rationalize[NewVarsSubRaw,10^-NPrec], {Eps, Ord}, NPrec, opts]];
  ]


(* ::Subsubsection::Closed:: *)
(*HypFunctionExpand*)


Options[HypFunctionExpand]={IDelta->-I,VerboseMode->False,ParallelRun->True};
SetAttributes[HypFunctionExpand, HoldFirst];


HypFunctionExpand[Hypergeometric2F1[a_,b_,c_,x_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0[Evaluate[{"PFPm1", 2}], {a,b,c}, {x}, {eps, Nterms}, Prec, opts]
  
HypFunctionExpand[HypergeometricPFQ[upper_List,lower_List, args_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  If[(Length@upper-Length@lower)===1,
  HypFunctionExpand0[Evaluate[{"PFPm1", Length[upper]}], Join[upper, lower], {args}, {eps, Nterms}, Prec, opts],
  Print["The package currently works for\!\(\*SubscriptBox[\(\\\ \), \(p\)]\)\!\(\*SubscriptBox[\(F\), \(p - 1\)]\) hypergeometric functions only"];Abort[]];
  
HypFunctionExpand[AppellF1[a_,b1_,b2_,c_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["F1", {a,b1,b2,c}, {x,y}, {eps, Nterms}, Prec, opts]
  
HypFunctionExpand[AppellF2[a_,b1_,b2_,c1_,c2_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["F2", {a,b1,b2,c1,c2}, {x,y}, {eps, Nterms}, Prec, opts]
  
HypFunctionExpand[AppellF3[a1_,a2_,b1_,b2_,c_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["F3", {a1,a2,b1,b2,c}, {x,y}, {eps, Nterms}, Prec, opts]
  
HypFunctionExpand[AppellF4[a_,b_,c1_,c2_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["F4", {a,b,c1,c2}, {x,y}, {eps, Nterms}, Prec, opts]
  

HypFunctionExpand[HornG1[a_,b_,c_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["G1", {a,b,c}, {x,y}, {eps, Nterms}, Prec, opts]

HypFunctionExpand[HornG2[a_,b_,c_,d_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["G2", {a,b,c,d}, {x,y}, {eps, Nterms}, Prec, opts]
  
HypFunctionExpand[HornG3[a_,b_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["G3", {a,b}, {x,y}, {eps, Nterms}, Prec, opts]


HypFunctionExpand[HornH1[a_,b_,c_,d_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["H1", {a,b,c,d}, {x,y}, {eps, Nterms}, Prec, opts]

HypFunctionExpand[HornH2[a_,b_,c_,d_,e_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["H2", {a,b,c,d,e}, {x,y}, {eps, Nterms}, Prec, opts]

HypFunctionExpand[HornH3[a_,b_,c_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["H3", {a,b,c}, {x,y}, {eps, Nterms}, Prec, opts]

HypFunctionExpand[HornH4[a_,b_,c_,d_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["H4", {a,b,c,d}, {x,y}, {eps, Nterms}, Prec, opts]

HypFunctionExpand[HornH5[a_,b_,c_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["H5", {a,b,c}, {x,y}, {eps, Nterms}, Prec, opts]

HypFunctionExpand[HornH6[a_,b_,c_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["H6", {a,b,c}, {x,y}, {eps, Nterms}, Prec, opts]

HypFunctionExpand[HornH7[a_,b_,c_,d_,x_,y_],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  HypFunctionExpand0["H7", {a,b,c,d}, {x,y}, {eps, Nterms}, Prec, opts]


(* \[HorizontalLine]\[HorizontalLine] Shared message template for Lauricella parameter-list errors \[HorizontalLine]\[HorizontalLine] *)
HypFunctionExpand::lauricellaparams =
  "Lauricella`1`: `2` list has wrong length for `3` variable(s). \
Expected `4`, got `5`.";

(* \[HorizontalLine]\[HorizontalLine] FA: upper = {a, b1,\[Ellipsis],bn}  (n+1),  lower = {c1,\[Ellipsis],cn}  (n) \[HorizontalLine]\[HorizontalLine] *)
HypFunctionExpand[LauricellaFA[upper_List, lower_List, args_List],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  Module[{n = Length[args]},
    Which[
      Length[upper] =!= n + 1,
        Message[HypFunctionExpand::lauricellaparams,
                "FA", "upper", n, n + 1, Length[upper]];
        $Failed,
      Length[lower] =!= n,
        Message[HypFunctionExpand::lauricellaparams,
                "FA", "lower", n, n, Length[lower]];
        $Failed,
      True,
        HypFunctionExpand0[{"FA", n},
          Join[upper, lower], args, {eps, Nterms}, Prec, opts]
    ]
  ]

(* \[HorizontalLine]\[HorizontalLine] FB: upper = {a1,\[Ellipsis],an, b1,\[Ellipsis],bn}  (2n),  lower = {c}  (1) \[HorizontalLine]\[HorizontalLine] *)
HypFunctionExpand[LauricellaFB[upper_List, lower_List, args_List],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  Module[{n = Length[args]},
    Which[
      Length[upper] =!= 2 n,
        Message[HypFunctionExpand::lauricellaparams,
                "FB", "upper", n, 2 n, Length[upper]];
        $Failed,
      Length[lower] =!= 1,
        Message[HypFunctionExpand::lauricellaparams,
                "FB", "lower", n, 1, Length[lower]];
        $Failed,
      True,
        HypFunctionExpand0[{"FB", n},
          Join[upper, lower], args, {eps, Nterms}, Prec, opts]
    ]
  ]

(* \[HorizontalLine]\[HorizontalLine] FC: upper = {a, b}  (2),  lower = {c1,\[Ellipsis],cn}  (n) \[HorizontalLine]\[HorizontalLine] *)
HypFunctionExpand[LauricellaFC[upper_List, lower_List, args_List],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  Module[{n = Length[args]},
    Which[
      Length[upper] =!= 2,
        Message[HypFunctionExpand::lauricellaparams,
                "FC", "upper", n, 2, Length[upper]];
        $Failed,
      Length[lower] =!= n,
        Message[HypFunctionExpand::lauricellaparams,
                "FC", "lower", n, n, Length[lower]];
        $Failed,
      True,
        HypFunctionExpand0[{"FC", n},
          Join[upper, lower], args, {eps, Nterms}, Prec, opts]
    ]
  ]

(* \[HorizontalLine]\[HorizontalLine] FD: upper = {a, b1,\[Ellipsis],bn}  (n+1),  lower = {c}  (1) \[HorizontalLine]\[HorizontalLine] *)
HypFunctionExpand[LauricellaFD[upper_List, lower_List, args_List],
    {eps_, Nterms_}, Prec_, opts : OptionsPattern[]] :=
  Module[{n = Length[args]},
    Which[
      Length[upper] =!= n + 1,
        Message[HypFunctionExpand::lauricellaparams,
                "FD", "upper", n, n + 1, Length[upper]];
        $Failed,
      Length[lower] =!= 1,
        Message[HypFunctionExpand::lauricellaparams,
                "FD", "lower", n, 1, Length[lower]];
        $Failed,
      True,
        HypFunctionExpand0[{"FD", n},
          Join[upper, lower], args, {eps, Nterms}, Prec, opts]
    ]
  ]


Options[HypFunctionExpand0]={IDelta->-I,VerboseMode->False,ParallelRun->True};


HypFunctionExpand0[FunName_, Paras_List, Arg_List, {eps_, Nterms_}, Prec_,
    opts : OptionsPattern[]] :=
  Module[{FunctionName, ParaValues, ArgValues, ExpectedParas, ExpectedArgs, def},

    def = Which[
      MatchQ[FunName, {"PFPm1", _Integer?Positive}],DefPFPm1[FunName[[2]]],
      ToString[FunName] === "F1",  DefF1,
      ToString[FunName] === "F2",  DefF2,
      ToString[FunName] === "F3",  DefF3,
      ToString[FunName] === "F4",  DefF4,
      ToString[FunName] === "G1",  DefG1,
      ToString[FunName] === "G2",  DefG2,
      ToString[FunName] === "G3",  DefG3,
      ToString[FunName] === "H1",  DefH1,
      ToString[FunName] === "H2",  DefH2,
      ToString[FunName] === "H3",  DefH3,
      ToString[FunName] === "H4",  DefH4,
      ToString[FunName] === "H5",  DefH5,
      ToString[FunName] === "H6",  DefH6,
      ToString[FunName] === "H7",  DefH7,
      MatchQ[FunName, {"FA", _Integer?Positive}], DefLauricellaFA[FunName[[2]]],
      MatchQ[FunName, {"FB", _Integer?Positive}], DefLauricellaFB[FunName[[2]]],
      MatchQ[FunName, {"FC", _Integer?Positive}], DefLauricellaFC[FunName[[2]]],
      MatchQ[FunName, {"FD", _Integer?Positive}], DefLauricellaFD[FunName[[2]]],
      True,
        Message[HypFunctionExpand0::unknownfun, FunName];
        Return[$Failed]
    ];

    ExpectedParas  = def[[1]];
    ExpectedArgs   = def[[2]];
    FunctionName   = def[[3]];
    
    If[Length[Paras] =!= Length[ExpectedParas],
      Message[HypFunctionExpand0::wrongparas, FunName,
              Length[ExpectedParas], Length[Paras]];
      Return[$Failed]];
      

    If[Length[Arg] =!= Length[ExpectedArgs],
      Message[HypFunctionExpand0::wrongargs, FunName,
              Length[ExpectedArgs], Length[Arg]];
      Return[$Failed]];

    ParaValues = Thread[ExpectedParas -> Paras];
    ArgValues  = Thread[ExpectedArgs  -> Arg];
    

    Return[HypExpand[FunctionName, ParaValues, ArgValues,
                     {eps, Nterms}, Prec, opts]];
  ]

HypFunctionExpand0::unknownfun =
  "Unknown function: `1`. \
Supported functions are: Hypergeometric2F1, HypergeometricPFQ; \
AppellF1, AppellF2, AppellF3, AppellF4; \
HornG1, HornG2, HornG3; \
HornH1, HornH2, HornH3, HornH4, HornH5, HornH6, HornH7; \
LauricellaFA, LauricellaFB, LauricellaFC, LauricellaFD. \
See ?HypFunctionExpand for usage details.";

HypFunctionExpand0::wrongparas =
  "Function `1` expects `2` parameters but `3` were given.";
HypFunctionExpand0::wrongargs =
  "Function `1` expects `2` variables but `3` were given.";


(* ::Section::Closed:: *)
(*End Package*)


End[];
EndPackage[];
Needs["DESolver`"];
