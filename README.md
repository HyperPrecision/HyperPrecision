# HyperPrecision

`HyperPrecision` is a Mathematica package for the high-precision numerical evaluation of Horn-type hypergeometric functions, including their Laurent expansions in a small parameter.

The package automatically derives the Pfaffian system of partial differential equations satisfied by a given hypergeometric function using [FiniteFlow](https://github.com/peraro/finiteflow). The resulting system is then restricted to a one-dimensional path and solved numerically at a user-specified target point using the Frobenius method. When the input depends on \(\epsilon\), the package evaluates the system at several rational values of \(\epsilon\) and reconstructs the Laurent expansion by interpolation, yielding the expansion coefficients to the desired order and precision.

More details can be found in [arXiv:2605.XXXXX](https://arxiv.org/abs/2605.XXXXX).

## Dependencies

`HyperPrecision.wl` requires the following external tools:

- [FiniteFlow](https://github.com/peraro/finiteflow), used for the automatic derivation of Pfaffian systems  
  T. Peraro, [arXiv:1905.08019](https://arxiv.org/abs/1905.08019)

- [DESolver](https://gitlab.com/multiloop-pku/amflow/-/tree/master/diffeq_solver), a differential-equation solver distributed with AMFlow  
  X. Liu and Y.-Q. Ma, [arXiv:2201.11669](https://arxiv.org/abs/2201.11669)

A slightly modified version of `DESolver.m` is included in this repository.

## Installation

1. Install [FiniteFlow](https://github.com/peraro/finiteflow) following the instructions in its repository.

2. Clone this repository:

```bash
git clone https://github.com/HyperPrecision/HyperPrecision.git

```
   git clone https://github.com/HyperPrecision/HyperPrecision.git
```

3. Place `HyperPrecision.wl` and `DESolver.m` in a directory on your Mathematica `$Path`, or in the same directory as your notebook.

4. Load the package in Mathematica:
```mathematica
   << HyperPrecision`
```

## Files

| File | Description |
|------|-------------|
| `HyperPrecision.wl` | Main package file |
| `DESolver.m` | Slightly modified version of the differential equation solver shipped with [AMFlow](https://gitlab.com/multiloop-pku/amflow) |
| `Examples.nb` | Example evaluations |

## Authors

- Sumit Banik (SLAC National Accelerator Laboratory, Stanford University) — [banik@stanford.edu](mailto:banik@stanford.edu)
- Souvik Bera (Asia Pacific Center for Theoretical Physics) — [souvik.bera@apctp.org](mailto:souvik.bera@apctp.org)
