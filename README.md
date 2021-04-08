# Collection of Julia scripts.

[![ForTheBadge made-with-julia](https://forthebadge.com/images/badges/made-with-julia.svg)](https://julialang.org)

[![GitHub](https://img.shields.io/github/license/Ezequiel92/julia_apps?style=flat-square)](https://github.com/Ezequiel92/julia_apps/blob/main/LICENSE) [![Maintenance](https://img.shields.io/maintenance/yes/2021?style=flat-square)](mailto:lozano.ez@gmail.com)

Collection of single-file apps written in Julia, as learning projects.

- Each folder contains one .jl file with the script and the .toml files with the dependencies. 
- Each app is self-contained, and can be run as is.  
- The functions within each app are documented using docstrings. 
- An example on how to use the app is written at the end of each .jl file, and is what it is executed when the file in run. 

## Apps

COVID-19: Makes an interactive plot (outputs an .html file) of some variable (e.g. total number of cases) versus time for a given country. The data is taken from [Our World in Data](https://github.com/owid/covid-19-data).

wishlist_scrapper: A Web scrapper for the books in a [Book Depository](https://www.bookdepository.com) public wishlist. It saves the data in a JSON file. I could find only two similar projects in GitHub, one in Python2 (more than 10 years old) and the other in Javascript (from more than two years ago), both were unmaintained and obviously neither worked. So, I made my own in Julia.

gravity_sim: (UNDER CONSTRUCTION) Makes a GIF of a N-body gravitational simulation.
