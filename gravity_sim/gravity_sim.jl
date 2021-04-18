using Plots, NBodySimulator, StaticArrays

############################################################################################
# Constants for the simulation.
############################################################################################

"Gravitational constant. It sets the unit system => pc^3 / (Mₒ Myr^2)."
const G = 4.49e-3

"Side length of the simulation region (vaccum boundary conditions) in pc."
const BOX_SIZE = (-2.5e6, 2.5e6)

"Duration of the simulation in Myr."
const DURATION = (0.0, 1000.0)

"Color scheme for the stars."
const COLOR_SCHEME = "orange_stars"

"Frame rate of the final animation."
const FPS = 30

"Pixel size of the frames and final GIF."
const RESOLUTION = (1280, 720)

# Color schemes for the stars.
if COLOR_SCHEME == "orange_stars"

    markercolor = :darkorange2
    markershape = :star5
    background_color = :black
    background_color_outside = :black

elseif COLOR_SCHEME == "white_stars"

    markercolor = :white
    markershape = :circle
    background_color = :black
    background_color_outside = :black

end

############################################################################################
# Auxiliary functions.
############################################################################################

"""
    randMass()::Float64

Generate a random mass following the Salpeter (1995) IMF.
"""
function randMass()::Float64

    while true
        # Stellar mass between 0.4 and 10 Mₒ.
        global mass = 4.8 * rand() + 5.2
        # Salpeter (1995) IMF.
        prob = mass^(-2.35) / 2.51894
        rand() > prob || break
    end

    return mass

end

"""
    randPosVel(kind::String)::NTuple{2, Vector{Float64}}

Generate a random position and velocity depending on the type of simulation.

# Arguments
- `kind::String`: Type of simulation. The options are "Gas" and "Globular cluster".

# Returns
- A Tuple with two Vectors containing the position and velocity.
"""
function randPosVel(kind::String)::NTuple{2, SVector{3, Float64}}

    side_length = BOX_SIZE[2] - BOX_SIZE[1]

    if kind == "Gas"

        x, y, z = side_length .* rand(3) .- (side_length / 2)
        vx, vy, vz = 50 .* randn(3) .+ 100

    elseif kind == "Globular cluster"

        R_A = (side_length / 10.0) + randn() * (side_length / 20.0)
        box_size_A = side_length - 2 * R_A
        center_A = box_size_A .* rand(3) .- (box_size_A / 2)

        R_B = (side_length / 10.0) + randn() * (side_length / 20.0)
        box_size_B = side_length - 2 * R_B
        center_B = box_size_B .* rand(3) .- (box_size_B / 2)

        R_center = rand(((R_A, center_A), (R_B, center_B)))

        r = (R_center[1] / 2) * randn()
        coord = randn(3)

        x, y, z = (coord ./ sqrt.(cumsum(coord .^ 2)) .* r) .+ R_center[2]

        V = (50 * randn() + 100) .* (-R_center[2])
        vx, vy, vz = 5 .* randn(3) .+ 10 .+ V

    end

    return SVector(x, y, z), SVector(vx, vy, vz)
end

"""
    initCondition(kind::String, N::Int64)::Vector{MassBody{Float64, Float64}}

Generate a random initial condition depending on the type of simulation.

# Arguments
- `kind::String`: Type of simulation. The options are "Gas" and "Globular cluster".
- `N::Int64`: Total number of stars for the simulation.

# Returns
- A Vector with the data for the initial condition.
"""
function initCondition(kind::String, N::Int64)::Vector{MassBody{Float64, Float64}}

    stars = MassBody{Float64, Float64}[]
    for i in 1:N
        rand_pos, rand_vel = randPosVel(kind)
        rand_mass = randMass()
        star = MassBody(rand_pos, rand_vel, rand_mass)
        push!(stars, star)
    end

    return stars
end

############################################################################################
# Main function.
############################################################################################

"""
    makeSim(N::Int64, kind::String, tspan::Tuple{Float64, Float64})

Run a gravitational simulation with `N` stars distributed according to `kind` 
for a period of `tspan`. 

# Arguments
- `N::Int64`: Total number of stars for the simulation.
- `kind::String`: Type of simulation. The options are "Gas" and "Globular cluster".
- `tspan::Tuple{Float64, Float64}`: Total duration of the simulation.

# Returns
- The result of the simulation.
"""
function makeSim(N::Int64, kind::String, tspan::Tuple{Float64, Float64})

    stars = initCondition(kind, N)
    universe = GravitationalSystem(stars, G)
    simulation = NBodySimulation(universe, tspan)

    return run_simulation(simulation)
end

# Create the directory where the frames will be temporarily stored.
mkpath("TEMP/")

############################################################################################
# Usage.
############################################################################################

# Duration of the simulation in Myr.
tspan = DURATION
# Time length of each frame, for a 1 minute long animation.
frame_time = (tspan[2] - tspan[1]) / (60 * FPS)

sim_result = makeSim(1000, "Globular cluster", tspan)

animation = @animate for (i, t) in enumerate(tspan[1]:frame_time:tspan[2])
    universe = sim_result(t)
    N = Int(size(universe, 2) / 2)
    scatter3d(
        universe[1, 1:N], universe[2, 1:N], universe[3, 1:N],
        camera = (45, 45),
        xlims = BOX_SIZE,
        ylims = BOX_SIZE,
        zlims = BOX_SIZE,
        legend = false,
        grid = false,
        border = :none,
        axis = nothing,
        aspect_ratio = 1,
        markersize = 3,
        markerstrokewidth = 0;
        markercolor,
        markershape,
        background_color,
        background_color_outside,
        size = RESOLUTION,
    )
    savefig("TEMP/" * "frame_" * string(i) * ".png")
end

# Make the GIF.
gif(animation, "example.gif", fps = FPS)

#rm("TEMP/")
