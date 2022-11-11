using ImageCore, MLDatasets, Plots

const LEARNING_RATE = 0.01
const EPOCHS = 5
const MNIST_PATH = "MNIST"

"""
    train_net(images::Array{Float32, 3}, labels::Vector{Int64}; <keyword arguments>)

Train a basic neural network on the MNIST dataset.

# Arguments

  - `images::Array{Float32, 3}`: Images to do the training.
  - `labels::Vector{Int64}`: Labels of the images.
  - `show_training::Bool=true`: If it will print each epoch accuracy and mean error.

# Returns

  - The weights and biases of the train net as the tuple (w_i_h, w_h_o, b_i_h, b_h_o), where w = weights, b = bias, i = input, h = hidden and o = output, e.g. w_i_h = weights from input layer to hidden layer.
"""
function train_net(images::Array{Float32,3}, labels::Vector{Int64}; show_training::Bool=true)

    # Initialize the weiths and biasis randomly
    w_i_h = rand(Float64, (20, 784)) .- 0.5
    w_h_o = rand(Float64, (10, 20)) .- 0.5
    b_i_h = zeros(Float64, 20, 1)
    b_h_o = zeros(Float64, 10, 1)

    # Set the possible output values
    ov = [zeros(10, 1) for _ in 1:10]
    for i in 1:10
        ov[i][i, 1] = 1.0
    end

    # Initialize the vector of the images with a shape of 784x1
    vec_img = reshape.(eachslice(images, dims=3), 784, 1)

    for epoch in 1:EPOCHS

        # Initialize the number of correct guesses
        n_correct = 0
        # Initialize the mean error per epoch
        e = 0

        for (img, number) in zip(vec_img, labels)

            # Forward propagation input -> hidden
            h_pre = b_i_h + w_i_h * img
            h = @. 1 / (1 + exp(-h_pre))
            # Forward propagation hidden -> output
            o_pre = b_h_o + w_h_o * h
            o = @. 1 / (1 + exp(-o_pre))

            # Compute Cost / Error
            l = ov[number + 1]
            e += sum((o - l) .^ 2) / length(o)
            n_correct += argmax(o) == argmax(l) ? 1 : 0

            # Backpropagation output -> hidden (cost function derivative)
            delta_o = o - l
            w_h_o += -LEARNING_RATE * delta_o * h'
            b_h_o += -LEARNING_RATE * delta_o
            # Backpropagation hidden -> input (activation function derivative)
            delta_h = w_h_o' * delta_o .* (h .* (1 .- h))
            w_i_h += -LEARNING_RATE * delta_h * img'
            b_i_h += -LEARNING_RATE * delta_h

        end

        # Show accuracy and error for this epoch
        if show_training
            acc = round(100 * n_correct / size(images, 3), sigdigits=3)
            err = round(e / length(vec_img), sigdigits=3)
            println("Epoch $epoch, accuracy: $acc%, mean error: $err")
        end

    end

    return w_i_h, w_h_o, b_i_h, b_h_o

end

"""
    mnist_net(; <keyword arguments>)

Run train_net(), allowing for automatic or interactive testing of the results.

# Arguments

  - `interactive::Bool=false`: If the testing of the results will be interactive or automatic. In interactive mode, it prompts you to choose one image from the testing set, and runs the trained net on it. In automatic mode, it will test the trained net on the whole test set of 10000 images.
  - `show_training::Bool=true`: If it will print each epoch accuracy and mean error.
"""
function mnist_net(; interactive::Bool=false, show_training::Bool=true)

    # Load train dataset
    images, labels = MNIST(; split=:train, dir=MNIST_PATH)[:]
    # Load test dataset
    test_images, test_labels = MNIST(; split=:test, dir=MNIST_PATH)[:]

    # Train the neural net
    w_i_h, w_h_o, b_i_h, b_h_o = train_net(images, labels; show_training)

    if interactive
        while true

            # Select a testing image
            print("Choose an image (1 - 10000): \n")
            ans = readline()
            idx = parse(Int64, ans)
            img = test_images[:, :, idx]

            # Forward propagation input -> hidden
            h_pre = b_i_h .+ w_i_h * reshape(img, 784, 1)
            h = @. 1 / (1 + exp(-h_pre))
            # Forward propagation hidden -> output
            o_pre = b_h_o .+ w_h_o * h
            o = @. 1 / (1 + exp(-o_pre))

            # Show the image and the result
            title = "\n I think it is a $(argmax(o)[1] - 1) with \
            $(round(maximum(o) * 100, sigdigits = 3))% confidence \n"
            println(title)
            plot(MNIST.convert2image(img); title, axis=nothing)
            gui()

        end
    else
        test_correct = 0
        # Set possible output values
        ov = [zeros(10, 1) for _ in 1:10]
        for i in 1:10
            ov[i][i, 1] = 1.0
        end

        for (img, number) in zip(eachslice(test_images, dims=3), test_labels)

            # Forward propagation input -> hidden
            h_pre = b_i_h .+ w_i_h * reshape(img, 784, 1)
            h = @. 1 / (1 + exp(-h_pre))
            # Forward propagation hidden -> output
            o_pre = b_h_o .+ w_h_o * h
            o = @. 1 / (1 + exp(-o_pre))

            l = ov[number + 1]
            test_correct += argmax(o) == argmax(l) ? 1 : 0

        end

        accuracy = round(100 * test_correct / size(test_images, 3), sigdigits=3)
        println("\nAccuracy on the test dataset: $accuracy%")
    end

end

####################################################################################################
# Usage
####################################################################################################

mnist_net(interactive=true, show_training=true)
