using MLDatasets, Plots, ImageCore

const LEARNING_RATE = 0.01
const EPOCHS = 5

"""
    trainNet(
        images::Base.ReinterpretArray, 
        labels::Vector{Int64};
        <keyword arguments>,
    )

Train a basic neural network on the MNIST dataset.
        
# Arguments
- `images::Base.ReinterpretArray`: Images to do the training.
- `labels::Vector{Int64}`: Labels of the images.
- `show_training::Bool = true`: If it will print each epoch accuracy and mean error.

# Returns
- The weiths and biasis of the train net as (w_i_h, w_h_o, b_i_h, b_h_o), where w = weights, 
  b = bias, i = input, h = hidden, o = output and l = label, e.g. w_i_h = weights from 
  input layer to hidden layer.
"""
function trainNet(
    images::Base.ReinterpretArray, 
    labels::Vector{Int64}; 
    show_training::Bool = true,
)

    # Random initialized the weiths and biasis
    w_i_h = rand(Float64, (20, 784)) .- 0.5
    w_h_o = rand(Float64, (10, 20)) .- 0.5
    b_i_h = zeros(Float64, 20, 1)
    b_h_o = zeros(Float64, 10, 1)

    # Possible output values
    ov = [zeros(10, 1) for _ in 1:10]
    for i in 1:10
        ov[i][i, 1] = 1.0
    end

    # Vector of the images with a shape of 784x1
    vec_img = reshape.(eachslice(images, dims = 3), 784, 1)
    
    for epoch in 1:EPOCHS

        # Number of correct guesses
        n_correct = 0
        # Mean error per epoch
        e = 0

        for (img, number) in zip(vec_img, labels)

            # Forward propagation input -> hidden
            h_pre = b_i_h + w_i_h * img
            h = @. 1 / (1 + exp(-h_pre))
            # Forward propagation hidden -> output
            o_pre = b_h_o + w_h_o * h
            o = @. 1 / (1 + exp(-o_pre))

            # Cost / Error calculation
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
            ep = "Epoch $epoch, "
            acc = "accuracy: $(round((n_correct / size(images, 3)) * 100, sigdigits = 3))%"
            err = ", mean error: $(round(e / length(vec_img), sigdigits = 3))"
            println(ep * acc * err)
        end

    end

    return w_i_h, w_h_o, b_i_h, b_h_o

end

"""
    MNIST_net(<keyword arguments>)

Run trainNet(), allowing for automatic or interactive testing of the results.
        
# Arguments
- `interactive::Bool = false`: If the testing of the results will be interactive or 
  automatic. In interactive mode, it prompts you to choose one image from the 
  testing set, and runs the trained net on it. In automatic mode, it will test the trained 
  net on the whole test set of 10000 images.
- `show_training::Bool = true`: If it will print each epoch accuracy and mean error.
"""
function MNIST_net(;interactive::Bool = false, show_training::Bool = true)

    # Load train dataset
    images, labels = MNIST.traindata(dir = "./MNIST")
    # Load test dataset
    test_images, test_labels = MNIST.testdata(dir = "./MNIST")

    # Train the neural net
    w_i_h, w_h_o, b_i_h, b_h_o = trainNet(images, labels; show_training)

    if interactive
        while true

            # Select a testing image
            print("Choose an image (1 - 10000): ") 
            idx =  parse(Int64, readline())
            img = test_images[:, :, idx]

            # Forward propagation input -> hidden
            h_pre = b_i_h .+ w_i_h * reshape(img, 784, 1)
            h = @. 1 / (1 + exp(-h_pre))
            # Forward propagation hidden -> output
            o_pre = b_h_o .+ w_h_o * h
            o = @. 1 / (1 + exp(-o_pre))

            # Show the image and the result
            title = "I think it is a $(argmax(o)[1] - 1) with " *
            "$(round(maximum(o) * 100, sigdigits = 3))% confidence"
            plot(MNIST.convert2image(img); title, axis = nothing)
            gui()

        end
    else
        test_correct = 0
        # Possible output values
        ov = [zeros(10, 1) for _ in 1:10]
        for i in 1:10
            ov[i][i, 1] = 1.0
        end

        for (img, number) in zip(eachslice(test_images, dims = 3), test_labels)

            # Forward propagation input -> hidden
            h_pre = b_i_h .+ w_i_h * reshape(img, 784, 1)
            h = @. 1 / (1 + exp(-h_pre))
            # Forward propagation hidden -> output
            o_pre = b_h_o .+ w_h_o * h
            o = @. 1 / (1 + exp(-o_pre))

            l = ov[number + 1]
            test_correct += argmax(o) == argmax(l) ? 1 : 0

        end

        println()
        test_accu = "Accuracy on the test dataset:" * 
        " $(round((test_correct / size(test_images, 3)) * 100, sigdigits = 3))%"   
        println(test_accu)
    end

end

############################################################################################
# Usage.
############################################################################################

MNIST_net(interactive = true, show_training = true)