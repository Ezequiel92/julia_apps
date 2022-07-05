<div align="center">
    <h1>👨‍💻 Julia apps</h1>
</div>

<p align="center">
    <a href="https://julialang.org"><img src="https://forthebadge.com/images/badges/made-with-julia.svg"></a>
</p>

Collection of single-file apps written in Julia, as a learning exercise.

- Each folder has a .jl file which is a self-contained script and can be run as is.
- The .toml files in each folder contain the dependencies for all the scripts.
- The functions within each app are documented using docstrings.
- An example of how to use the app is written at the end of each one and is what is executed when the file is run.

## 💻 Apps

😷 `COVID-19.jl`: Makes an interactive plot (as a .html file) of the evolution of some variable (e.g. total number of cases) for a given country. The data is taken from [Our World in Data](https://github.com/owid/covid-19-data).

🌌 `GravitySim.jl`: (🚧 WIP 🚧) Makes a GIF of an N-body gravitational simulation.

🤖 `MNISTNet.jl`: Julia implementation of the simple neural network of [Neural Network From Scratch](https://github.com/Bot-Academy/NeuralNetworkFromScratch), with some modifications and additions.

📚 `WishlistScrapper.jl`: A Web scrapper for any [Book Depository](https://www.bookdepository.com) public wishlist. It saves the data in a JSON file. I could only find two similar projects in GitHub, one in Python2 (more than 10 years old) and the other in Javascript (from more than two years ago), both were unmaintained, and obviously, neither worked. So, I made my own.

## Output

- For the apps that generate some kind of output, it will be stored in the `output/` directory within each app folder.

## ⚠️ Warning

These scripts are written as an exercise and may break at any moment. So, use them at your own risk.
