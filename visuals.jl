function state_timeseries(event_db)
	"""
	Count the number of individuals in each state at each event time
	"""
	susceptible = fill(0, length(event_db.event_times[event_db.event_times .< Inf]))
	infectious = fill(0, length(event_db.event_times[event_db.event_times .< Inf]))
	if size(event_db.events)[2] == 4
		recovered = fill(0, length(event_db.event_times[event_db.event_times .< Inf]))
		for t = 1:length(event_db.event_times[event_db.event_times .< Inf])
			susceptible[t] = sum(find_state(event_db, event_db.event_times[t], "S"))
			infectious[t] = sum(find_state(event_db, event_db.event_times[t], "I"))
			recovered[t] = sum(find_state(event_db, event_db.event_times[t], "R"))
		end
		return DataFrame(time = event_db.event_times[event_db.event_times .< Inf], S = susceptible, I = infectious, R = recovered)
	end
    if size(event_db.events)[2] == 3
        for t = 1:length(event_db.event_times[event_db.event_times .< Inf])
            susceptible[t] = sum(find_state(event_db, event_db.event_times[t], "S"))
            infectious[t] = sum(find_state(event_db, event_db.event_times[t], "I"))
        end
        return DataFrame(time = event_db.event_times[event_db.event_times .< Inf], S = susceptible, I = infectious)
    end
end

function spatial_states(pop_db, event_db, time)
    """
    Determine infection status for each individual at a specific time,
    and create a dataframe which includes their coordinates for easy
    spatial plotting of status through time
    """
    i = find_state(event_db, time, "I")
    state = fill("S", length(i))
    #state_num = fill(1, length(i))
    state[i] = "I"
    #state_num[i] = 2
    if size(event_db.events)[2] == 4
        state[find_state(event_db, time, "R")] = "R"
        #state_num[find_state(event_db, time, "R")] = 3
    end
    return append!(DataFrame(x=fill(NaN, 3), y=fill(NaN, 3), state=["S", "I", "R"]), DataFrame(x=pop_db[:,2], y=pop_db[:,3], state=state))
    #return sort!(DataFrame(x=pop_db[:,2], y=pop_db[:,3], state=state, state_num=state_num), cols=:state_num)
end

function state_animation(framewindow, event_db, pop_db)
    """
    Make a spatial animation/slider in ijulia
    """
    @manipulate for time = 1:framewindow:ceil(maximum(event_db.event_times[event_db.event_times .< Inf]))
        plot(spatial_states(pop_db, event_db, time), x="x", y="y", Geom.point, color="state", Scale.discrete_color_manual("black", "orange", "blue"))
    end
end