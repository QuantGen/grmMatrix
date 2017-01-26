grmMatrix
=========


Example
-------

This example uses dummy GRM files bundled with this package. It was generated from the dummy BED files in the [BEDMatrix package](https://cran.r-project.org/package=BEDMatrix) using `gcta64 --bfile example --make-grm --out example` with GCTA 1.26.0.

To get the prefix to the dummy GRM files (`system.file` finds the full file names of files in packages and is only used to find the example data):

```r
> prefix <- paste0(system.file("extdata", package = "grmMatrix"), "/example")
```

To wrap the dummy GRM files in a grmMatrix object:

```r
> m <- grmMatrix$new(prefix = prefix)
```

To get the dimensions of the grmMatrix object:

```r
> dim(m)
[1] 50 50
```

To extract a subset of the BEDMatrix object:

```r
> m[1:3, 1:3]
           per0_per0    per1_per1    per2_per2
per0_per0 0.99297035  0.045664247  0.956165433
per1_per1 0.04566425  0.956165433 -0.003567911
per2_per2 0.95616543 -0.003567911  0.981300116
```

To extract the diagonal of the grmMatrix object:

```r
> diag(m)
  per0_per0   per1_per1   per2_per2   per3_per3   per4_per4   per5_per5
  0.9929703   0.9561654   0.9813001   1.0006099   0.9571444   1.0086495
  per6_per6   per7_per7   per8_per8   per9_per9 per10_per10 per11_per11
  0.9779904   0.9986514   0.9818304   1.0304354   0.9246207   0.9786042
per12_per12 per13_per13 per14_per14 per15_per15 per16_per16 per17_per17
  1.0067449   0.9791979   1.0073903   0.9919306   0.9969872   1.0002682
per18_per18 per19_per19 per20_per20 per21_per21 per22_per22 per23_per23
  1.0341240   1.0021822   0.9916793   0.9868485   1.0195130   1.0006720
per24_per24 per25_per25 per26_per26 per27_per27 per28_per28 per29_per29
  1.0005078   1.0038743   0.9981703   1.0563536   1.0256737   0.9853888
per30_per30 per31_per31 per32_per32 per33_per33 per34_per34 per35_per35
  0.9726509   1.0062875   1.0499943   1.0089763   1.0286126   0.9993057
per36_per36 per37_per37 per38_per38 per39_per39 per40_per40 per41_per41
  1.0158972   1.0061988   0.9454290   0.9622741   1.0020869   0.9885394
per42_per42 per43_per43 per44_per44 per45_per45 per46_per46 per47_per47
  1.0198814   0.9933779   1.0055650   1.0098705   0.9839650   1.0303550
per48_per48 per49_per49
  1.0059229   0.9897712
```


Installation
------------

To get the current development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("QuantGen/grmMatrix")
```
