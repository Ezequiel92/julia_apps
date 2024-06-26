<div align="center">
    <h1>👨‍💻 Julia apps</h1>
</div>

<p align="center">
    <a href="https://julialang.org"><img src="https://img.shields.io/badge/-Julia-9558B2?style=for-the-badge&logo=julia&logoColor=white"></a>
</p>

> [!CAUTION]
> This code is written for my personal use and purely as an exercise, thus it may break at any moment. Use it at your own risk.

Collection of single-file apps written in Julia, as a learning exercise.

- Each folder has a .jl file which is a self-contained script and can be run as is.
- The .toml files in each folder contain the dependencies for all the scripts.
- The functions within each app are documented using docstrings.
- An example of how to use the app is written at the end of each `.jl` file.

## 💻 Apps

😷 `COVID-19.jl`: Makes an interactive plot (as a .html file) of the evolution of some variable (e.g. total number of cases) for a given country. The data is taken from [Our World in Data](https://github.com/owid/covid-19-data).

🤖 `MNISTNet.jl`: Julia implementation of the simple neural network of [Neural Network From Scratch](https://github.com/Bot-Academy/NeuralNetworkFromScratch), with some modifications and additions.

📚 `WishlistScrapper.jl`: A Web scrapper for any [Book Depository](https://www.bookdepository.com) public wishlist. It saves the data as a JSON file.

## Output

- For the apps that generate some kind of output, it will be stored in the `output/` directory within each app folder.
