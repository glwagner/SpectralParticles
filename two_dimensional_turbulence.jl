using Oceananigans

Nx = Ny = 128
x = y = (-π, π)
grid = RectilinearGrid(size=(Nx, Ny); x, y, topology=(Periodic, Periodic, Flat))

Np = 10
x = π .* (2rand(Np) .- 1)
y = π .* (2rand(Np) .- 1)
z = zeros(Np)
particles = LagrangianParticles(; x, y, z)

model = NonhydrostaticModel(; grid, particles, advection=WENO(order=5))

uᵢ(x, y) = 2rand() - 1
set!(model, u=uᵢ, v=uᵢ)

simulation = Simulation(model, Δt=0.1, stop_time=10)
conjure_time_step_wizard!(simulation, cfl=0.7)
run!(simulation)

u, v, w = model.velocities
ζ = ∂x(v) - ∂y(u)
outputs = (; u, v, ζ)
T = 0.01
mooring = JLD2OutputWriter(model, outputs,
                           schedule = TimeInterval(T),
                           filename = "mooring.jld2",
                           indices = (Nx÷2, Ny÷2, 1),
                           overwrite_existing = true)

fields = JLD2OutputWriter(model, outputs,
                          schedule = TimeInterval(T),
                          filename = "fields.jld2",
                          overwrite_existing = true)

trajectories = JLD2OutputWriter(model, (; particles),
                                schedule = TimeInterval(T),
                                filename = "trajectories.jld2",
                                overwrite_existing = true)

simulation.output_writers[:mooring] = mooring
simulation.output_writers[:fields] = fields
simulation.output_writers[:trajectories] = trajectories

run!(simulation)

