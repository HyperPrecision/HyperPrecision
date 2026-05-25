(* ::Package:: *)

(* ::Subsection::Closed:: *)
(*begin*)


BeginPackage["DESolver`"];


eta::usage = "the auxiliary squared mass eta.";


SetGlobalOptions::usage = "SetGlobalOptions[opt] sets global options.";
SetExpansionOptions::usage = "SetExpansionOptions[opt] sets expansion options.";
SetRunningOptions::usage = "SetRunningOptions[opt] sets running options.";
SetDefaultOptions::usage = "SetDefaultOptions[] sets default options.";


MatrixDensity::usage = "MatrixDensity[matrix] gives the density of the matrix.";
MatrixDegree::usage = "MatrixDegree[matrix] gives the maximal degree of numerators and denominators.";
ListPlotComplex::usage = "ListPlotComplex[points] plots the list of points on the complex plane.";
FitEps::usage = "FitEps[rule,leading] fits the coefficients of a laurant expansion.";
EvaluateAsymptoticExpansion::usage = "EvaluateAsymptoticExpansion[mu -> exp, x0] evaluates the asymptotic expansion at x = x0.";


AnalyzeBlock::usage = "AnalyzeBlock[mat] gives the list of blocks of a matrix.";
AsymptoticBehavior::usage = "AsymptoticBehavior[matrix] obtains the maximal aysmptotic behaviors for each block near eta = 0 in case that the matrix has been normalized.";
NHEquations::usage = "NHEquations[mat,mode] gives the non-homogeneous form for mat.";
NHEquationsNum::usage = "NHEquationsNum[nheqs] gives the numerical form of a set of non-homogeneous equations.";
NormalizeMat::usage = "NormalizeMat[mat] gives the normalized matrix along with transformation matrix.";
GetPoles::usage = "GetPoles[mat] gets the list of poles of mat.";
RunSegment::usage = "RunSegment[polelist,ini,fin] gives a run list joining ini and fin.";
RunEta::usage = "RunEta[polelist] obtians a list of points for eta running based on the list of poles of differential equations.";
DetermineBoundaryOrder::usage = "DetermineBoundaryOrder[mat, power] determines the boundary order for each integrals in specified region.";
CalcInf::usage = "CalcInf[de,bcs] gives the expansion near x = 0, where x := 1/eta.";
CalcRun::usage = "CalcRun[de,bc,run] evaluates the integrals at the list of points and only the last one is returned.";
CalcZero::usage = "CalcZero[de,bc,x0] gives the expansion near eta = 0 from boundary at eta = x0.";
TimesAsyExp::usage = "TimesAsyExp[rational, asyexp] computes the production of a rational function and an asymptotic expansion.";
PlusAsyExp::usage = "PlusAsyExp[asyexplist] computes the sum of a list of asymptotic expansion.";


LoadSystem::usage = "LoadSystem[sysid,de,bc,point] defines the original system with the identifier sysid.";
ClearSystem::usage = "ClearSystem[sysid] clear all objects corresponding to sysid.";
DE::usage = "DE[sysid] -- differential equation in matrix form.";
BC::usage = "BC[sysid] -- boundary conditions either in singular form or in regular form.";
P::usage = "P[sysid] -- boundary point.";
AsyExp::usage = "AsyExp[sysid] -- asymptotic expansion near a singular point.";
InfToRegular::usage = "InfToRegular[sysid,x0] expands the integrals near the Infinity and evaluates the values regular point at eta = x0.";
RegularRun::usage = "RegularRun[sysid, run] evaluates the integrals at the list of points and only the last one is saved.";
RegularInterpolation::usage = "RegularInterpolation[sysid, samples] evaluates and returns the values of integrals at samples.";
SolveAsyExp::usage = "SolveAsyExp[sysid] solves the expansion near eta = 0.";


PickZeroRuleS::usage = "PickZeroRuleS[rules] picks leading order of analytic region in an asymptotic expansion.";
$InternalSystem::usage = "$InternalSystem is a symbol used in compositive calculation.";
AMFlow::usage = "AMFlow[de,bc] evaluates integrals via auxiliary mass flow method.";


Begin["`Private`"];


(* ::Subsection::Closed:: *)
(*options*)


Options[SetGlobalOptions] = {"WorkingPre" -> 100, "ChopPre" -> 20, "SilentMode" -> False, "RationalizePre" -> 100};
SetGlobalOptions[opt___]:=Block[{},
(*working precision*)
If[MemberQ[Keys[{opt}], "WorkingPre"], WorkingPre = "WorkingPre"/.{opt}];
(*chop precision*)
If[MemberQ[Keys[{opt}], "ChopPre"], ChopPre = "ChopPre"/.{opt}];
(*whether print or not*)
If[MemberQ[Keys[{opt}], "SilentMode"], SilentMode = "SilentMode"/.{opt}];
(*precision of rational numbers*)
If[MemberQ[Keys[{opt}], "RationalizePre"], RationalizePre = "RationalizePre"/.{opt}];

SetWorkingPrecision[WorkingPre];
PrintOptions[SetGlobalOptions];
];


Options[SetExpansionOptions] = {"XOrder" -> 100, "ExtraXOrder" -> 20, "LearnXOrder" -> -1, "TestXOrder" -> 5};
SetExpansionOptions[opt___]:=Block[{},
(*basic expansion order*)
If[MemberQ[Keys[{opt}], "XOrder"], XOrder = "XOrder"/.{opt}];
(*extra expansion order for boundary determination and CalcTaylor*)
If[MemberQ[Keys[{opt}], "ExtraXOrder"], ExtraXOrder = "ExtraXOrder"/.{opt}];
(*expansion order for learning phase*)
If[MemberQ[Keys[{opt}], "LearnXOrder"], LearnXOrder = "LearnXOrder"/.{opt}];
(*test expansion order after learning*)
If[MemberQ[Keys[{opt}], "TestXOrder"], TestXOrder = "TestXOrder"/.{opt}];

PrintOptions[SetExpansionOptions];
];


Options[SetRunningOptions] = {"RunRadius" -> 2, "RunLength" -> 1000, "RunCandidate" -> 10, "RunDirection" -> "NegIm"};
SetRunningOptions[opt___]:=Block[{},
(*the ratio of convergence radius and distance between estimating point*)
If[MemberQ[Keys[{opt}], "RunRadius"], RunRadius = "RunRadius"/.{opt}];
(*maximal number of steps in a running*)
If[MemberQ[Keys[{opt}], "RunLength"], RunLength = "RunLength"/.{opt}];
(*number of candidates during an automatic selection*)
If[MemberQ[Keys[{opt}], "RunCandidate"], RunCandidate = "RunCandidate"/.{opt}];
(*direction of amflow*)
If[MemberQ[Keys[{opt}], "RunDirection"], RunDirection = "RunDirection"/.{opt}];

PrintOptions[SetRunningOptions];
];


SetWorkingPrecision[p_]:=If[$MinPrecision < p, $MinPrecision = $MaxPrecision = p, $MaxPrecision = $MinPrecision = p];


AMFN[a_]:=N[a, WorkingPre];
AMFChop[a_]:=Chop[a, Power[10, -ChopPre]];
AMFPrint[a___]:=If[SilentMode=!=True, Print[a], Hold[a]];
AMFRationalize[a_]:=Rationalize[a, Power[10, -RationalizePre]];


