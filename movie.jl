using Oceananigans
using GLMakie
using JLD2

ζt = FieldTimeSeries("fields.jld2", "ζ")
Nt = length(ζt)

trajectoriesfilename = "trajectories.jld2"
file = jldopen(trajectoriesfilename)
saveiters = parse.(Int, keys(file["timeseries/t"]))
data = [file["timeseries/particles/$iter"] for iter in saveiters]
close(file)

Nt = length(data)
function trajectory(data, p)
    Nt = length(data)
    x = [data[n].x[p] for n = 1:Nt]
    y = [data[n].y[p] for n = 1:Nt]
    return x, y
end

xp1, yp1 = trajectory(data, 1)
xp2, yp2 = trajectory(data, 2)
xp3, yp3 = trajectory(data, 3)
xp4, yp4 = trajectory(data, 4)

fig = Figure()
axζ = Axis(fig[1, 1], aspect=1)

slider = Slider(fig[2, 1], range=1:Nt, startvalue=1)
n = slider.value
ζn = @lift ζt[$n]
xn = @lift xp1[$n]
yn = @lift yp1[$n]

heatmap!(axζ, ζn)
#scatter!(axζ, xn, yn)
scatter!(axζ, xp1, yp1, color=:red, markersize=20)
scatter!(axζ, xp2, yp2, color=:red, markersize=20)
scatter!(axζ, xp3, yp3, color=:red, markersize=20)

display(fig)
