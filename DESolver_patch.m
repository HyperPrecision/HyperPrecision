(* ::Package:: *)

(* ::Title:: *)
(*DESolver_patch*)


(* ::Subtitle:: *)
(*HyperPrecision-specific overrides for DESolver.m by Xiao Liu and Yan-Qing Ma.*)


(* ::Section::Closed:: *)
(*Package Content*)


BeginPackage["DESolver`"];


Begin["`Private`"];


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

(* HyperPrecision modification: Throw instead of Abort so the caller can react *)
If[AnyTrue[getboundary@@@fids, #===Null&], AMFPrint["error: unsolved variables encountered" -> fids]; Throw[fids, "RequiredFids"]];

(*insert boundary consitions and solve*)
Table[f0[id[[1]], id[[2]]] = getboundary@@id;
AMFPrint["boundary condition inserted" -> {Sequence@@id, N@AMFChop[getboundary@@id]}], {id, fids}];
Table[cfid = fid[rel[[1,1]]]; f0[cfid[[1]], cfid[[2]]] = Total[-#[[2]]*f0@@fid[#[[1]]]&/@rel[[2;;]]];
If[getboundary@@cfid=!=Null, AMFPrint["boundary condition test" -> {Sequence@@cfid, N@AMFChop[f0@@cfid-getboundary@@cfid]}]], {rel, Reverse[reduce]}], {k, Length[nheq]}];

Table[{f0[i, Range[0, XOrder]]}, {i, Length[bc]}]
];


End[];


EndPackage[];
