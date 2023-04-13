# Creating Correlograms (work in progress)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7586736.svg)](https://doi.org/10.5281/zenodo.7586736)

Details and better documentation forthcoming...this matlab package creates correlograms for symmetric and asymmetric correlation matrices.

Here is an example where the upper triangle shows data for healthy controls and the lower triangle shows data for stroke patients. Note, matlab does not internally support scatterplots with trendlines/CIs, error bars around samples on a scatterplot, histogram 'patches' or differing upper/lower triangles in scatterplots and/or scatterplot matrices. correlogram.m and quickScatter.m support combining these elements in one plot. Note also the consistent color schemes between lower and upper tiangles with some deviation in color to distinguish the two sets of data.

<img align="center" width="825" height="700" src="https://i.imgur.com/bSebixu.png">
<br/>
<br/>


Here is another example for a rectengular matrix. Here, we pull out the histograms and place them at the edges of the correlogram. Correlogram interpolates between 3 colors to make a stark colormap. It also creates 2D colormaps by interpolating between two 1D colormaps, like shown in the plots below.


<img align="center" width="1000" height="850" src="https://i.imgur.com/zzG0Ama.png">
<br/>
<br/>

See main.m for some examples of usage (note, this code is just how I've used Correlogram.m for some projects but may be helpful for understanding how to organize your data) 
