using MLDatasets, Plots, ImageCore

"""
    trainNet(
        images::Base.ReinterpretArray, 
        labels::Vector{Int64};
        <keyword arguments>,
    )

Train a basic single layer net on the MNIS dataset.
        
# Arguments
- `images::Base.ReinterpretArray`: Train dataset.
- `labels::Vector{Int64}`: Labels of the train dataset.
- `show_training::Bool = true`: If it will show the results of each epoch of training.

# Returns
- The weiths and biasis of the train net as:
  (w_i_h, w_h_o, b_i_h, b_h_o)
  where w = weights, b = bias, i = input, h = hidden, o = output, l = label,
  e.g. w_i_h = weights from input layer to hidden layer.
"""
function trainNet(
    images::Base.ReinterpretArray, 
    labels::Vector{Int64}; 
    show_training::Bool = true,
)

    w_i_h = rand(Float64, (20, 784)) .- 0.5
    w_h_o = rand(Float64, (10, 20)) .- 0.5
    b_i_h = zeros(Float64, 20, 1)
    b_h_o = zeros(Float64, 10, 1)

    # Possible output values
    ov = []
    for n in 1:10
        push!(ov, zeros(10, 1))
        ov[end][n, 1] = 1
    end

    learn_rate = 0.01
    n_correct = 0
    epochs = 5
    for epoch in 1:epochs
        for (img, n) in zip(eachslice(images, dims=3), labels)

            # l = zeros(10, 1)
            # l[n + 1, 1] = 1
            img = reshape(img, 784, 1)

            # Forward propagation input -> hidden
            h_pre = b_i_h + w_i_h * img
            h = @. 1 / (1 + exp(-h_pre))
            # Forward propagation hidden -> output
            o_pre = b_h_o + w_h_o * h
            o = @. 1 / (1 + exp(-o_pre))

            # Cost / Error calculation
            l = ov[n+1]
            e = sum((o - l) .^ 2) / length(o)
            n_correct += argmax(o) == argmax(l) ? 1 : 0

            # Backpropagation output -> hidden (cost function derivative)
            delta_o = o - l
            w_h_o += -learn_rate * delta_o * h'
            b_h_o += -learn_rate * delta_o
            # Backpropagation hidden -> input (activation function derivative)
            delta_h = w_h_o' * delta_o .* (h .* (1 .- h))
            w_i_h += -learn_rate * delta_h * img'
            b_i_h += -learn_rate * delta_h

        end

        # Show accuracy for this epoch
        if show_training
            ep = "Epoch $epoch, "
            acc = "accuracy: $(round((n_correct / size(images, 3)) * 100, sigdigits=3))%"
            println(ep * acc)
        end
        n_correct = 0

    end

    return w_i_h, w_h_o, b_i_h, b_h_o

end

"""
    MNIST_net(<keyword arguments>)

Run a training session of trainNet(), allowing for automatic or interactive testing.
        
# Arguments
- `interactive::Bool = false`: If the testing of the result will be interactive or 
  automatic. In interactive mode, it prompts for you to choose one image from the 
  testing set, and runs the train net on it. In automatic mode it will test the trained 
  net on the whole test set of 10000 images.
- `show_training::Bool = true`: If it will show the results of each epoch of training.
"""
function MNIST_net(;interactive::Bool = false, show_training::Bool = true)
    images, labels = MNIST.traindata(dir="./MNIST")
    test_images, test_labels = MNIST.testdata(dir="./MNIST")

    w_i_h, w_h_o, b_i_h, b_h_o = trainNet(images, labels; show_training)

    if interactive

        while true

            print("Enter a number (1 - 10000): ") 
  
            # Calling rdeadline() function
            idx =  parse(Int64, readline())
            img = test_images[:, :, idx]

            # Forward propagation input -> hidden
            h_pre = b_i_h .+ w_i_h * reshape(img, 784, 1)
            h = @. 1 / (1 + exp(-h_pre))
            # Forward propagation hidden -> output
            o_pre = b_h_o .+ w_h_o * h
            o = @. 1 / (1 + exp(-o_pre))

            plot(
                MNIST.convert2image(img), 
                title = "I think it is a $(argmax(o)[1] - 1) with $(round(maximum(o) * 100, sigdigits = 3))% confidence",
                axis = nothing,
            )
            gui()
        end

    else
        test_correct = 0
        for (img, n) in zip(eachslice(test_images, dims=3), test_labels)

            l = zeros(10, 1)
            l[n + 1, 1] = 1

            # Forward propagation input -> hidden
            h_pre = b_i_h .+ w_i_h * reshape(img, 784, 1)
            h = @. 1 / (1 + exp(-h_pre))
            # Forward propagation hidden -> output
            o_pre = b_h_o .+ w_h_o * h
            o = @. 1 / (1 + exp(-o_pre))

            test_correct += argmax(o) == argmax(l) ? 1 : 0

        end

        println()
        println("Test accuracy: $(round((test_correct / size(test_images, 3)) * 100, sigdigits=3))%")
    end
end

############################################################################################
# Usage.
############################################################################################

MNIST_net(interactive=true, show_training = true)