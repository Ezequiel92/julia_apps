# 👨‍💻 Collection of small Julia apps

[![ForTheBadge made-with-julia](https://forthebadge.com/images/badges/made-with-julia.svg)](https://julialang.org)

[![GitHub](https://img.shields.io/github/license/Ezequiel92/julia_apps?style=flat-square)](https://github.com/Ezequiel92/julia_apps/blob/main/LICENSE) [![Maintenance](https://img.shields.io/maintenance/yes/2021?style=flat-square)](mailto:lozano.ez@gmail.com)

Collection of single-file apps written in Julia, as a learning exercise.

- Each .jl file is a script and the .toml files contain the dependencies for all of them. 
- Each app is self-contained and can be run as is.  
- The functions within each app are documented using docstrings. 
- An example of how to use the app is written at the end of each .jl file and is what is executed when the file is run. 

## 💻 Apps

😷 `COVID-19.jl`: Makes an interactive plot (outputs a .html file) of the evolution of some variable (e.g. total number of cases) for a given country. The data is taken from [Our World in Data](https://github.com/owid/covid-19-data).

🌌 `gravity_sim.jl`: (UNDER CONSTRUCTION) Makes a GIF of an N-body gravitational simulation.

🤖 `MNIST_net.jl`: Julia implementation of a simple feedforward neural network. Based on [Neural Network From Scratch](https://github.com/Bot-Academy/NeuralNetworkFromScratch) with some modifications.

📚 `wishlist_scrapper.jl`: A Web scrapper for any [Book Depository](https://www.bookdepository.com) public wishlist. It saves the data in a JSON file. I could find only two similar projects in GitHub, one in Python2 (more than 10 years old) and the other in Javascript (from more than two years ago), both were unmaintained, and obviously, neither worked. So, I made my own in Julia.

## Output

- For the apps that generate some kind of output, this will be stored in `output/`.
- The folder `auxiliary/`is used to store working files for the scripts, and it can be emptied between runs.

## 📣 Contact

[![image](https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:lozano.ez@gmail.com)

[![image](https://img.shields.io/badge/Microsoft_Outlook-0078D4?style=for-the-badge&logo=microsoft-outlook&logoColor=white)](mailto:lozano.ez@outlook.com)

## ⚠️ Warning

These scripts are written as an exercise and may break at any moment. So, no guarantees are given.
