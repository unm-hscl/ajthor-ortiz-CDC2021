# Repeatability Code

This code is the repeatability package for the Kernel Module of
[SReachTools](https://sreachtools.github.io). Each Matlab script produces a
figure or table in the paper, "SReachTools Kernel Module: Data-Driven Stochastic
Reachability Using Hilbert Space Embeddings of Distributions".

## Figure 1

Figure 1 is a latex image file, generated using tikz, and as such is not
included in the repeatability evaluation.

## Figure 2

Figure 2 shows the computation time of the `KernelEmbeddings` algorithm as a
function of the sample size `M`. As more samples are used to compute the
approximation, the sample size increases exponentially. Use the `figure2.m`
script to generate the figure.

## Figure 3

Figure 2 shows the performance of the Kernel Module on a stochastic double
integrator system for the first-hitting time problem. Use the `figure3.m` script
to generate the figure.

## Figure 4

Figure 2 shows the performance of the Kernel Module on a stochastic double
integrator system for the first-hitting time problem. Use the `figure4.m` script
to generate the figure.

## Figure 5

Figure 2 shows the performance of the Kernel Module on a stochastic double
integrator system for the first-hitting time problem. Use the `figure5.m` script
to generate the figure.

## Table 1

Table 1 shows the computation time of the kernel-based algorithms compared with
the existing algorithms in [SReachTools](https://sreachtools.github.io). It
omits the algorithms, `ParticleOpen` and `VoronoiOpen`, since they use Gurobi
and require an active license. Use the `table1.m` script to generate the table.

## License

The code is released under an MIT license. For more information about licenses,
see [here](https://choosealicense.com/licenses/mit/). 