$CTX = $Context;
PrintOptions[func_]:=AMFPrint[func -> Thread[Keys[Options[func]] -> ToExpression[$CTX<>#&/@Keys[Options[func]]]]];


SetDefaultOptions[]:=Block[{},
SetGlobalOptions@@Options[SetGlobalOptions];
SetExpansionOptions@@Options[SetExpansionOptions];
SetRunningOptions@@Options[SetRunningOptions];
];


$MaxExtraPrecision = Infinity;


(* ::Subsection::Closed:: *)
(*basic*)


(* ::Subsubsection::Closed:: *)
(*debug & helper*)


MatrixDensity[matrix_]:=Length[Select[Flatten[matrix],#=!=0&]]/Times@@Dimensions[matrix];


MatrixDegree[matrix_]:=Max[Exponent[#,eta]]&/@{Numerator[matrix], Denominator[matrix]};


Options[ListPlotComplex] = Options[ListPlot];
ListPlotComplex[points_,opt___:OptionsPattern[]]:=Quiet[ListPlot[Transpose@{Re@points,Im@points},opt]];


(*rule: {eps1\[Rule]a1, eps2\[Rule]a2}*)
FitEps[rule_,leading_]:=Block[{fit,eps},
fit = Fit[Transpose[{Keys[rule],Values[rule]}],Power[eps,leading+Range[0,Length@rule-1]],eps];
Coefficient[fit,eps,leading+Range[0,Length@rule-1]]
];


(*exp should have at least one row*)
EvaluateExpansion[exp_, x0_]:=Fold[Inner[Times, #2, #1, Plus]&, exp, {Prepend[Power[Log[x0], Range[Length[exp]-1]], 1], Power[x0, Range[0, Length[exp[[1]]]-1]]}];
Attributes[EvaluateAsymptoticExpansion] = {Listable};
EvaluateAsymptoticExpansion[mu_ -> exp_, x0_]:=Power[x0, AMFN[mu]]*EvaluateExpansion[exp, x0];


PickElement[list_,order_]:=If[order>Length@list-1,0,list[[order+1]]];
PickList[list_,order_]:=Map[PickElement[#,order]&,list,{1}];
PickMat[mat0_,order_]:=Map[PickElement[#,order]&,mat0,{2}];


(*f: truncated, poly: precise*)
(*the result has the same length with f*)
TimesPoly[f_,poly_]:=If[#<=Length@poly,f[[;;#]] . Reverse@poly[[;;#]],
f[[#-Length@poly+1;;#]] . Reverse@poly]&/@Range[Length@f];
(*poly: leading term not equal to 0*)
InversePoly[f_,poly_]:=Block[{$coe},
($coe[#]=(f[[#+1]]-If[#<=Length@poly-1,
$coe/@Range[0,#-1] . Reverse@poly[[2;;#+1]],
$coe/@Range[#-Length@poly+1,#-1] . Reverse@poly[[2;;]]])/poly[[1]])&/@Range[0,Length@f-1]
];
RationalExpansion[num_, de_, expansion_]:=InversePoly[TimesPoly[expansion, num], de];
InnerRationalExpansion[nums_, des_, expansions_]:=Total[MapThread[RationalExpansion, {nums, des, expansions}]];
MapRationalExpansion[nummap_, demap_, expansions_]:=InnerRationalExpansion[nummap[[#]], demap[[#]], expansions]&/@Range@Length@nummap;


ToStringInput[exp_]:=ToString[exp, InputForm];


(* ::Subsubsection::Closed:: *)
(*equation analysis*)


AnalyzeBlockOld[mat_]:=Block[{right,blocks},
right = FirstPosition[Reverse[#],Except[0],Heads -> False]&/@mat;
right = If[#==={},0,Length[mat]+1-#[[1]]]&/@right;
right = FoldList[Max,0,right]//Rest;
blocks = MapThread[#1>=#2&,{Range[Length[mat]],right}];
blocks = Pick[Range[Length[mat]],blocks];
blocks = Range@@@Transpose[{Prepend[Most[blocks],0]+1,blocks}];
blocks
];


AnalyzeBlock[mat_] := AnalyzeBlock[mat, AnalyzeBlock1];
AnalyzeBlock[mat_, func_] := func[Map[Boole[# =!= 0]&, mat, {2}]];
AnalyzeBlock0[mat_]:=Block[{nonzeroposi,subint,extend,samesetQ,topblockQ,sortblocks,blocks},
nonzeroposi[list_]:=Select[Range[Length[list]], list[[#]]=!=0&];
Table[subint[i] = DeleteDuplicates[Join[nonzeroposi[mat[[i]]], {i}]], {i, Length[mat]}];

extend[bl_]:=Block[{dep,ext,full},
dep = DeleteDuplicates[Join@@(subint/@bl)];
ext = Select[dep, Intersection[subint[#], bl]=!={}&];
full = DeleteDuplicates[Join[bl, ext]];
If[full===bl, full, extend[full]]
];
samesetQ[s1_, s2_]:=SubsetQ[s1, s2] && SubsetQ[s2, s1] && Length[s1] === Length[s2];
topblockQ[blocks_, block_] := ! Or@@(SubsetQ[#, block] && !samesetQ[#, block]&/@blocks);
sortblocks[bls_]:=Block[{bls0,bls1},
bls0 = {};
bls1 = bls;
While[bls1=!={}, 
bls0 = Join[bls0, Select[bls1, samesetQ[Intersection[Join@@(subint/@#), Join@@bls1], #]&]];
bls1 = Complement[bls1, bls0]];
bls0
];

blocks = {#}&/@Range[Length[mat]];
blocks = extend/@blocks;
blocks = Gather[Select[blocks, topblockQ[blocks, #]&], samesetQ[#1, #2]&];
blocks = DeleteDuplicates/@(Join@@@blocks);
blocks = sortblocks[blocks];

If[!samesetQ[Flatten[blocks], Range[Length[mat]]], AMFPrint["AnalyzeBlock: bad blocks."]; Abort[]];
blocks
];
AnalyzeBlock1[mat_] := Block[{nonzeroposi, subint, samesetQ, extend, topblockQ, sortblocks, blocks},
nonzeroposi[list_] := Select[Range[Length[list]], list[[#]] =!= 0&];
subint[i_] := subint[i] = DeleteDuplicates[Join[nonzeroposi[mat[[i]]], {i}]];
samesetQ[s1_, s2_] := SubsetQ[s1, s2] && SubsetQ[s2, s1] && Length[s1] === Length[s2];
extend[bl_] := Block[{next = DeleteDuplicates[Join@@subint/@bl]}, If[samesetQ[next, bl], bl, extend[next]]];
topblockQ[blocks_, block_] := !Or@@(SubsetQ[#, block] && !samesetQ[#, block]&/@blocks);
sortblocks[bls_] := Block[{bls0 = {}, bls1 = bls}, While[(bls1 = Complement[bls1, bls0]) =!= {}, bls0 = Join[bls0, Select[bls1, topblockQ[bls1, #]&]]]; bls0];

blocks = extend[{#}]&/@Range[Length[mat]];
blocks = First/@Gather[blocks, samesetQ[#1, #2]&];
blocks = sortblocks[blocks];
blocks = Reverse[Table[Complement[Sequence@@blocks[[i;;]]], {i, Length[blocks]}]];
If[!samesetQ[Flatten[blocks], Range[Length[mat]]], AMFPrint["AnalyzeBlock: bad blocks."]; Abort[]];
blocks
];


SubBlockID[mat_]:=Block[{blocks,judge},
blocks = AnalyzeBlock[mat];
judge[i_,j_]:=If[AnyTrue[Flatten[mat[[blocks[[i]],blocks[[j]]]]],#=!=0&],j,Nothing[]];
Table[judge[i,j],{i,Length@blocks},{j,i-1}]
];


UnionBehavior[behs_]:={#[[1,1]],Max[#[[All,2]]]}&/@GatherBy[behs,First];
UnionBehavior2[behs_]:=If[Length[#]===1,#[[1]],{#[[1,1]],Total[#[[All,2]]]+1}]&/@GatherBy[behs,First];


AsymptoticBehavior[mat_]:=Block[{blocks,sub,jor,essbeh,subbeh,beh},
blocks = AnalyzeBlock[mat];
sub = SubBlockID[mat];
Table[
(*we demand in each block, the leading term near eta = 0 is in jordan standard form*)
jor = mat[[blocks[[i]],blocks[[i]]]]eta/.eta -> 0;
essbeh = UnionBehavior[{jor[[#,#]][[1,1]],Length[#]-1}&/@AnalyzeBlockOld[jor]];
subbeh = UnionBehavior[Join@@beh/@sub[[i]]];
beh[i] = UnionBehavior2[Join[essbeh,subbeh]]
,{i,Length[blocks]}];

beh/@Range[Length[blocks]]
];


PoincareRank[mat_]:=Max@Exponent[mat//Denominator,eta,Min]-1;


(*x d[x] D[f[x],x] == A[x] f[x] + B[x] g[x] at singular points*)
(* d[x] D[f[x],x] == A[x] f[x] + B[x] g[x] at regular points and Taylor-like singular points*)
NHEquations[mat_,mode_]:=Block[{blocks,sub,factor,dxlist,axlist,bxlist},
blocks = AnalyzeBlock[mat];
sub = SubBlockID[mat];
sub = Join@@blocks[[#]]&/@sub;

Which[
mode === "Singular", factor = eta,
mode === "Regular", factor = 1,
mode === "Taylor", factor = Power[eta, PoincareRank[mat]+1],
True, AMFPrint["error: undefined mode for NHEquations."];Abort[]];

dxlist = PolynomialLCM@@Denominator[Flatten[factor*mat[[#,#]]]]&/@blocks;
axlist = Table[Together[factor*dxlist[[i]]*mat[[blocks[[i]],blocks[[i]]]]],{i,Length@blocks}];
bxlist = Table[Together[factor*dxlist[[i]]*mat[[blocks[[i]],sub[[i]]]]],{i,Length@blocks}];

If[mode =!= "Singular", dxlist = dxlist*factor];
Transpose@{dxlist,axlist,bxlist,blocks,sub}
];


Attributes[ToNum] = {Listable};
ToNum[poly_]:=AMFN[CoefficientList[poly,eta]];


NHEquationsNum[nheqs_]:=Block[{dx,ax,bx,block,sub,dxexp,axexp,bxexpn,bxexpd},
Table[
{dx,ax,bx,block,sub}=nheqs[[k]];
dxexp = ToNum[dx];
axexp = ToNum[ax];
bxexpn = ToNum[Numerator@bx];
bxexpd = ToNum[Denominator@bx];
{dxexp,axexp,bxexpn,bxexpd,block,sub}
,{k,Length@nheqs}]
];


(* ::Subsubsection::Closed:: *)
(*diagonal blocks normalization*)


(*balance between 0 and \[Infinity]*)
PBar[P_]:=IdentityMatrix[Length@P]-P;
Balance[P_]:=Together[PBar[P]+P/eta];
InvBalance[P_]:=Together[PBar[P]+P*eta];


ReduceL0[L0_,r_,lblock_]:=Block[{S,Delta,n,L0tmp,independentQ,L0t,Deltaij,comS,null,Delta0,Delta0t},
S = {};
Delta = ConstantArray[0,Dimensions[L0]];
n = 1;
L0tmp = L0;
independentQ[k_]:=MatrixRank[L0t[[All,1;;k-1]]]===MatrixRank[L0t[[All,1;;k]]];
Deltaij[i_,j_]:=Array[KroneckerDelta[#1,i]KroneckerDelta[#2,j]&,Dimensions[L0]];

While[n>r,
comS = Complement[Range@Length@L0,S];
L0t = L0tmp[[comS]];
n = Select[comS,independentQ][[1]];
null = NullSpace[L0t[[All,1;;n]]];
If[Length@null=!=1,AMFPrint["error: L0's null space is not one-dimensional."];Abort[]];
null = null[[1]]/-null[[1,-1]];
Delta0 = -Sum[null[[j]]Deltaij[j,n],{j,n-1}];
Delta0t = -Sum[null[[j]]KroneckerDelta[lblock[[j]],lblock[[n]]]Deltaij[j,n],{j,n-1}];
L0tmp = (IdentityMatrix@Length@L0-Delta0t) . L0tmp . (IdentityMatrix@Length@L0+Delta0);
Delta = Delta+Delta0+Delta . Delta0;
AppendTo[S,n];
];
{n,Complement[S,{n}],Delta}
];


DynamicPartition[l_,p_]:=MapThread[l[[#;;#2]]&,{{0}~Join~Most@#+1,#}&@Accumulate@p];


FindProjector[cp_,cp1_]:=Block[{s,jor,invs,blocks,right,left,L0,L1,r,k0,S,Delta,map,Eij,Et,U,invU,Q},
{s,jor} = JordanDecomposition[cp];
If[AnyTrue[Diagonal[jor],#=!=0&],AMFPrint["error: irreducible poincare rank."];Abort[]];
invs = Inverse[s];
blocks = Sort[AnalyzeBlockOld[jor],Length@#1>Length@#2&];
right = Part[Transpose@s,#]&/@blocks;
left = Part[invs,#]&/@(Reverse/@blocks);
L0 = Table[left[[i,1]] . cp1 . right[[j,1]],{i,Length@blocks},{j,Length@blocks}];
L1 = Table[left[[i,1]] . right[[j,1]],{i,Length@blocks},{j,Length@blocks}];
r = Count[Diagonal[L1],0];
{k0,S,Delta} = ReduceL0[L0,r,Length/@blocks];

map = Join@@Table[{i,j},{i,Length@blocks},{j,Length@blocks[[i]]}];
Eij[l_,k_]:=Table[If[map[[m]][[1]]==l&&map[[n]][[1]]==k&&map[[m]][[2]]==map[[n]][[2]],1,0],{m,Length@jor},{n,Length@jor}];
Et = Sum[Delta[[i,j]]Eij[i,j],{i,Length@blocks},{j,i+1,Length@blocks}];

U = Transpose[Join@@right] . (IdentityMatrix@Length@jor+Et);
invU = Inverse[IdentityMatrix@Length@jor+Et] . (Join@@Reverse/@left);

right = DynamicPartition[Transpose@U,Length/@blocks];
left = Reverse/@DynamicPartition[invU,Length/@blocks];
S = Join[S,{k0}];
Q = Sum[KroneckerProduct[right[[k,1]],left[[k,-1]]],{k,S}];
Q
];


ToFuchsian[mat_]:=Block[{T,invT,B,p,A0,A1,Q},
T = invT = IdentityMatrix[Length@mat];
B = mat;
While[(p = PoincareRank[B])>0,
A0 = Together[B*eta^(p+1)]/.eta -> 0;
A1 = Together[D[B,eta]eta^(p+1)+(p+1)*eta^p*B]/.eta -> 0;
Q = FindProjector[A0,A1];
T = Together[T . Balance[Q]];
invT = Together[InvBalance[Q] . invT];
B = Together[InvBalance[Q] . Together[B . Balance[Q]+Power[eta,-2]Q]];
];
{T,invT,B}
];


(*standard, feps-standard*)
(*2021/04/24: Re[] is added, in case that eps is a complex number*)
NormalEigen[feps_]:={feps-Floor[Re[feps]],Floor[Re[feps]]};


(*matrix is in fuchsian form at x=0, return True if matrix needs to be normalized*)
NormalizeEigenQ[mat_]:=AnyTrue[NormalEigen/@Eigenvalues[Together[mat*eta]/.eta -> 0],#[[2]]=!=0&];


(*matrix needs to be normalized*)
ShearingTransformation[mat_]:=Block[{u,b,invu,eigen,neigen,ele,T,invT,B},
{u,b} = JordanDecomposition[Together[mat*eta]/.eta -> 0];
invu = Inverse[u];
eigen = Diagonal[b];
neigen = NormalEigen/@eigen;
ele = If[Max@neigen[[All,2]]>0,If[#>0,eta,1]&/@neigen[[All,2]],If[#<0,1/eta,1]&/@neigen[[All,2]]];
T = Transpose[ele*Transpose[u]];
invT = invu/ele;
B = Together[invT . Together[mat . T] - DiagonalMatrix[D[ele,eta]/ele]];
{T,invT,B}
];


NormalizeEigen[mat_]:=Block[{T,invT,B,T0,invT0},
T = invT = IdentityMatrix@Length@mat;
B = mat;
While[NormalizeEigenQ[B],
{T0,invT0,B} = ShearingTransformation[B];
T = Together[T . T0];
invT = Together[invT0 . invT];
];
{T,invT,B}
];


NormalizeDiagonal[mat_]:=Block[{blocks,T,invT,B,normal,u,jor,invu,rows,cols},
blocks = AnalyzeBlock[mat];
T = invT = B = ConstantArray[0,Dimensions@mat];

Table[
{T[[ints,ints]], invT[[ints,ints]], B[[ints,ints]]} = ToFuchsian[mat[[ints,ints]]];
normal = NormalizeEigen[B[[ints,ints]]];
T[[ints,ints]] = Together[T[[ints,ints]] . normal[[1]]];
invT[[ints,ints]] = Together[normal[[2]] . invT[[ints,ints]]];
B[[ints,ints]] = normal[[3]];
(*turn B0 to jordan standard form*)
{u,jor} = JordanDecomposition[Together[B[[ints,ints]]*eta]/.eta -> 0];
invu = Inverse[u];
T[[ints,ints]] = Together[T[[ints,ints]] . u];
invT[[ints,ints]] = Together[invu . invT[[ints,ints]]];
B[[ints,ints]] = Together[invu . Together[B[[ints,ints]] . u]], {ints, blocks}];

Table[
rows = blocks[[i]];
cols = blocks[[j]];
B[[rows,cols]] = Together[invT[[rows,rows]] . Together[mat[[rows,cols]] . T[[cols,cols]]]];
,{i,Length[blocks]},{j,i-1}];

{T,invT,B}
];


(* ::Subsubsection::Closed:: *)
(*off-diagonal blocks normalization*)


(*{{a0/x,0},{b0/x^(p+1),c0/x}} tofuchsian*)
SolveOffDiagonal[a0_,b0_,c0_,p_]:= Block[{matrix,g,var,eqs,sol},
matrix = Array[g,Dimensions[b0]];
var = Join@@matrix;
eqs = Thread[Flatten[b0+c0 . matrix-matrix . a0+p*matrix]==0];
sol = Solve[eqs,var];
matrix/.Flatten[sol]
];


(*diagonal block have been normalized, off-diagonal blocks are to be normalized*)
ToFuchsianGlobal[mat_]:=Block[{blocks,T,invT,B,diag,transTB,p,rows,cols,a0,b0,c0,G},
blocks = AnalyzeBlock[mat];
T = invT = IdentityMatrix[Length@mat];
B = mat;
diag = (Together[B[[#,#]]*eta]/.eta -> 0)&/@blocks;

transTB[m_,n_,g_]:=Block[{},
Table[B[[blocks[[m]],blocks[[j]]]] = Together[B[[blocks[[m]],blocks[[j]]]]-g . B[[blocks[[n]],blocks[[j]]]]/eta^p],{j,1,n}];
Table[B[[blocks[[i]],blocks[[n]]]] = Together[B[[blocks[[i]],blocks[[n]]]]+B[[blocks[[i]],blocks[[m]]]] . g/eta^p],{i,m,Length[blocks]}];
B[[blocks[[m]],blocks[[n]]]] = Together[B[[blocks[[m]],blocks[[n]]]]+p*g/eta^(p+1)];
Table[T[[blocks[[i]],blocks[[n]]]] = Together[T[[blocks[[i]],blocks[[n]]]]+T[[blocks[[i]],blocks[[m]]]] . g/eta^p],{i,m,Length[blocks]}];
Table[invT[[blocks[[m]],blocks[[j]]]] = Together[invT[[blocks[[m]],blocks[[j]]]]-g . invT[[blocks[[n]],blocks[[j]]]]/eta^p],{j,1,n}];
];

Table[
rows = blocks[[i]];
cols = blocks[[j]];
While[(p = PoincareRank[B[[rows,cols]]])>0,
a0 = diag[[j]];
b0 = Together[B[[rows,cols]]*eta^(p+1)]/.eta -> 0;
c0 = diag[[i]];
G = SolveOffDiagonal[a0,b0,c0,p];
transTB[i,j,G];
],{i,Length@blocks},{j,Reverse@Range[i-1]}];

{T,invT,B}
];


(* ::Subsubsection::Closed:: *)
(*normalized fuchsian form*)


NormalizeMat[mat_]:=Block[{times,timef,T,invT,B,T2,invT2,blocks,rows,cols},
times = AbsoluteTime[];
{T,invT,B} = NormalizeDiagonal[mat];
{T2,invT2,B} = ToFuchsianGlobal[B];

(*T.T2 and invT2.invT*)
(*T and invT: only have diagonal blocks*)
blocks = AnalyzeBlock[mat];
Table[
rows = blocks[[i]];
cols = blocks[[j]];
T2[[rows,cols]] = Together[T[[rows,rows]] . T2[[rows,cols]]];
invT2[[rows,cols]] = Together[invT2[[rows,cols]] . invT[[cols,cols]]];
,{i,Length@blocks},{j,i}];
timef = AbsoluteTime[];
AMFPrint["NormalizeMat finished in "<>ToStringInput[IntegerPart[timef-times]]<>"s."];

{T2,invT2,B}
];


(* ::Subsubsection::Closed:: *)
(*integration contour*)


AllFactors[exp_List]:=FactorList[Times@@(exp//Denominator//Flatten)][[2;;,1]];
Zeros[poly_]:=If[#=!={}, eta/.#, {}]&/@NSolve[poly==0, eta, WorkingPrecision -> WorkingPre];
GetPoles[mat_]:=AMFRationalize[Join@@(Zeros/@AllFactors[mat])];


(*real*)
FirstStep[polelist_]:=If[Length[polelist]===1 && polelist[[1]]===0, 1, AMFRationalize[RunRadius*Max[polelist//Abs]]];


(*real*)
LastStep[polelist_]:=If[Length[polelist]===1 && polelist[[1]]===0, 1, AMFRationalize[Min[Select[polelist, #=!=0&]//Abs]/RunRadius]];


(*from 0 to 1, regular on the whole interval*)
RunUnit[polelist_]:=Block[{bad, min, current, run},
bad = Select[polelist, Im[#]===0 && 0 <= Re[#] <= 1&];
If[bad=!={}, Return[{}]];

min[point_]:=Min[Abs[AMFN[point-polelist]]];
current = 0;
run = {current};
While[current < 1,
current = Min[AMFRationalize[current+min[current]/RunRadius], 1];
AppendTo[run, current];
If[Length[run] > RunLength, Return[{}]]];

run
];


(*ini and fin: rational number*)
(*ini should not be equal to fin*)
(*regular on the whole interval*)
RunSegment[polelist_, ini_, fin_]:=RunUnit[(polelist-ini)/(fin-ini)]*(fin-ini)+ini;


RunEtaDirection[polelist_, 1]:=Block[{ini, fin},
ini = FirstStep[polelist];
fin = LastStep[polelist];
If[ini===fin, {ini}, RunSegment[polelist, ini, fin]]
];
RunEtaDirection[polelist_, direction_]:=Block[{dir, run},
dir = direction/Abs[direction];
run = RunEtaDirection[polelist/dir, 1];
AMFRationalize[dir*run]
];
RunEtaDirection[polelist_, mode_String]:=Block[{runlist},
Which[
mode === "Re",
runlist = RunEtaDirection[polelist, 1+I*#/RunCandidate]&/@Join[Range[0, RunCandidate], -Range[0, RunCandidate]],
mode === "Im",
runlist = RunEtaDirection[polelist, I-#/RunCandidate]&/@Join[Range[0, RunCandidate], -Range[0, RunCandidate]],
mode === "NegRe",
runlist = RunEtaDirection[polelist, -1-I*#/RunCandidate]&/@Join[Range[0, RunCandidate], -Range[0, RunCandidate]],
mode === "NegIm",
runlist = RunEtaDirection[polelist, -I+#/RunCandidate]&/@Join[Range[0, RunCandidate], -Range[0, RunCandidate]],
True, AMFPrint["error: undefined mode for RunEtaDirection."]; Return[{}]];

runlist = Select[runlist, #=!={}&];
If[runlist==={}, AMFPrint["error: no contour can be defined."]; Return[{}]];
Sort[runlist, Length@#1 <= Length@#2&][[1]]
];


RunEta[polelist_]:=RunEtaDirection[polelist, RunDirection];


(* ::Subsubsection::Closed:: *)
(*sparse solve*)


Sparsify[matrix_]:=Block[{dim,sp},
dim = Dimensions[matrix,2];
sp[list_]:=If[list[[#]]=!=0,# -> list[[#]],Nothing[]]&/@Range[dim[[2]]];
{dim, sp/@matrix}
];


(*translate n columns*)
SparseTranslate[sp_,n_]:={sp[[1]],Thread/@Thread[n+Keys/@sp[[2]] -> Values/@sp[[2]]]};


(*dx: polynomial in eta*)
(*ax: polynomial matrix in eta*)
(*to solve dx D[f,x] - ax f = g*)
ConstructMatrix[dx_,ax_,totalorder_]:=Block[{expd,expa,dn,an,table,sp},
expd = Exponent[dx,eta];
expa = Exponent[ax,eta]//Max;
If[expa<0,expa = 0];

dn[n_]:=0;
an[n_]:=0;
Table[dn[n] = Coefficient[dx,eta,n]*IdentityMatrix[Length@ax],{n,0,expd}];
Table[an[n] = Coefficient[ax,eta,n],{n,0,expa}];

table = Table[(totalorder+1-j)dn[j-i]-an[j-i-1],{i,0,totalorder},{j,i,Min[totalorder+1, Max[i+expd,i+1+expa]]}];
table = Select[#,#=!=0&]&/@table;
table = ArrayFlatten[{#}]&/@table;
sp = Sparsify/@table;
sp = MapThread[SparseTranslate,{sp,Length@ax*Range[0,totalorder]}];
{{Length@ax, (totalorder+2)*Length@ax}, sp[[All,2]]}
];


SplitSystem[sys_, m_]:=Block[{all,dep,indep},
all = Range@Length@sys;
dep = Select[all,MemberQ[Keys@sys[[#]],m]&];
indep = Complement[all,dep];
{dep,indep}
];


PlusSparse[sp1_,sp2_]:=Select[If[Length@#===1,#[[1]],#[[1,1]] -> #[[1,2]]+#[[2,2]]]&/@GatherBy[Join[sp1,sp2],First],#[[2]]=!=0&];
ScalarSparse[s_,sp_]:=Thread[Keys@sp -> s*Values@sp];


ForwardSparseGaussian[sparse_,vset_]:=Block[{rset,system,depr,indepr,rows,r,leading},
(*forward*)
rset = {};
system = sparse;

Table[
{depr,indepr} = SplitSystem[system,n];
If[depr=!={},
rows = system[[depr]];
r = rows[[1]];
leading = n/.r;
r = ScalarSparse[1/leading,r];
rows = PlusSparse[ScalarSparse[-(n/.#),r],#]&/@rows[[2;;]];
system = Join[system[[indepr]], rows];
AppendTo[rset,r]],{n,vset}];
rset = Sort[#,#1[[1]]<#2[[1]]&]&/@rset;

{rset,system}
];


(*{dim,sparselist}: generated by ConstructMatrix*)
SparseGaussian[{dim_,sparselist_},nh_]:=Block[{systems,k,inivar,rset,var,relation,residue},
systems = sparselist;
k = 1;
Table[If[nh[[k]]=!=0,AppendTo[systems[[i,j]],dim[[2]]+1->nh[[k]]]];k++,{i,Length@systems},{j,dim[[1]]}];
inivar = Range[dim[[1]]];

rset = {};
Table[
If[i<Length[systems],
var = inivar+(i-1)*dim[[1]],
var = Join[inivar+(i-1)*dim[[1]],inivar+i*dim[[1]]]];
{relation,residue} = ForwardSparseGaussian[systems[[i]],var];
rset = Join[rset,relation];
If[i<Length@systems,systems[[i+1]] = Join[systems[[i+1]],residue]];
,{i,Length@systems}];

{rset,residue}
];


NSparse[sp_]:=Thread[Keys[sp] -> N@AMFChop[Values[sp]]];


(* ::Subsubsection::Closed:: *)
(*boundary conditions*)


BuildTaylor[mat_,ini_]:=Table[If[i=!=j, Power[eta, -ini[[i]]]mat[[i, j]]Power[eta, ini[[j]]]//Together, mat[[i, i]]-ini[[i]]/eta//Together], {i, Length[mat]}, {j, Length[mat]}];


(*mat: homogeneous part of a block*)
(*I \[Equal] Power[eta, power] J such that J is a Taylor expansion*)
DetermineBlockBoundaryOrder[mat_, power_]:=Block[{new, dx, ax, sp, nh, reduce, residue, unsolved, fid, fids, order, getorder},
new = BuildTaylor[mat, power];
dx = PolynomialLCM@@Denominator[Flatten[new]];
ax = Together[dx*new];
sp = ConstructMatrix[dx, ax, ExtraXOrder];
nh = ConstantArray[0, (ExtraXOrder+1)*Length[new]];
{reduce, residue} = SparseGaussian[sp,nh];

fid[n_]:={Range[Length[new]][[Mod[n-1, Length[new]]+1]], ExtraXOrder+1-Quotient[n-1, Length[new]]};
unsolved = Complement[Range[sp[[1, 2]]], Keys[reduce][[All, 1]]];
fids = fid/@unsolved;

order = Ceiling[ExtraXOrder/2];
While[order <= ExtraXOrder+1, If[!MemberQ[fids[[All,2]], order], Break[]]; order++];
If[order > ExtraXOrder+1, AMFPrint["error: cannot find a level of solved coefficients. please increase ExtraXOrder."]; Abort[]];

(*boundary order*)
fids = Select[fids, #[[2]]<order&];
(*this may cause some error, see xiao6@162.105.151.111: /data/home/xiao6/XL2021/Higgs+jet/N3LO/VVV1/family/f151/ps1/2/results/bc, e.g.*)
(*If[Length[fids]=!=Length[GatherBy[fids, First]], AMFPrint["error: some integrals have more than one unsolved coefficients."]; Abort[]];*)

getorder[___]:=-1;
Table[If[fids[[i,2]] > getorder[fids[[i,1]]], getorder[fids[[i,1]]] = fids[[i,2]]], {i, Length[fids]}];
getorder/@Range[Length[mat]]
];


(*mat: the whole matrix*)
DetermineBoundaryOrder[mat_, power_]:=Range[Length[mat]]/.Thread[Join@@AnalyzeBlock[mat] -> Join@@(DetermineBlockBoundaryOrder[mat[[#, #]], power[[#]]]&/@AnalyzeBlock[mat])];


ReverseBCS[bcs_]:=Thread[-Keys[bcs] -> Values[bcs]];
UnionBCS[bcs_]:=#[[1,1]] -> Total[#[[All,2]]]&/@GatherBy[bcs,First];


ReadBCS[bcs_, region_]:=Block[{bcregion, ini, f},
bcregion = Select[bcs, IntegerQ[#[[1]]-region]&];
ini = If[bcregion==={}, region, Min[Keys[bcregion]-region]+region];
{ini, Thread[Keys[bcregion]-ini -> Values[bcregion]]}
];


(* ::Subsubsection::Closed:: *)
(*expand*)


(*bc: a list of rules with each {0\[Rule].., 1\[Rule].., ..}*)
CalcTaylor[mat_, bc_]:=Block[{nheq, nheqn, totalorder, getboundary, f0, dxexp, axexp, bxexpn, bxexpd, block, subints, nh, sp, reduce, residue, fid, vid, unsolved, fids, cfid},
nheq = NHEquations[mat, "Taylor"];
nheqn = NHEquationsNum[nheq];
totalorder = XOrder+ExtraXOrder;
getboundary[___]:=Null;
Table[getboundary[i, bc[[i, j, 1]]] = bc[[i, j, 2]], {i, Length[bc]}, {j, Length[bc[[i]]]}];
Attributes[f0] = {Listable};
f0[intid_, order_]:=0;
f0[intid_, -1]:=-1;

Table[
{dxexp, axexp, bxexpn, bxexpd, block, subints} = nheqn[[k]];
AMFPrint["block" -> block];

(*construct and solve the linear system*)
nh = MapRationalExpansion[bxexpn, bxexpd, f0[#, Range[0, totalorder]]&/@subints];
Table[If[nh[[i]]===0, nh[[i]] = ConstantArray[0, totalorder+1]], {i, Length[nh]}];
nh = Join@@(PickList[nh, #]&/@Reverse[Range[0, totalorder]]);
sp = ConstructMatrix[nheq[[k,1]], nheq[[k,2]], totalorder];
{reduce, residue} = SparseGaussian[sp, nh];

(*check residues*)
residue = Select[residue, #=!={}&];
If[Length[residue] > 0, AMFPrint["homogeneous id up to" -> sp[[1,2]]]; AMFPrint["dropped eqs" -> NSparse/@residue]];

(*check boundary*)
fid[n_]:={block[[Mod[n-1, Length[block]]+1]], totalorder+1-Quotient[n-1, Length[block]]};
unsolved = Complement[Range[sp[[1, 2]]], Keys[reduce][[All, 1]]];
fids = Select[fid/@unsolved, #[[2]] <= XOrder&];
If[AnyTrue[getboundary@@@fids, #===Null&], AMFPrint["error: unsolved variables encountered" -> fids]; Abort[]];

(*insert boundary consitions and solve*)
Table[f0[id[[1]], id[[2]]] = getboundary@@id; 
AMFPrint["boundary condition inserted" -> {Sequence@@id, N@AMFChop[getboundary@@id]}], {id, fids}];
Table[cfid = fid[rel[[1,1]]]; f0[cfid[[1]], cfid[[2]]] = Total[-#[[2]]*f0@@fid[#[[1]]]&/@rel[[2;;]]];
If[getboundary@@cfid=!=Null, AMFPrint["boundary condition test" -> {Sequence@@cfid, N@AMFChop[f0@@cfid-getboundary@@cfid]}]], {rel, Reverse[reduce]}], {k, Length[nheq]}];

Table[{f0[i, Range[0, XOrder]]}, {i, Length[bc]}]
];


(*de and bcs: original*)
(*allrule generated by this function: expansion by x := 1/eta*)
CalcInf[de_, bcs_]:=Block[{deinf,bcinf,allrule,regions,ini,bc,mat,nheq,nheqn,rule},
deinf = Together[-Power[eta, -2]*(de/.eta -> 1/eta)];
bcinf = UnionBCS/@ReverseBCS/@bcs;
regions = NormalEigen[Keys[bcinf]][[1]]//Flatten//DeleteDuplicates;

allrule = ConstantArray[{}, Length[deinf]];
Table[
AMFPrint["CalcTaylor: current region" -> region];
{ini, bc} = Transpose[ReadBCS[#, region]&/@bcinf];
mat = BuildTaylor[deinf, ini];
rule = Thread[ini -> CalcTaylor[mat, bc]];
allrule = MapThread[Append, {allrule, rule}], {region, regions}];
allrule
];


(* ::Subsubsection::Closed:: *)
(*regular point*)


(*expand equations at eta = x0*)
ExpandNHEquationsNum[nheqn_, 0]:=nheqn;
ExpandNHEquationsNum[nheqn_, x0_]:=Block[{maxorder, table, polyx0, polymatx0},
maxorder = Max[Length/@nheqn[[All, 1]], Map[Length, nheqn[[All, 2;;4]], {4}]]-1;
table = Table[Binomial[i, j]*Power[x0, i-j], {i, 0, maxorder}, {j, 0, i}];
polyx0[poly_]:=table[[#+1;;Length[poly], #+1]] . poly[[#+1;;]]&/@Range[0, Min[Length[poly]-1, XOrder]];
polymatx0[polymat_]:=Map[polyx0, polymat, {2}];

{polyx0[#[[1]]], Sequence@@(polymatx0/@#[[2;;4]]), Sequence@@#[[5;;]]}&/@nheqn
];


(*bc at regular point x0*)
(*x0: floating number*)
Calcx1x2[nheqn_, bc_, x0_]:=Block[{nheqnx0, f0, dxexp, axexp, bxexpn, bxexpd, block, subints, maxd, maxa, mata, nh, vec},
nheqnx0 = ExpandNHEquationsNum[nheqn, x0];
Attributes[f0] = {Listable};
Table[f0[i, 0] = bc[[i]], {i, Length[bc]}];

Table[
{dxexp, axexp, bxexpn, bxexpd, block, subints} = nheqnx0[[k]];
maxd = Length@dxexp-1;
maxa = Max@Map[Length, axexp, {2}]-1;
If[maxa < 0, maxa = -1];
Table[mata[m] = PickMat[axexp, m], {m, 0, maxa}];

nh = MapRationalExpansion[bxexpn, bxexpd, f0[#, Range[0, XOrder]]&/@subints];
Table[If[nh[[i]]===0, nh[[i]] = ConstantArray[0, XOrder+1]], {i, Length[nh]}];
Table[
vec = Power[(n+1)dxexp[[1]], -1]*Total@{nh[[All,n+1]], 
Total@Table[mata[m] . f0[block, n-m], {m, 0, If[n > maxa, maxa, n]}], 
Total@Table[-(n-m+1)dxexp[[m+1]]f0[block, n-m+1], {m, If[n > maxd, maxd, n]}]};
Table[f0[block[[i]], n+1] = vec[[i]], {i, Length@block}], {n, 0, XOrder-1}], {k, Length[nheqnx0]}];

Table[f0[i, Range[0, XOrder]], {i, Length[bc]}]
];


(*bc: at run[[1]]*)
(*run: a list of floating numbers*)
CalcRun[de_, bc_, run_]:=Block[{nheqn, bcr, rule},
nheqn = NHEquationsNum@NHEquations[de, "Regular"];
bcr = bc;
Table[AMFPrint["current regular point" -> N[run[[i]]]];
rule = Calcx1x2[nheqn, bcr, run[[i]]];
bcr = rule . Power[run[[i+1]]-run[[i]], Range[0, XOrder]], {i, Length[run]-1}];
bcr
];


(* ::Subsubsection::Closed:: *)
(*zero*)


Calcx00[nheq_, nheqn_, bc_, x0_, behavior_]:=Block[{rec1, rec2, f0, dxexp, axexp, bxexpn, bxexpd, block, subints, beh, maxd, maxa, mata, a00, bb, kk, pair, finalmat, variables, essentialset, spbeh, logk, nh, posi, inv, finalvec, matchequ, pairtoequ, allvar, compensate, constraints, sol, vec, blocks, final},
(*first recurrence relation*)
rec1[func_, p_, n_]:=Power[(p+1)*dxexp[[1]], -1]Total@{Total@Table[mata[mm] . func[spbeh, p, n-mm], {mm, 0, If[n > maxa, maxa, n]}],
If[func===bb, nh[[p+1,All,n+1]], Nothing[]],
Total@Table[-(spbeh+n-mm)dxexp[[mm+1]]func[spbeh, p, n-mm], {mm, 0, If[n > maxd, maxd, n]}],
Total@Table[-(p+1)dxexp[[mm+1]]func[spbeh, p+1, n-mm], {mm, If[n > maxd, maxd, n]}]};
(*second recurrence relation*)
rec2[func_, p_, n_]:=inv . Total@{Total@Table[mata[mm] . func[spbeh, p, n-mm], {mm, If[n > maxa, maxa, n]}],
If[func===bb, nh[[p+1, All, n+1]], Nothing[]],
Total@Table[-(spbeh+n-mm)dxexp[[mm+1]]func[spbeh, p, n-mm], {mm, If[n > maxd, maxd, n]}],
Total@Table[-(p+1)dxexp[[mm+1]]func[spbeh, p+1, n-mm], {mm, 0, If[n > maxd, maxd, n]}]};

Attributes[f0] = {Listable};
f0[___]:=0;

Table[
{dxexp, axexp, bxexpn, bxexpd, block, subints} = nheqn[[k]];
AMFPrint["block" -> block];
AMFPrint["behavior" -> (beh = behavior[[k]])];
maxd = Length[dxexp]-1;
maxa = Max[Map[Length, axexp, {2}]-1];
If[maxa < 0, maxa = -1];
Table[mata[m] = PickMat[axexp, m], {m, 0, maxa}];
a00 = (nheq[[k, 2]]/.eta -> 0)/(nheq[[k, 1]]/.eta -> 0);

Clear[bb, kk, pair, finalmat, variables];
bb[___]:=ConstantArray[0,Length[block]];
kk[___]:=ConstantArray[0,{Length[block],Length[block]}];
essentialset = {};
Table[{spbeh, logk} = beh[[m]];
nh = Table[MapRationalExpansion[bxexpn, bxexpd, f0[#, spbeh, p, Range[0, XOrder]]&/@subints], {p, 0, logk}];
Table[If[nh[[i, j]]===0, nh[[i,j]] = ConstantArray[0, XOrder+1]], {i, Length@nh}, {j, Length@nh[[i]]}];
Table[posi = Flatten[Position[Together[(n+spbeh)-Diagonal[a00]], 0]];
Which[posi=!={}, AppendTo[essentialset, m];
kk[spbeh, 0, n] = IdentityMatrix[Length[block]]; 
bb[spbeh, 0, n] = ConstantArray[0, Length[block]];
Table[bb[spbeh,p+1,n] = rec1[bb, p, n]; kk[spbeh,p+1,n] = rec1[kk, p, n], {p, 0, logk}];
pair[m] = {kk[spbeh, logk+1, n], bb[spbeh, logk+1, n], Complement[Range[Length[block]], posi]}, 
True, inv = Power[dxexp[[1]], -1]Inverse[(n+spbeh)IdentityMatrix[Length[block]]-a00];
Table[bb[spbeh, p, n] = rec2[bb, p, n]; kk[spbeh, p, n] = rec2[kk, p, n], {p, Reverse[Range[0, logk]]}]], {n, 0, XOrder}], {m, Length[beh]}];

Table[finalmat[m] = EvaluateAsymptoticExpansion[beh[[m, 1]] -> Array[kk[beh[[m, 1]], #1, #2]&, {beh[[m, 2]]+1, XOrder+1}, {0, 0}], x0];
variables[m] = variables[m, #]&/@Range[Length[block]], {m, essentialset}];
finalvec = bc[[block]]-Total@EvaluateAsymptoticExpansion[Table[beh[[m, 1]] -> Array[bb[beh[[m, 1]], #1, #2]&, {beh[[m, 2]]+1, XOrder+1}, {0, 0}], {m, Length[beh]}], x0];
matchequ = Reverse@SortBy[Thread[Sum[finalmat[m] . variables[m], {m, essentialset}]-finalvec==0], LeafCount];
pairtoequ = Flatten@Table[Thread[(pair[m][[1]] . variables[m]+pair[m][[2]])[[pair[m][[3]]]]==0], {m, essentialset}];
allvar = Flatten[variables/@essentialset];
compensate = Length[allvar] - Length[pairtoequ];
constraints = Flatten[{matchequ[[1;;compensate]], pairtoequ}];
AMFPrint["number of constraints and variables" -> Length/@{constraints, allvar}];
sol = Flatten@Solve[constraints, allvar];
Table[variables[m] = If[MemberQ[essentialset, m], variables[m]/.sol, ConstantArray[0, Length[block]]], {m, Length[beh]}];
If[compensate < Length[matchequ], AMFPrint["dropped eqs" -> N[AMFChop[(Sum[finalmat[m] . variables[m], {m, essentialset}]-finalvec)[[compensate+1;;]]]]]];

Table[vec = kk[beh[[m, 1]], p, n] . variables[m]+bb[beh[[m, 1]], p, n];
Table[f0[block[[i]], beh[[m,1]], p, n] = vec[[i]], {i, Length[block]}], {m, Length[beh]}, {p, 0, beh[[m, 2]]}, {n, 0, XOrder}], {k, Length[nheq]}];

blocks = nheqn[[All, 5]];
final = Table[behavior[[i, m, 1]] -> Table[f0[blocks[[i, j]], behavior[[i, m, 1]], p, Range[0, XOrder]], {p, 0, behavior[[i, m, 2]]}], {i, Length[blocks]}, {j, Length[blocks[[i]]]}, {m, Length[behavior[[i]]]}];

Range[Length[bc]]/.Thread[Join@@blocks -> Join@@final]
];


FindLogPower[exp_]:=Block[{k = Length[exp]}, While[k >= 1, If[AllTrue[exp[[k]], #===0&], k--, Break[]]]; k-1];
LearnFromRuleS[rules_]:=Select[Transpose@{Keys[rules], FindLogPower/@AMFChop[Values[rules][[All, All, ;;Min[TestXOrder, LearnXOrder]+1]]]}, #[[2]] >= 0&];
LearnFromRuleSAll[ruleslist_, blocks_]:=UnionBehavior[Join@@LearnFromRuleS/@ruleslist[[#]]]&/@blocks;


(*exp: a two-dim matrix*)
(*row number: log power*)
(*column number: eta power*)
ExtendExpansion[exp_,n_]:=Join[exp, ConstantArray[0, {n-Length[exp], XOrder+1}]];
PlusExpansion[exps_]:=Total[ExtendExpansion[#, Max[Length/@exps]]&/@exps];
RescaleExpansion[exp_, order_]:=Join[ConstantArray[0, order], #[[;;XOrder+1-order]]]&/@exp;


(*rules0: single region involved*)
(*2021/04/24: Min[Keys[rules0]] \[Rule] Min[Keys[rules0]-Keys[rules0][[1]]]+Keys[rules0][[1]], in case that eps is a complex number*)
PlusRuleS[rules0_]:=Block[{min = Min[Keys[rules0]-Keys[rules0][[1]]]+Keys[rules0][[1]]}, min -> PlusExpansion[MapThread[RescaleExpansion, {Values[rules0], Keys[rules0]-min}]]];
UnionRuleS[rules_]:=PlusRuleS/@Gather[rules, IntegerQ[#1[[1]]-#2[[1]]]&];
PSTimesRuleS[0, rules_]:={};
PSTimesRuleS[ps_, rules_]:=Join@@Table[rules[[j, 1]]+ps[[2]]+i-1 -> rules[[j, 2]]*ps[[1, i]], {i, Length@ps[[1]]}, {j, Length@rules}];
PSMapRuleS[psmap_, ruleslist_]:=UnionRuleS/@(Join@@@Table[PSTimesRuleS[psmap[[i, j]], ruleslist[[j]]], {i, Length@psmap}, {j, Length@ruleslist}]);


Attributes[ToPS] = {Listable};
ToPS[0]:=0;
ToPS[poly_]:=Block[{exp, newpoly},
exp = Exponent[Numerator[poly], eta, Min]-Exponent[Denominator[poly], eta, Min];
newpoly = Together[poly*Power[eta, -exp]];
If[!PolynomialQ[newpoly, eta], AMFPrint["error: non-polynomial."]; Abort[]];
{CoefficientList[newpoly, eta], exp}
];


(*de and bc: original*)
(*x0: floating number*)
CalcZero[de_, bc_, x0_]:=Block[{T, invT, B, bcT, nheq, nheqn, behavior},
{T, invT, B} = NormalizeMat[de];
bcT = Dot[invT/.eta -> x0, bc];
nheq = NHEquations[B, "Singular"];
nheqn = NHEquationsNum[nheq];
behavior = AsymptoticBehavior[B];

(*learn*)
If[LearnXOrder < 0, AMFPrint["LearnXOrder is negative. skip learning phase."],
Block[{XOrder = LearnXOrder, SilentMode = True}, behavior = LearnFromRuleSAll[Calcx00[nheq, nheqn, bcT, x0, behavior], AnalyzeBlock[B]]]];

PSMapRuleS[ToPS[T], Calcx00[nheq, nheqn, bcT, x0, behavior]]
];


TimesAsyExp[rational_, asyexp_]:=Block[{num, de, exponent},
de = Denominator[Together[rational]];
exponent = Exponent[de, eta, Min];
de = ToNum[de/Power[eta, exponent]//Together];
num = ToNum[Numerator[Together[rational]]];
#[[1]]-exponent -> (RationalExpansion[num, de, #]&/@#[[2]])&/@asyexp
];


PlusAsyExp[asyexplist_]:=UnionRuleS[Join@@asyexplist];


(* ::Subsection::Closed:: *)
(*operations*)


(* ::Subsubsection::Closed:: *)
(*login & logout*)


LoadSystem[sysid_, de_, bc_, point_]:=Block[{},
DE[sysid] = de;
BC[sysid] = bc;
P[sysid] = point;
AsyExp[sysid] = Null;

AMFPrint@StringTemplate[
"system loaded: `sysid`
DE[`sysid`] -- differential equation in matrix form
BC[`sysid`] -- boundary conditions either in singular form or in regular form
P[`sysid`] -- boundary point
AsyExp[`sysid`] -- asymptotic expansion near a singular point (currently it is Null)
integrals: `ints`, blocks: `blocks`, density: `density`, degrees: `deg`"][<|
"sysid" -> ToStringInput[sysid],
"ints" -> ToStringInput[Length[DE[sysid]]],
"blocks" -> ToStringInput[Length[AnalyzeBlock@DE[sysid]]],
"density" -> ToStringInput[N[IntegerPart[100*MatrixDensity[DE[sysid]]]/100]],
"deg" -> ToStringInput[MatrixDegree[DE[sysid]]]|>];
];


ClearSystem[sysid_]:=Module[{},
DE[sysid] =.;
BC[sysid] =.;
P[sysid] =.;
AsyExp[sysid] =.;

AMFPrint["system cleared: "<>ToStringInput[sysid]];
];


(* ::Subsubsection::Closed:: *)
(*links*)


(*x0: rational number near the Infinity*)
InfToRegular[sysid_, x0_]:=Block[{},
If[P[sysid]=!=Infinity, AMFPrint["error: current boundary is not at the Infinity."]; Abort[]]; 
AsyExp[sysid] = CalcInf[DE[sysid], BC[sysid]];
BC[sysid] = Total/@EvaluateAsymptoticExpansion[AsyExp[sysid], AMFN[1/x0]];
P[sysid] = x0;
];


(*run: rational numbers*)
RegularRun[sysid_, run_]:=Block[{},
If[P[sysid]=!=run[[1]], AMFPrint["error: current boundary is not the same as the initial point in run list."]; Abort[]];
BC[sysid] = CalcRun[DE[sysid], BC[sysid], AMFN[run]];
P[sysid] = run[[-1]];
];


(*samples: a list of rational numbers*)
RegularInterpolation[sysid_, samples_]:=Block[{bcinfo,polelist,radius,findnum,vsets,residues,number,run,nheqn,rule},
bcinfo = {BC[sysid], P[sysid]};
polelist = GetPoles[DE[sysid]];
radius:=Min[Abs[P[sysid]-polelist]]/RunRadius;
findnum[sam_]:=Block[{k = 1},
While[k <= Length[sam], If[Abs[P[sysid]-sam[[k]]] > radius, Break[]]; k++]; 
k-1];

If[Length@samples>0 && samples[[1]] === P[sysid], 
vsets = {BC[sysid]};
residues = samples[[2;;]], 
vsets = {};
residues = samples];

While[Length@residues > 0, number = findnum[residues];
Which[
number === 0, 
run = RunSegment[polelist, P[sysid], residues[[1]]];
RegularRun[sysid, run];
vsets = Append[vsets, BC[sysid]];
residues = residues[[2;;]],

True,
AMFPrint["current regular point" -> N[P[sysid]]];
nheqn = NHEquationsNum@NHEquations[DE[sysid], "Regular"];
rule = Calcx1x2[nheqn, BC[sysid], P[sysid]];
vsets = Join[vsets, rule . Power[#-P[sysid], Range[0, XOrder]]&/@residues[[;;number]]];
BC[sysid] = vsets[[-1]];
P[sysid] = residues[[number]];
residues = residues[[number+1;;]]]];

{BC[sysid], P[sysid]} = bcinfo;
vsets
];


SolveAsyExp[sysid_]:=Block[{},
AsyExp[sysid] = CalcZero[DE[sysid], BC[sysid], AMFN[P[sysid]]];
];


(* ::Subsection::Closed:: *)
(*applications*)


(* ::Subsubsection::Closed:: *)
(*AMFlow*)


PickZeroRuleS[rules_]:=Block[{key},
key = Select[Keys[rules], IntegerQ];
If[Length[key]===0, Return[0]];
If[Length[key] > 1, AMFPrint["error: not combined regions encountered."]; Abort[]];
key = key[[1]];
If[key > 0, Return[0]];
If[key===0, Return[(key/.rules)[[1,1]]]];
AMFPrint["dropped terms when pickzero" -> N@AMFChop[(key/.rules)[[1, ;;-key]]]];
(key/.rules)[[1, -key+1]]
];


AMFlow[de_,bc_]:=Block[{run, times, time1, time2, timef, sol},
AMFPrint["AMFlow: start."];
times = AbsoluteTime[];
LoadSystem[$InternalSystem, de, bc, Infinity];

time1 = AbsoluteTime[];
run = RunEta[GetPoles[DE[$InternalSystem]]];
If[run==={}, AMFPrint["AMFlow: error. integration contour not generated."]; Abort[]];
time2 = AbsoluteTime[];
AMFPrint["AMFlow: integrals will be evaluated at "<>ToStringInput[Length[run]]<>" regular points" -> N[run]];
AMFPrint["AMFlow: integration contour generated in "<>ToStringInput[IntegerPart[time2-time1]]<>"s."];

AMFPrint["AMFlow: solving near eta = Infinity..."];
time1 = AbsoluteTime[];
InfToRegular[$InternalSystem, run[[1]]];
time2 = AbsoluteTime[];
AMFPrint["AMFlow: Infinity solved in "<>ToStringInput[IntegerPart[time2-time1]]<>"s."];

AMFPrint["AMFlow: running among regular points..."];
time1 = AbsoluteTime[];
RegularRun[$InternalSystem, run];
time2 = AbsoluteTime[];
AMFPrint["AMFlow: regular running finished in "<>ToStringInput[IntegerPart[time2-time1]]<>"s."];

AMFPrint["AMFlow: solving near the last point..."];
time1 = AbsoluteTime[];
SolveAsyExp[$InternalSystem];
time2 = AbsoluteTime[];
AMFPrint["AMFlow: last point solved in "<>ToStringInput[IntegerPart[time2-time1]]<>"s."];

sol = PickZeroRuleS/@AsyExp[$InternalSystem];
ClearSystem[$InternalSystem];
timef = AbsoluteTime[];
AMFPrint["AMFlow: finished in "<>ToStringInput[IntegerPart[timef-times]]<>"s."];

sol
];


(* ::Subsection::Closed:: *)
(*end*)


End[];


EndPackage[];
