module Keyword

using Printf

export AMPLITUDE, BOUNDARY, BUCKLE, CLOAD, CONN3D2,
       CONNECTOR_BEHAVIOR, CONNECTOR_ELASTICITY, CONNECTOR_FRICTION,
       CONNECTOR_SECTION, CONSTRAINT_CONTROLS, CONTACT, CONTROLS,
       CONTACT_CONTROLS, CONTACT_INCLUSIONS, CONTACT_INITIALIZATION_ASSIGNMENT,
       CONTACT_INITIALIZATION_DATA, CONTACT_PAIR, CONTACT_PROPERTY_ASSIGNMENT,
       CONTACT_STABILIZATION, CONTROLS_RESET, CONTROLS_CONSTRAINTS,
       CONTROLS_FIELD, CONTROLS_LINE_SEARCH, CONTROLS_TIME_INCREMENTATION,
       DENSITY, DLOAD, DLOAD_GRAV, DSLOAD, DYNAMIC, DYNAMIC_EXPLICIT,
       EL_FILE, ELASTIC, ELEMENT_SPRING, ELEMENT, ELEMENT_OUTPUT, ELSET,
       EL_PRINT, EQUATION, FASTENER, FASTENER_PROPERTY, FRICTION, HEADING,
       INSTANCE, KINEMATIC_COUPLING, MATERIAL, NODE, NODE_OUTPUT, NODE_PRINT,
       NSET, ORIENTATION, OUTPUT, OUTPUT_TIME_POINTS, PART, PLASTIC,
       PREPRINT, RESTART, RIGID_BODY, SHELL_SECTION, SOLID_SECTION,
       BEAM_SECTION, BEAM_ARBITRARY_SECTION, BEAM_GENERAL_SECTION,
       SPRING, STATIC, STEP, SURFACE, SURFACE_BEHAVIOR, SURFACE_INTERACTION,
       TIE, TIME_POINTS, UEL_PROPERTY_DING_CONNECTOR, USER_ELEMENT


"""
    AMPLITUDE(name, x, y)

Write an `*Amplitude` keyword block.

Groups up to 4 (x, y) pairs per line as required by Abaqus.

# Arguments
- `name`: Amplitude table name
- `x`: Vector of time (or frequency) values
- `y`: Vector of amplitude values, same length as `x`

# Returns
A vector of strings forming the keyword block.
"""
function AMPLITUDE(name, x, y)

    lines = @sprintf "*Amplitude, name=%s" name

    num_rows=size(x)[1]

    #Figure out the number of rows in the set.
    residual = num_rows/4 - floor(Int, num_rows/4)

    if residual == 0.0
        num_rows = floor(Int, num_rows/4)
    else
        num_rows = floor(Int, num_rows/4) + 1
    end

    for i=1:num_rows

        if (i== num_rows) & (residual > 0.0)

            residual_inputs = Int(residual * 4)
            x_last_row =  x[end-residual_inputs + 1:end]
            y_last_row = y[end-residual_inputs + 1:end]

            if residual_inputs == 1
                line = @sprintf "%9.5f,%9.5f" x_last_row[1] y_last_row[1]
            elseif residual_inputs == 2
                line = @sprintf "%9.5f,%9.5f,%9.5f,%9.5f" x_last_row[1] y_last_row[1] x_last_row[2] y_last_row[2]
            elseif residual_inputs == 3
                line = @sprintf "%9.5f,%9.5f,%9.5f,%9.5f,%9.5f,%9.5f" x_last_row[1] y_last_row[1] x_last_row[2] y_last_row[2] x_last_row[3] y_last_row[3]
            elseif residual_inputs == 4
                line = @sprintf "%9.5f,%9.5f,%9.5f,%9.5f,%9.5f,%9.5f,%9.5f,%9.5f" x_last_row[1] y_last_row[1] x_last_row[2] y_last_row[2] x_last_row[3] y_last_row[3] x_last_row[4] y_last_row[4]
            end

            lines = [lines; line]

        else

            range_start = (i-1) * 4 + 1
            range_end = i * 4
            range = range_start:range_end

            line = @sprintf "%9.5f,%9.5f,%9.5f,%9.5f,%9.5f,%9.5f,%9.5f,%9.5f" x[range[1]] y[range[1]] x[range[2]] y[range[2]] x[range[3]] y[range[3]] x[range[4]] y[range[4]]
            lines = [lines; line]

        end

    end

    return lines

end


"""
    BOUNDARY(node_set_name, degrees_of_freedom, op)
    BOUNDARY(node::Int, degrees_of_freedom, op)
    BOUNDARY(node_set_name, degrees_of_freedom, displacement_magnitude, op)
    BOUNDARY(node_set_name, degrees_of_freedom, displacement_magnitude, amplitude_table_name, op)

Write a `*Boundary` keyword block.

Four methods are available:
- **Set name, DOF only** — zero displacement (fixed) boundary condition on a named set
- **Node integer, DOF only** — same, but targeting a single node number
- **With displacement magnitude** — prescribed displacement value
- **With amplitude** — prescribed displacement scaled by a named amplitude table

# Arguments
- `node_set_name`: Name of the node set (String)
- `node`: Single node number (Int)
- `degrees_of_freedom`: Vector of DOF integers (1=Ux, 2=Uy, 3=Uz, 4=Rx, 5=Ry, 6=Rz)
- `displacement_magnitude`: Prescribed displacement value
- `amplitude_table_name`: Name of an `*Amplitude` table to scale the displacement
- `op`: Operation type string (e.g. `"MOD"`, `"NEW"`) — pass `""` to omit

# Returns
A vector of strings forming the keyword block.
"""
function BOUNDARY(node_set_name, degrees_of_freedom, op)

    if isempty(op)
        lines = "*Boundary"
    else
        lines = @sprintf "*Boundary, OP=%s" op
    end

    for i in eachindex(degrees_of_freedom)
        lines = [lines; @sprintf "%s, %2d" node_set_name degrees_of_freedom[i]]
    end

    return lines

end


function BOUNDARY(node::Int, degrees_of_freedom, op)

    if isempty(op)
        lines = "*Boundary"
    else
        lines = @sprintf "*Boundary, OP=%s" op
    end

    for i in eachindex(degrees_of_freedom)
        lines = [lines; @sprintf "%8d, %2d" node degrees_of_freedom[i]]
    end

    return lines

end

function BOUNDARY(node_set_name, degrees_of_freedom, displacement_magnitude, op)

    if isempty(op)
        lines = "*Boundary"
    else
        lines = @sprintf "*Boundary, OP=%s" op
    end

    for i in eachindex(degrees_of_freedom)
        lines = [lines; @sprintf "%s, %o,  , %9.3f" node_set_name degrees_of_freedom[i] displacement_magnitude]
    end

    return lines

end


function BOUNDARY(node_set_name, degrees_of_freedom, displacement_magnitude, amplitude_table_name::String, op)

    if isempty(op)
        lines = @sprintf "*Boundary, amplitude=%s" amplitude_table_name
    else
        lines = @sprintf "*Boundary, OP=%s, amplitude=%s" op amplitude_table_name
    end

    for i in eachindex(degrees_of_freedom)
        lines = [lines; @sprintf "%s, %o,  , %9.3f" node_set_name degrees_of_freedom[i] displacement_magnitude]
    end

    return lines

end


"""
    BUCKLE(num_modes, max_eigenvalue, num_vectors, max_iterations)
    BUCKLE(num_modes, min_eigenvalue, max_eigenvalue, block_size, max_num_block_steps)

Write a `*Buckle` keyword block.

Two methods:
- **Subspace eigensolver** — 4-argument form
- **Lanczos eigensolver** — 5-argument form with eigenvalue bounds

# Arguments (subspace form)
- `num_modes`: Number of buckling modes to extract
- `max_eigenvalue`: Maximum eigenvalue to extract (pass `""` to omit)
- `num_vectors`: Number of Lanczos vectors
- `max_iterations`: Maximum number of iterations

# Arguments (Lanczos form)
- `num_modes`: Number of modes
- `min_eigenvalue`: Minimum eigenvalue bound
- `max_eigenvalue`: Maximum eigenvalue bound
- `block_size`: Block size (pass `""` to use default)
- `max_num_block_steps`: Maximum number of block Lanczos steps

# Returns
A vector of strings forming the keyword block.
"""
function BUCKLE(num_modes, max_eigenvalue, num_vectors, max_iterations)

    lines = "*Buckle"

    if isempty(max_eigenvalue)
        lines = [lines; @sprintf "%5d, , %5d, %5d" num_modes num_vectors max_iterations]
    else
        lines = [lines; @sprintf "%5d, %9.3f, %5d, %5d" num_modes max_eigenvalue num_vectors max_iterations]
    end

    return lines

end


function BUCKLE(num_modes, min_eigenvalue, max_eigenvalue, block_size, max_num_block_steps)

    lines = "*Buckle, eigensolver=LANCZOS"

    if isempty(block_size)
        lines = [lines; @sprintf "%o, %9.5f, %9.5f, ," num_modes min_eigenvalue max_eigenvalue]
    else
        lines = [lines; @sprintf "%o, %9.5f, %9.5f, %9.5f, %o" num_modes min_eigenvalue max_eigenvalue block_size max_num_block_steps]
    end

    return lines

end


"""
    CLOAD(node_set_name, degree_of_freedom, magnitude)

Write a `*Cload` (concentrated load) keyword block.

# Arguments
- `node_set_name`: Name of the node set or node label
- `degree_of_freedom`: DOF to load (1=Fx, 2=Fy, 3=Fz, 4=Mx, 5=My, 6=Mz)
- `magnitude`: Load magnitude

# Returns
A vector of strings forming the keyword block.
"""
function CLOAD(node_set_name, degree_of_freedom, magnitude)

    lines = "*Cload"
    lines = [lines; @sprintf "%s, %2d, %7.4f" node_set_name degree_of_freedom magnitude]

    return lines

end


"""
    CONN3D2(element_number, node_i, node_j)

Write a `*Element, type=CONN3D2` keyword block for a single connector element.

# Arguments
- `element_number`: Element label
- `node_i`: First node label
- `node_j`: Second node label

# Returns
A vector of strings forming the keyword block.
"""
function CONN3D2(element_number, node_i, node_j)

    lines = "*Element, type=CONN3D2"
    lines = [lines; @sprintf "%d, %d, %d" element_number node_i node_j]

    return lines

end


"""
    CONNECTOR_BEHAVIOR(name)

Write a `*Connector Behavior` keyword line.

# Arguments
- `name`: Connector behavior name

# Returns
A String (single line).
"""
function CONNECTOR_BEHAVIOR(name)

    lines = @sprintf "*Connector Behavior, name=%s" name

    return lines

end

"""
    CONNECTOR_ELASTICITY(component, magnitude)

Write a `*Connector Elasticity` keyword block for a single component.

# Arguments
- `component`: Connector component number
- `magnitude`: Elastic stiffness magnitude

# Returns
A vector of strings forming the keyword block.
"""
function CONNECTOR_ELASTICITY(component, magnitude)

    lines = @sprintf "*Connector Elasticity, component=%2d" component
    lines = [lines; @sprintf "%7.4E," magnitude]

    return lines

end


"""
    CONNECTOR_FRICTION(inputs)

Write a `*Connector Friction, predefined` keyword block.

# Arguments
- `inputs`: 4-element vector `[val1, val2, val3, val4]` written to the data line

# Returns
A vector of strings forming the keyword block.
"""
function CONNECTOR_FRICTION(inputs)

    lines = "*Connector Friction, predefined"
    lines = [lines; @sprintf "%9.5f, %9.5f, %9.5f, %9.5f" inputs[1] inputs[2] inputs[3] inputs[4]]

    return lines

end


"""
    CONNECTOR_SECTION(elset, behavior, coordinate_system)
    CONNECTOR_SECTION(elset, coordinate_system)
    CONNECTOR_SECTION(elset, behavior, type, orientation)

Write a `*Connector Section` keyword block.

Three methods:
- **With behavior, no type** — references a named connector behavior; coordinate system on next line
- **Without behavior** — no behavior reference; coordinate system on next line
- **With type and orientation** — full form with connector type and orientation name

# Arguments
- `elset`: Element set name
- `behavior`: Connector behavior name (omit in 2-argument form)
- `coordinate_system`: Coordinate system name or `""`
- `type`: Connector type string (e.g. `"CARTESIAN"`)
- `orientation`: Orientation name (quoted in output)

# Returns
A vector of strings forming the keyword block.
"""
function CONNECTOR_SECTION(elset, behavior, coordinate_system)

    lines = @sprintf "*Connector Section, elset=%s, behavior=%s" elset behavior
    lines = [lines; @sprintf "%s," coordinate_system]

    return lines

end


function CONNECTOR_SECTION(elset, coordinate_system)

    lines = @sprintf "*Connector Section, elset=%s" elset
    lines = [lines; @sprintf "%s," coordinate_system]

    return lines

end


function CONNECTOR_SECTION(elset, behavior, type, orientation)

    lines = @sprintf "*Connector Section, elset=%s, behavior=%s" elset behavior
    lines = [lines; @sprintf "%s," type]
    lines = [lines; @sprintf "\"%s\"," orientation]

    return lines

end


"""
    CONSTRAINT_CONTROLS(print)

Write a `*CONSTRAINT controls` keyword line.

# Arguments
- `print`: Print flag value (e.g. `"YES"` or `"NO"`)

# Returns
A String (single line).
"""
function CONSTRAINT_CONTROLS(print)

    lines = @sprintf "*CONSTRAINT controls, print=%s" print

    return lines

end


"""
    CONTACT()

Write a `*Contact` keyword line (general contact definition header).

# Returns
A String (single line).
"""
function CONTACT()

    lines = "*Contact"

end


"""
    CONTROLS(field_type)

Write a `*Controls, parameters=field` keyword block.

# Arguments
- `field_type`: Field type string (e.g. `"displacement"`)

# Returns
A vector of strings forming the keyword block.
"""
function CONTROLS(field_type)

    lines = @sprintf "*Controls, parameters=field, field=%s" field_type
    lines = [lines; @sprintf "%9.5f, %9.5f, , , , , ," residual_tolerance correction_tolerance]

    return lines

end

"""
    CONTACT_CONTROLS(parameter)
    CONTACT_CONTROLS(parameter, damping_coeff, fraction_of_damping_at_end_of_step, clearance_at_which_damping_becomes_zero)

Write a `*Contact Controls` keyword block.

Two methods:
- **Parameter only** — single keyword option (e.g. `"STABILIZE"`)
- **With stabilization data** — includes damping coefficient and clearance values

# Arguments
- `parameter`: Contact controls parameter string
- `damping_coeff`: Contact damping coefficient
- `fraction_of_damping_at_end_of_step`: Fraction of stabilization damping at step end
- `clearance_at_which_damping_becomes_zero`: Clearance at which damping vanishes

# Returns
A vector of strings forming the keyword block.
"""
function CONTACT_CONTROLS(parameter)

    lines = @sprintf "*Contact Controls, %s" parameter

    return lines

end

function CONTACT_CONTROLS(parameter, damping_coeff, fraction_of_damping_at_end_of_step, clearance_at_which_damping_becomes_zero)

    lines = @sprintf "*Contact Controls, %s" parameter
    lines = [lines; @sprintf "%s, %9.5f, %9.5f" damping_coeff fraction_of_damping_at_end_of_step clearance_at_which_damping_becomes_zero]

    return lines

end


"""
    CONTACT_INCLUSIONS(all_exterior, surface_pairs)

Write a `*Contact Inclusions` keyword block.

# Arguments
- `all_exterior`: If `true`, emits `*Contact Inclusions, ALL EXTERIOR` with no data lines
- `surface_pairs`: Vector of 2-element tuples `(surface_1, surface_2)` — used when `all_exterior=false`

# Returns
A vector of strings forming the keyword block.
"""
function CONTACT_INCLUSIONS(all_exterior, surface_pairs)

    if all_exterior == true
        lines = "*Contact Inclusions, ALL EXTERIOR"
    else
        lines = "*Contact Inclusions"
        for i in eachindex(surface_pairs)
            lines = [lines; @sprintf "%s, %s" surface_pairs[i][1] surface_pairs[i][2]]
        end
    end

    return lines

end


"""
    CONTACT_INITIALIZATION_ASSIGNMENT(surface_pairs, initialization_name)

Write a `*Contact Initialization Assignment` keyword block.

# Arguments
- `surface_pairs`: Vector of 2-element tuples `(surface_1, surface_2)`
- `initialization_name`: Vector of initialization data names, one per pair

# Returns
A vector of strings forming the keyword block.
"""
function CONTACT_INITIALIZATION_ASSIGNMENT(surface_pairs, initialization_name)

    lines = "*Contact Initialization Assignment"

    for i in eachindex(surface_pairs)
        lines = [lines; @sprintf "%s, %s, %s" surface_pairs[i][1] surface_pairs[i][2] initialization_name[i]]
    end

    return lines

end


"""
    CONTACT_INITIALIZATION_DATA(name, search_above, search_below)

Write a `*Contact Initialization Data` keyword line.

# Arguments
- `name`: Initialization data set name
- `search_above`: Search distance above the surface
- `search_below`: Search distance below the surface

# Returns
A String (single line).
"""
function CONTACT_INITIALIZATION_DATA(name, search_above, search_below)

    lines = @sprintf "*Contact Initialization Data, name=%s, SEARCH ABOVE=%9.5f, SEARCH BELOW=%9.5f" name search_above search_below

end


"""
    CONTACT_PAIR(interaction, type, surface_pair)

Write a `*Contact Pair` keyword block.

# Arguments
- `interaction`: Surface interaction name
- `type`: Contact type (e.g. `"SURFACE TO SURFACE"`, `"NODE TO SURFACE"`)
- `surface_pair`: 2-element vector `[slave_surface, master_surface]`

# Returns
A vector of strings forming the keyword block.
"""
function CONTACT_PAIR(interaction, type, surface_pair)

    lines = @sprintf "*Contact Pair, interaction=\"%s\", type=%s" interaction type
    lines = [lines; @sprintf "%s, %s" surface_pair[1] surface_pair[2]]

    return lines

end


"""
    CONTACT_PROPERTY_ASSIGNMENT(surface_name_1, surface_name_2, surface_interaction_name)

Write a `*Contact Property Assignment` keyword block.

# Arguments
- `surface_name_1`: First surface name
- `surface_name_2`: Second surface name
- `surface_interaction_name`: Name of the surface interaction property (quoted in output)

# Returns
A vector of strings forming the keyword block.
"""
function CONTACT_PROPERTY_ASSIGNMENT(surface_name_1, surface_name_2, surface_interaction_name)

    lines = "*Contact Property Assignment"
    lines = [lines; @sprintf "%s, %s, \"%s\"" surface_name_1 surface_name_2 surface_interaction_name]

    return lines

end


"""
    CONTACT_STABILIZATION(surface_pair)

Write a `*Contact Stabilization` keyword block.

# Arguments
- `surface_pair`: 2-element vector `[surface_1, surface_2]`, or empty to apply globally

# Returns
A vector of strings forming the keyword block.
"""
function CONTACT_STABILIZATION(surface_pair)

    lines = "*Contact Stabilization"

    if !isempty(surface_pair)
        lines = [lines; @sprintf "%s, %s" surface_pair[1] surface_pair[2]]
    end

    return lines

end


"""
    CONTROLS_RESET()

Write a `*Controls, reset` keyword line to restore Abaqus default solver controls.

# Returns
A String (single line).
"""
function CONTROLS_RESET()

    lines = "*Controls, reset"

end


"""
    CONTROLS_CONSTRAINTS(Tvol, Taxial, Ttshear, Tcont, Tsoft, Tdisp, Trot, Tcfe)

Write a `*Controls, parameters=constraints` keyword block.

# Arguments
- `Tvol`: Volume ratio tolerance
- `Taxial`: Axial strain tolerance
- `Ttshear`: Transverse shear strain tolerance
- `Tcont`: Contact tolerance
- `Tsoft`: Soft contact tolerance
- `Tdisp`: Displacement correction tolerance
- `Trot`: Rotation correction tolerance
- `Tcfe`: Concentrated force/moment tolerance

# Returns
A vector of strings forming the keyword block.
"""
function CONTROLS_CONSTRAINTS(Tvol, Taxial, Ttshear, Tcont, Tsoft, Tdisp, Trot, Tcfe)

    lines = "*Controls, parameters=constraints"
    lines = [lines; @sprintf "%9.5f, %9.5f, %9.5f, %9.5f, %9.5f, %9.5f, %9.5f, %9.5f" Tvol Taxial Ttshear Tcont Tsoft Tdisp Trot Tcfe]

    return lines

end


"""
    CONTROLS_FIELD(residual_tolerance, correction_tolerance, field_type)

Write a `*Controls, parameters=field` keyword block for a specific field type.

# Arguments
- `residual_tolerance`: Force residual tolerance
- `correction_tolerance`: Displacement correction tolerance
- `field_type`: Field type string (e.g. `"displacement"`, `"rotation"`)

# Returns
A vector of strings forming the keyword block.
"""
function CONTROLS_FIELD(residual_tolerance, correction_tolerance, field_type)

    lines = @sprintf "*Controls, parameters=field, field=%s" field_type
    lines = [lines; @sprintf "%9.5f, %9.5f, , , , , ," residual_tolerance correction_tolerance]

    return lines

end


"""
    CONTROLS_LINE_SEARCH(num_iterations)

Write a `*Controls, parameters=line search` keyword block.

# Arguments
- `num_iterations`: Maximum number of line search iterations

# Returns
A vector of strings forming the keyword block.
"""
function CONTROLS_LINE_SEARCH(num_iterations)

    lines = "*Controls, parameters=line search"
    lines = [lines; @sprintf "%2d, , , ," num_iterations]

    return lines

end

"""
    CONTROLS_TIME_INCREMENTATION(attempts_per_increment)

Write a `*Controls, parameters=TIME INCREMENTATION` keyword block.

Sets only the maximum number of attempts per increment; all other fields are left blank.

# Arguments
- `attempts_per_increment`: Maximum cutbacks allowed per increment

# Returns
A vector of strings forming the keyword block.
"""
function CONTROLS_TIME_INCREMENTATION(attempts_per_increment)

    lines = "*Controls, parameters=TIME INCREMENTATION"
    lines = [lines; @sprintf ", , , , , , , %2d" attempts_per_increment]

    return lines

end


"""
    DENSITY(ρ)

Write a `*Density` keyword block.

# Arguments
- `ρ`: Mass density value

# Returns
A vector of strings forming the keyword block.
"""
function DENSITY(ρ)

    lines = "*Density"
    lines = [lines; @sprintf "%9.6f," ρ]

    return lines

end


"""
    DLOAD(element_set_name, degree_of_freedom, magnitude)

Write a `*Dload` (distributed load) keyword block.

# Arguments
- `element_set_name`: Name of the element set
- `degree_of_freedom`: Load type label
- `magnitude`: Load magnitude

# Returns
A vector of strings forming the keyword block.
"""
function DLOAD(element_set_name, degree_of_freedom, magnitude)

    lines = "*Dload"
    lines = [lines; @sprintf "%s, %2d, %7.4f" element_set_name degree_of_freedom magnitude]

    return lines

end


"""
    DLOAD_GRAV(acceleration_magnitude, acceleration_direction)

Write a `*Dload` gravity load keyword block.

# Arguments
- `acceleration_magnitude`: Gravitational acceleration magnitude
- `acceleration_direction`: 3-element vector `[gx, gy, gz]` direction components

# Returns
A vector of strings forming the keyword block.
"""
function DLOAD_GRAV(acceleration_magnitude, acceleration_direction)

    lines = "*Dload"
    lines = [lines; @sprintf ", GRAV, %7.4f, %7.4f, %7.4f, %7.4f" acceleration_magnitude acceleration_direction[1] acceleration_direction[2] acceleration_direction[3]]

    return lines

end


"""
    DSLOAD(follower, constant_resultant, surface_name, load_type, load_magnitude, load_direction)
    DSLOAD(surface_name, load_type, load_magnitude)

Write a `*Dsload` (distributed surface load) keyword block.

Two methods:
- **Full form** — with follower and constant resultant flags, plus a load direction vector
- **Simple form** — surface name, load type, and scalar magnitude only

# Arguments (full form)
- `follower`: Follower force flag (`"YES"` or `"NO"`)
- `constant_resultant`: Constant resultant flag (`"YES"` or `"NO"`)
- `surface_name`: Name of the surface
- `load_type`: Load type string (e.g. `"TRVEC"`)
- `load_magnitude`: Load magnitude
- `load_direction`: 3-element vector `[nx, ny, nz]`

# Arguments (simple form)
- `surface_name`: Name of the surface
- `load_type`: Load type string (e.g. `"P"`)
- `load_magnitude`: Load magnitude

# Returns
A vector of strings forming the keyword block.
"""
function DSLOAD(follower, constant_resultant, surface_name, load_type, load_magnitude, load_direction)

    lines = @sprintf "*Dsload, follower=%s, constant resultant=%s" follower constant_resultant
    lines = [lines; @sprintf "%s, %s, %7.4f, %7.4f, %7.4f, %7.4f" surface_name load_type load_magnitude load_direction[1] load_direction[2] load_direction[3]]

    return lines

end


function DSLOAD(surface_name, load_type, load_magnitude)

    lines = "*Dsload"
    lines = [lines; @sprintf "%s, %s, %7.4f" surface_name load_type load_magnitude]

    return lines

end

"""
    DYNAMIC(application, initial_time_increment, step_time_period, minimum_time_increment, maximum_time_increment)

Write a `*Dynamic` keyword block for implicit dynamic analysis.

# Arguments
- `application`: Application type (e.g. `"QUASI-STATIC"`, `"TRANSIENT FIDELITY"`)
- `initial_time_increment`: Initial time increment
- `step_time_period`: Total step time
- `minimum_time_increment`: Minimum allowed time increment
- `maximum_time_increment`: Maximum allowed time increment

# Returns
A vector of strings forming the keyword block.
"""
function DYNAMIC(application, initial_time_increment, step_time_period, minimum_time_increment, maximum_time_increment)

    lines = @sprintf "*Dynamic, application=%s" application
    lines = [lines; @sprintf "%7.4f, %7.4f, %e, %7.4f" initial_time_increment step_time_period minimum_time_increment maximum_time_increment]

    return lines

end

"""
    DYNAMIC_EXPLICIT(step_time_period, maximum_time_increment)

Write a `*Dynamic, explicit` keyword block.

# Arguments
- `step_time_period`: Total step time
- `maximum_time_increment`: Maximum stable time increment

# Returns
A vector of strings forming the keyword block.
"""
function DYNAMIC_EXPLICIT(step_time_period, maximum_time_increment)

    lines = "*Dynamic, explicit"
    lines = [lines; @sprintf ", %7.4f, , %7.4f" step_time_period maximum_time_increment]

    return lines

end


"""
    EL_FILE(elset, variable)

Write an `*El File` keyword block to request element output to the results file.

# Arguments
- `elset`: Element set name
- `variable`: Output variable label (e.g. `"S"`, `"E"`)

# Returns
A vector of strings forming the keyword block.
"""
function EL_FILE(elset, variable)

    lines = @sprintf "*El File, elset =%s" elset
    lines = [lines; @sprintf "%s" variable]

    return lines

end


"""
    ELASTIC(E, ν)

Write a `*Elastic` keyword block for isotropic linear elasticity.

# Arguments
- `E`: Young's modulus
- `ν`: Poisson's ratio

# Returns
A vector of strings forming the keyword block.
"""
function ELASTIC(E, ν)

    lines = "*Elastic"
    lines = [lines; @sprintf "%9.6f, %9.6f" E ν]

    return lines

end

"""
    ELEMENT_SPRING(elements, type, elset)

Write an `*Element` keyword block for spring elements with an element set.

# Arguments
- `elements`: Matrix where each row is `[element_number, node_label]`
- `type`: Element type string (e.g. `"SPRINGA"`)
- `elset`: Element set name

# Returns
A vector of strings forming the keyword block.
"""
function ELEMENT_SPRING(elements, type, elset)

    lines = @sprintf "*Element, type= %s, elset= %s" type elset

    for i=1:size(elements)[1]
        lines = [lines; @sprintf "%1d, %s" elements[i, 1] elements[i, 2]]
    end

    return lines

end


"""
    ELEMENT(elements, type, nodes_per_element)
    ELEMENT(elements, type, nodes_per_element, elset_name)
    ELEMENT(element_number, node_i, node_j, type, nodes_per_element, elset_name)

Write an `*Element` keyword block.

Three methods:
- **Matrix form, no set** — writes element connectivity from a matrix; supports 2, 3, 4, 8, and 10 nodes per element
- **Matrix form, with set** — same, but adds `elset=` to the keyword line (currently supports 2-node elements)
- **Vector form, with set** — writes connector-style elements from separate node arrays

# Arguments (matrix form)
- `elements`: Matrix where column 1 is element number and columns 2–N+1 are node labels
- `type`: Element type string (e.g. `"S4R"`, `"B31"`, `"C3D8R"`)
- `nodes_per_element`: Number of nodes per element (2, 3, 4, 8, or 10)
- `elset_name`: Element set name (used in overloads that include a set)

# Arguments (vector form)
- `element_number`: Vector of element numbers
- `node_i`: Vector of first node labels
- `node_j`: Vector of second node labels

# Returns
A matrix of strings forming the keyword block.
"""
function ELEMENT(elements, type, nodes_per_element)

    lines = Matrix{String}(undef, size(elements)[1]+1, 1)

    if nodes_per_element == 4
        lines[1] = "*Element, type=" * type
        for i=1:size(elements)[1]
            lines[i+1] = @sprintf "%7d,%7d,%7d,%7d,%7d" elements[i,1] elements[i,2] elements[i,3] elements[i,4] elements[i,5]
        end
    elseif nodes_per_element == 3
        lines[1] = "*Element, type=" * type
        for i=1:size(elements)[1]
            lines[i+1] = @sprintf "%7d,%7d,%7d,%7d" elements[i,1] elements[i,2] elements[i,3] elements[i,4]
        end
    elseif nodes_per_element == 2
        lines[1] = "*Element, type=" * type
        for i=1:size(elements)[1]
            lines[i+1] = @sprintf "%7d,%7d,%7d" elements[i,1] elements[i,2] elements[i,3]
        end
    elseif nodes_per_element == 8
        lines[1] = "*Element, type=" * type
        for i=1:size(elements)[1]
            lines[i+1] = @sprintf "%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d" elements[i,1] elements[i,2] elements[i,3] elements[i,4] elements[i,5] elements[i,6] elements[i,7] elements[i,8] elements[i,9]
        end
    elseif nodes_per_element == 10
        lines[1] = "*Element, type=" * type
        for i=1:size(elements)[1]
            lines[i+1] = @sprintf "%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d" elements[i,1] elements[i,2] elements[i,3] elements[i,4] elements[i,5] elements[i,6] elements[i,7] elements[i,8] elements[i,9] elements[i,10] elements[i,11]
        end
    end

    return lines

end


function ELEMENT(elements, type, nodes_per_element, elset_name)

    lines = Matrix{String}(undef, size(elements)[1]+1, 1)

    if nodes_per_element == 2
        lines[1] = @sprintf "*Element, type=%s, elset=%s" type elset_name
        for i=1:size(elements)[1]
            lines[i+1] = @sprintf "%7d,%7d,%7d" elements[i,1] elements[i,2] elements[i,3]
        end
    end

    return lines

end


function ELEMENT(element_number, node_i, node_j, type, nodes_per_element, elset_name)

    lines = Matrix{String}(undef, size(element_number)[1]+1, 1)

    if nodes_per_element == 2
        lines[1] = @sprintf "*Element, type=%s, elset=%s" type elset_name
        for i=1:size(element_number)[1]
            lines[i+1] = @sprintf "%d,%s,%s" element_number[i] node_i[i] node_j[i]
        end
    end

    return lines

end


"""
    ELEMENT_OUTPUT(directions, fields)
    ELEMENT_OUTPUT(directions, fields, elset)

Write an `*Element Output` keyword block.

Two methods:
- **Global** — output for all elements in the model
- **Set-scoped** — output restricted to a named element set

# Arguments
- `directions`: Directions flag (`"YES"` or `"NO"`)
- `fields`: Vector of output variable strings (e.g. `["S", "E", "MISES"]`)
- `elset`: Element set name (set-scoped form only)

# Returns
A vector of strings forming the keyword block.
"""
function ELEMENT_OUTPUT(directions, fields)

    lines = @sprintf "*Element Output, directions=%s" directions

    line = ""
    for i = 1:size(fields)[1]
        if i == size(fields)[1]
            line = line * fields[i]
        else
            line = line * fields[i] * ", "
        end
    end

    lines = [lines; line]

    return lines

end

function ELEMENT_OUTPUT(directions, fields, elset)

    lines = @sprintf "*Element Output, elset=%s, directions=%s" elset directions

    line = ""
    for i in eachindex(fields)
        if i == size(fields)[1]
            line = line * fields[i]
        else
            line = line * fields[i] * ", "
        end
    end

    lines = [lines; line]

    return lines

end


"""
    ELSET(elements, name)

Write an `*Elset` keyword block, packing up to 16 element labels per line.

# Arguments
- `elements`: Vector of integer element labels
- `name`: Element set name

# Returns
A vector of strings forming the keyword block.
"""
function ELSET(elements, name)

    num_elements=size(elements)[1]

    residual = num_elements/16 - floor(Int, num_elements/16)

    if residual == 0.0
        num_rows = floor(Int, num_elements/16)
    else
        num_rows = floor(Int, num_elements/16) + 1
        elements = [elements; zeros(Int, 16 - (num_elements - (num_rows - 1) * 16))]
    end

    lines = "*Elset, elset=" * name

    for i=1:num_rows
        range_start = (i-1) * 16 + 1
        range_end = i * 16
        range = range_start:range_end
        lines = [lines; @sprintf "%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d" elements[range[1]] elements[range[2]] elements[range[3]] elements[range[4]] elements[range[5]] elements[range[6]] elements[range[7]] elements[range[8]] elements[range[9]] elements[range[10]] elements[range[11]] elements[range[12]] elements[range[13]] elements[range[14]] elements[range[15]] elements[range[16]]]
    end

    if residual != 0.0
        index = findfirst(" 0", lines[end])[1]
        lines[end] = lines[end][1:index - 7]
    end

    return lines

end


"""
    EL_PRINT(variables, elset_name)

Write an `*El Print` keyword block to request element output to the print file.

# Arguments
- `variables`: Vector of output variable strings
- `elset_name`: Element set name

# Returns
A vector of strings forming the keyword block.
"""
function EL_PRINT(variables, elset_name)

    lines = @sprintf "*El Print, elset=%s" elset_name

    line = ""
    for i in eachindex(variables)
        if i == size(variables)[1]
            line = line * variables[i]
        else
            line = line * variables[i] * ", "
        end
    end

    lines = [lines; line]

    return lines

end


"""
    EQUATION(num_of_equations, node_label_i, dof_i, magnitude_i, node_label_j, dof_j, magnitude_j)

Write an `*Equation` keyword block defining linear multi-point constraints.

Each entry in the input vectors defines one constraint equation of the form:
`magnitude_i * u(node_i, dof_i) + magnitude_j * u(node_j, dof_j) = 0`

# Arguments
- `num_of_equations`: Vector of integers — number of terms in each equation (typically 2)
- `node_label_i`: Vector of first node labels
- `dof_i`: Vector of DOF indices for first node
- `magnitude_i`: Vector of coefficients for first node
- `node_label_j`: Vector of second node labels
- `dof_j`: Vector of DOF indices for second node
- `magnitude_j`: Vector of coefficients for second node

# Returns
A vector of strings forming the keyword block.
"""
function EQUATION(num_of_equations, node_label_i, dof_i, magnitude_i, node_label_j, dof_j, magnitude_j)

    lines = "*Equation"

    for i in eachindex(node_label_i)
        lines = [lines; @sprintf "%d" num_of_equations[i]]
        lines = [lines; @sprintf "%s, %d, %7.4f, %s, %d, %7.4f" node_label_i[i] dof_i[i] magnitude_i[i] node_label_j[i] dof_j[i] magnitude_j[i]]
    end

    return lines

end


"""
    FASTENER(name, property, reference_node_set, elset, coupling, attachment_method,
             weighting_method, adjust_orientation, number_of_layers,
             radius_of_influence, projection_direction)

Write a `*Fastener` keyword block.

# Arguments
- `name`: Fastener interaction name
- `property`: Fastener property name
- `reference_node_set`: Reference node set name
- `elset`: Element set name
- `coupling`: Coupling type (e.g. `"STRUCTURAL"`)
- `attachment_method`: Attachment method (e.g. `"FREEFORM"`)
- `weighting_method`: Weighting method (e.g. `"UNIFORM"`)
- `adjust_orientation`: Adjust orientation flag (`"YES"` or `"NO"`)
- `number_of_layers`: Number of layers through thickness
- `radius_of_influence`: Radius of influence for attachment
- `projection_direction`: 3-element vector `[px, py, pz]`

# Returns
A vector of strings forming the keyword block.
"""
function FASTENER(name, property, reference_node_set, elset, coupling, attachment_method, weighting_method, adjust_orientation, number_of_layers, radius_of_influence, projection_direction)

    lines = @sprintf "*Fastener, interaction name=%s, property=%s, reference node set=%s, elset=%s, coupling=%s, attachment method=%s, weighting method=%s," name property reference_node_set elset coupling attachment_method weighting_method
    lines = [lines; @sprintf "adjust orientation=%s," adjust_orientation]
    lines = [lines; @sprintf "number of layers=%2d," number_of_layers]
    lines = [lines; @sprintf "radius of influence=%9.5f" radius_of_influence]
    lines = [lines; @sprintf "%7.4f, %7.4f, %7.4f" projection_direction[1] projection_direction[2] projection_direction[3]]

    return lines

end


"""
    FASTENER_PROPERTY(name, radius)

Write a `*Fastener Property` keyword block.

# Arguments
- `name`: Fastener property name
- `radius`: Fastener radius (punch-through radius)

# Returns
A vector of strings forming the keyword block.
"""
function FASTENER_PROPERTY(name, radius)

    lines = "*Fastener Property, name=" * name
    lines = [lines; @sprintf "%9.5f" radius]

    return lines
end


"""
    FRICTION(slip_tolerance, friction_coeff)
    FRICTION(friction_coeff)

Write a `*Friction` keyword block.

Two methods:
- **With slip tolerance** — includes the `slip tolerance=` parameter
- **Without slip tolerance** — coefficient only

# Arguments
- `slip_tolerance`: Allowable elastic slip as a fraction of characteristic element length
- `friction_coeff`: Coulomb friction coefficient

# Returns
A vector of strings forming the keyword block.
"""
function FRICTION(slip_tolerance, friction_coeff)

    lines = @sprintf "*Friction, slip tolerance=%7.5f" slip_tolerance
    lines = [lines; @sprintf "%7.5f," friction_coeff]

    return lines

end


function FRICTION(friction_coeff)

    lines = "*Friction"
    lines = [lines; @sprintf "%7.5f," friction_coeff]

    return lines

end

"""
    HEADING(heading_lines)

Write a `*Heading` keyword block.

Each entry in `heading_lines` is prefixed with `**` (Abaqus comment marker) on
the lines following the `*Heading` keyword.

# Arguments
- `heading_lines`: Vector of strings to write as heading comments

# Returns
A matrix of strings forming the keyword block.
"""
function HEADING(heading_lines)

    lines = Matrix{String}(undef, size(heading_lines)[1]+1, 1)
    lines[1] = "*Heading"

    for i in eachindex(heading_lines)
        lines[i+1] = "**" * heading_lines[i]
    end

    return lines

end


"""
    INSTANCE(instance_name, part_name, offset_coordinates)
    INSTANCE(instance_name, part_name, offset_coordinates, point_a_coordinates, point_b_coordinates, rotation_angle_a_b)

Write an `*Instance` ... `*End Instance` keyword block.

Two methods:
- **Translation only** — offset coordinates only
- **Translation + rotation** — offset plus rotation defined by an axis (point A to point B) and angle

# Arguments
- `instance_name`: Instance name
- `part_name`: Part name
- `offset_coordinates`: 3-element vector `[x, y, z]` translation offset
- `point_a_coordinates`: 3-element vector for rotation axis start point
- `point_b_coordinates`: 3-element vector for rotation axis end point
- `rotation_angle_a_b`: Rotation angle in degrees about the A→B axis

# Returns
A vector of strings forming the full instance block including `*End Instance`.
"""
function INSTANCE(instance_name, part_name, offset_coordinates)

    lines = @sprintf "*Instance, name=%s, part=%s" instance_name part_name
    lines = [lines; @sprintf "%7.4f, %7.4f, %7.4f" offset_coordinates[1] offset_coordinates[2] offset_coordinates[3]]
    lines = [lines; "*End Instance"]

    return lines

end


function INSTANCE(instance_name, part_name, offset_coordinates, point_a_coordinates, point_b_coordinates, rotation_angle_a_b)

    lines = @sprintf "*Instance, name=%s, part=%s" instance_name part_name
    lines = [lines; @sprintf "%7.4f, %7.4f, %7.4f" offset_coordinates[1] offset_coordinates[2] offset_coordinates[3]]
    lines = [lines; @sprintf "%7.4f, %7.4f, %7.4f, %7.4f, %7.4f, %7.4f, %7.4f" point_a_coordinates[1] point_a_coordinates[2] point_a_coordinates[3] point_b_coordinates[1] point_b_coordinates[2] point_b_coordinates[3] rotation_angle_a_b]
    lines = [lines; "*End Instance"]

    return lines

end


"""
    KINEMATIC_COUPLING(ref_node, node_set_name, degrees_of_freedom)

Write a `*Kinematic Coupling` keyword block.

# Arguments
- `ref_node`: Reference node number
- `node_set_name`: Name of the coupled node set
- `degrees_of_freedom`: Vector of DOF integers to couple

# Returns
A vector of strings forming the keyword block.
"""
function KINEMATIC_COUPLING(ref_node, node_set_name, degrees_of_freedom)

    lines = @sprintf "*Kinematic Coupling, ref node=%d" ref_node

    for i in eachindex(degrees_of_freedom)
        lines = [lines; @sprintf "%s, %o, " node_set_name degrees_of_freedom[i]]
    end

    return lines

end


"""
    MATERIAL(name)

Write a `*Material` keyword line.

# Arguments
- `name`: Material name

# Returns
A String (single line).
"""
function MATERIAL(name)

    lines = "*Material, name=" * name

end


"""
    NODE(nodes)

Write a `*Node` keyword block.

# Arguments
- `nodes`: Matrix with columns `[node_number, x, y, z]`

# Returns
A matrix of strings forming the keyword block.
"""
function NODE(nodes)

    lines = Matrix{String}(undef, size(nodes)[1]+1, 1)
    lines[1] = "*Node"

    for i=1:size(nodes)[1]
        lines[i+1] = @sprintf "%14d,%14.8f,%14.8f,%14.8f" nodes[i, 1] nodes[i, 2] nodes[i, 3] nodes[i, 4]
    end

    return lines

end


"""
    NODE_OUTPUT(fields)

Write a `*Node Output` keyword block.

# Arguments
- `fields`: Vector of output variable strings (e.g. `["U", "RF"]`)

# Returns
A vector of strings forming the keyword block.
"""
function NODE_OUTPUT(fields)

    lines = "*Node Output"

    line = ""
    for i in eachindex(fields)
        if i == size(fields)[1]
            line = line * fields[i]
        else
            line = line * fields[i] * ", "
        end
    end

    lines = [lines; line]

    return lines

end


"""
    NODE_PRINT(variables, nset_name)

Write a `*Node Print` keyword block to request nodal output to the print file.

# Arguments
- `variables`: Vector of output variable strings
- `nset_name`: Node set name

# Returns
A vector of strings forming the keyword block.
"""
function NODE_PRINT(variables, nset_name)

    lines = @sprintf "*Node Print, nset=%s" nset_name

    line = ""
    for i in eachindex(variables)
        if i == size(variables)[1]
            line = line * variables[i]
        else
            line = line * variables[i] * ", "
        end
    end

    lines = [lines; line]

    return lines

end

"""
    NSET(nodes, name)
    NSET(name, nset_names)

Write an `*Nset` keyword block.

Two methods:
- **From node numbers** — packs up to 16 node labels per line
- **From set names** — combines existing named sets (4 names per line)

# Arguments (node number form)
- `nodes`: Vector of integer node labels
- `name`: Node set name

# Arguments (set name form)
- `name`: Node set name
- `nset_names`: Vector of existing node set name strings to include

# Returns
A vector of strings forming the keyword block.
"""
function NSET(nodes, name)

    num_nodes=size(nodes)[1]

    residual = num_nodes/16 - floor(Int, num_nodes/16)

    if residual == 0.0
        num_rows = floor(Int, num_nodes/16)
    else
        num_rows = floor(Int, num_nodes/16) + 1
        nodes = [nodes; zeros(Int, 16 - (num_nodes - (num_rows - 1) * 16))]
    end

    lines = "*Nset, nset=" * name

    for i=1:num_rows
        range_start = (i-1) * 16 + 1
        range_end = i * 16
        range = range_start:range_end
        lines = [lines; @sprintf "%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d,%7d" nodes[range[1]] nodes[range[2]] nodes[range[3]] nodes[range[4]] nodes[range[5]] nodes[range[6]] nodes[range[7]] nodes[range[8]] nodes[range[9]] nodes[range[10]] nodes[range[11]] nodes[range[12]] nodes[range[13]] nodes[range[14]] nodes[range[15]] nodes[range[16]]]
    end

    if residual != 0.0
        index = findfirst(" 0", lines[end])[1]
        lines[end] = lines[end][1:index - 7]
    end

    return lines

end


function NSET(name, nset_names::Vector{String})

    num_sets=size(nset_names)[1]

    residual = num_sets/4 - floor(Int, num_sets/4)

    if residual == 0.0
        num_rows = floor(Int, num_sets/4)
    else
        num_rows = floor(Int, num_sets/4) + 1
        nset_names = [nset_names; fill("", 4 - (num_sets - (num_rows - 1) * 4))]
    end

    lines = "*Nset, nset=" * name

    for i=1:num_rows
        range_start = (i-1) * 4 + 1
        range_end = i * 4
        range = range_start:range_end
        lines = [lines; @sprintf "%s,%s,%s,%s" nset_names[range[1]] nset_names[range[2]] nset_names[range[3]] nset_names[range[4]]]
    end

    return lines

end


"""
    ORIENTATION(name, local_x_axis, local_y_axis)

Write an `*Orientation` keyword block (rectangular/Cartesian type).

The orientation is defined by specifying the local 1-axis and a vector in the
1–2 plane. The additional line `1, 0.` specifies a rectangular system with
no rotation about the 3-axis.

# Arguments
- `name`: Orientation name
- `local_x_axis`: 3-element vector defining the local 1-axis direction
- `local_y_axis`: 3-element vector in the local 1–2 plane

# Returns
A vector of strings forming the keyword block.
"""
function ORIENTATION(name, local_x_axis, local_y_axis)

    lines = @sprintf "*Orientation, name=%s" name
    lines = [lines; @sprintf "%9.5f, %9.5f, %9.5f, %9.5f, %9.5f, %9.5f" local_x_axis[1] local_x_axis[2] local_x_axis[3] local_y_axis[1] local_y_axis[2] local_y_axis[3]]
    lines = [lines; "1, 0."]

    return lines

end


"""
    OUTPUT(field_or_history, variable)

Write an `*Output` keyword line.

# Arguments
- `field_or_history`: Output type (`"field"` or `"history"`)
- `variable`: Variable preset (e.g. `"PRESELECT"`, `"ALL"`) — pass `""` to omit

# Returns
A String (single line).
"""
function OUTPUT(field_or_history, variable)

    if isempty(variable)
        lines = @sprintf "*Output, %s" field_or_history
    else
        lines = @sprintf "*Output, %s, variable=%s" field_or_history variable
    end

    return lines

end


"""
    OUTPUT_TIME_POINTS(field_or_history, time_points_name)

Write an `*Output` keyword line with a `TIME POINTS` reference.

# Arguments
- `field_or_history`: Output type (`"field"` or `"history"`)
- `time_points_name`: Name of the `*Time Points` table to use for output timing

# Returns
A String (single line).
"""
function OUTPUT_TIME_POINTS(field_or_history, time_points_name)

    lines = @sprintf "*Output, %s, TIME POINTS=%s" field_or_history time_points_name

    return lines

end


"""
    PART(name, node_lines, element_lines, nset_lines, elset_lines, section_lines)

Assemble a complete `*Part` ... `*End Part` keyword block.

Concatenates pre-built keyword line vectors in the correct order.

# Arguments
- `name`: Part name
- `node_lines`: Lines from [`NODE`](@ref)
- `element_lines`: Lines from [`ELEMENT`](@ref) or similar
- `nset_lines`: Lines from [`NSET`](@ref)
- `elset_lines`: Lines from [`ELSET`](@ref)
- `section_lines`: Lines from a section keyword (e.g. [`SHELL_SECTION`](@ref))

# Returns
A vector of strings forming the complete part block.
"""
function PART(name, node_lines, element_lines, nset_lines, elset_lines, section_lines)

    lines = "*Part, name=" * name
    lines = [lines; node_lines; element_lines; nset_lines; elset_lines; section_lines; "*End Part"]

    return lines

end

"""
    PLASTIC(curve)

Write a `*Plastic` keyword block for isotropic hardening.

# Arguments
- `curve`: Matrix with columns `[true_stress, true_plastic_strain]`

# Returns
A matrix of strings forming the keyword block.
"""
function PLASTIC(curve)

    lines = Matrix{String}(undef, size(curve)[1]+1, 1)
    lines[1] = "*Plastic"

    for i = 1:size(curve)[1]
        lines[i+1] = @sprintf "%9.6f, %9.6f" curve[i, 1] curve[i, 2]
    end

    return lines

end


"""
    PREPRINT(echo, model, history, contact)

Write a `*Preprint` keyword line.

# Arguments
- `echo`: Echo flag (`"YES"` or `"NO"`)
- `model`: Model echo flag (`"YES"` or `"NO"`)
- `history`: History echo flag (`"YES"` or `"NO"`)
- `contact`: Contact echo flag (`"YES"` or `"NO"`)

# Returns
A String (single line).
"""
function PREPRINT(echo, model, history, contact)

    lines = "*Preprint, echo=" * echo * ", model=" * model * ", history=" * history * ", contact=" * contact

end

"""
    RESTART(read_or_write, frequency)

Write a `*Restart` keyword line.

# Arguments
- `read_or_write`: `"read"` to read a restart file or `"write"` to write one
- `frequency`: Output frequency (every N increments)

# Returns
A String (single line).
"""
function RESTART(read_or_write, frequency)

    lines = @sprintf "*Restart, %s, frequency=%2d" read_or_write frequency

    return lines

end

"""
    RIGID_BODY(ref_node, pin_or_tie, nset_name)

Write a `*Rigid Body` keyword line.

Two methods:
- **Integer ref node** — `ref_node` is an `Int`
- **String ref node** — `ref_node` is a node set name String

# Arguments
- `ref_node`: Reference node number or node set name
- `pin_or_tie`: `"pin"` or `"tie"` constraint type
- `nset_name`: Node set name to make rigid

# Returns
A String (single line).
"""
function RIGID_BODY(ref_node, pin_or_tie, nset_name)

    lines = "*Rigid Body, ref node=" * string(ref_node) * ", " * pin_or_tie * " nset=" * nset_name

end

function RIGID_BODY(ref_node::String, pin_or_tie, nset_name)

    lines = "*Rigid Body, ref node=" * ref_node * ", " * pin_or_tie * " nset=" * nset_name

end

"""
    SHELL_SECTION(elset_name, material_name, offset, t, num_integration_points)

Write a `*Shell Section` keyword block.

# Arguments
- `elset_name`: Element set name
- `material_name`: Material name
- `offset`: Shell reference surface offset — either a `String` (e.g. `"MIDSURFACE"`) or a `Float64` fraction
- `t`: Shell thickness
- `num_integration_points`: Number of thickness integration points (typically 5 for Simpson)

# Returns
A vector of strings forming the keyword block.
"""
function SHELL_SECTION(elset_name, material_name, offset, t, num_integration_points)

    start_line = "*Shell Section, elset=" * elset_name * ", material=" * material_name * ", offset="

    if typeof(offset) == String
        lines = start_line * offset
    elseif typeof(offset) == Float64
        lines = @sprintf "%s%2.1f" start_line offset
    end

    lines = [lines; @sprintf "%7.4f,%2d" t num_integration_points]

    return lines

end

"""
    SOLID_SECTION(elset_name, material_name)

Write a `*Solid Section` keyword line.

# Arguments
- `elset_name`: Element set name
- `material_name`: Material name

# Returns
A String (single line).
"""
function SOLID_SECTION(elset_name, material_name)

    lines = "*Solid Section, elset=" * elset_name * ", material=" * material_name

    return lines

end


"""
    BEAM_SECTION(elset_name, material_name, section_type, dims, n1, n2, n3;
                 temperature=nothing, E=nothing, G=nothing, poisson=nothing)

Write a `*Beam Section` (or `*Beam General Section`) keyword block.

The `section_type` string selects the cross-section profile and determines the
content and interpretation of `dims`. Case-insensitive.

# Arguments
- `elset_name`: Element set name
- `material_name`: Material name (not used for `CHANNEL`/`HAT`)
- `section_type`: Cross-section type — one of `"BOX"`, `"PIPE"`, `"CIRC"`, `"RECT"`,
  `"HEX"`, `"TRAPEZOID"`, `"I"`, `"T"`, `"L"`, `"CHANNEL"`, `"HAT"`
- `dims`: Tuple of section dimensions (content depends on `section_type`, see below)
- `n1`, `n2`, `n3`: Components of the local beam 1-axis direction vector
- `temperature`: (kwarg) Temperature dependence flag (e.g. `"GRADIENTS"`) — omitted if `nothing`
- `E`, `G`: (kwarg) Young's and shear moduli — required for `CHANNEL` and `HAT`
- `poisson`: (kwarg) Poisson's ratio — required for `CHANNEL` and `HAT`

# Section types and `dims` content
| Type        | `dims`                                        | Description |
|-------------|-----------------------------------------------|-------------|
| `BOX`       | `(a, b, t1, t2, t3, t4)`                     | width, height, 4 wall thicknesses |
| `PIPE`      | `(r, t)`                                      | outside radius, wall thickness |
| `CIRC`      | `(r,)`                                        | radius (solid circle) |
| `RECT`      | `(a, b)`                                      | width, height (solid rectangle) |
| `HEX`       | `(d, t)`                                      | circumscribing radius, wall thickness |
| `TRAPEZOID` | `(a, b, c, d)`                                | bottom width, height, top width, top offset |
| `I`         | `(l, h, b1, b2, t1, t2, t3)`                 | dist centroid-bottom, height, bot/top flange widths, flange/web thicknesses |
| `T`         | `(b, h, l, tf, tw)`                           | flange width, total height, dist centroid-bottom, flange t, web t |
| `L`         | `(a, b, t1, t2)`                              | leg lengths, leg thicknesses |
| `CHANNEL`   | `(l, h, b1, b2, t1, t2, t3, o)`              | dist centroid-bottom, height, bot/top flange widths, flange/web t, offset |
| `HAT`       | `(l, h, b, b1, b2, t1, t2, t3)`              | dist centroid-bottom, height, total bottom width, top width, bot flange overhang, top/bot flange/inclined wall t |

# Notes
- `T` emits `section=I` with bottom flange zeroed (`b1=0`, `t1=0`) — Abaqus has no `section=T`
- `CHANNEL` and `HAT` emit `*Beam General Section` (no during-analysis integration)
- `CHANNEL` and `HAT` require keyword args `E`, `G`, and `poisson`

# Returns
A vector of strings forming the keyword block.
"""
function BEAM_SECTION(elset_name, material_name, section_type, dims, n1, n2, n3;
                      temperature=nothing, E=nothing, G=nothing, poisson=nothing)

    s = uppercase(section_type)

    line1 = "*Beam Section, elset=" * elset_name * ", material=" * material_name * ", section=" * s
    if temperature !== nothing
        line1 *= ", temperature=" * uppercase(temperature)
    end

    if s == "BOX"
        line2 = @sprintf "%g, %g, %g, %g, %g, %g" dims[1] dims[2] dims[3] dims[4] dims[5] dims[6]
    elseif s == "PIPE"
        line2 = @sprintf "%g, %g" dims[1] dims[2]
    elseif s == "CIRC"
        line2 = @sprintf "%g" dims[1]
    elseif s == "RECT"
        line2 = @sprintf "%g, %g" dims[1] dims[2]
    elseif s == "HEX"
        line2 = @sprintf "%g, %g" dims[1] dims[2]
    elseif s == "TRAPEZOID"
        line2 = @sprintf "%g, %g, %g, %g" dims[1] dims[2] dims[3] dims[4]
    elseif s == "I"
        line2 = @sprintf "%g, %g, %g, %g, %g, %g, %g" dims[1] dims[2] dims[3] dims[4] dims[5] dims[6] dims[7]
    elseif s == "T"
        b_f, h_t, l_t, tf_t, tw_t = dims
        line1 = "*Beam Section, elset=" * elset_name * ", material=" * material_name * ", section=I"
        line2 = @sprintf "%g, %g, %g, %g, %g, %g, %g" l_t h_t 0.0 b_f 0.0 tf_t tw_t
    elseif s == "L"
        line2 = @sprintf "%g, %g, %g, %g" dims[1] dims[2] dims[3] dims[4]
    elseif s == "CHANNEL" || s == "HAT"
        if any(isnothing, (E, G, poisson))
            error("BEAM_SECTION: $section_type requires keyword args E, G, and poisson")
        end
        line1 = @sprintf "*Beam General Section, elset=%s, poisson=%g, section=%s" elset_name poisson s
        if s == "CHANNEL"
            line2 = @sprintf "%g, %g, %g, %g, %g, %g, %g, %g" dims[1] dims[2] dims[3] dims[4] dims[5] dims[6] dims[7] dims[8]
        else
            line2 = @sprintf "%g, %g, %g, %g, %g, %g, %g, %g" dims[1] dims[2] dims[3] dims[4] dims[5] dims[6] dims[7] dims[8]
        end
        line3 = @sprintf "%g, %g, %g" n1 n2 n3
        line4 = @sprintf "%g, %g" E G
        return [line1; line2; line3; line4]
    else
        error("BEAM_SECTION: unsupported section type \"$section_type\"")
    end

    line3 = @sprintf "%g, %g, %g" n1 n2 n3

    return [line1; line2; line3]

end


"""
    BEAM_GENERAL_SECTION(elset_name, dims, n1, n2, n3; GammaO=0.0, GammaW=0.0)

Write a `*Beam General Section, section=GENERAL` keyword block for a generalized
cross-section defined by its section properties.

# Arguments
- `elset_name`: Element set name
- `dims`: 5-element tuple `(A, I11, I12, I22, J)`:
  - `A` — cross-sectional area
  - `I11` — moment of inertia about local 1-axis
  - `I12` — product of inertia
  - `I22` — moment of inertia about local 2-axis
  - `J` — torsional constant
- `n1`, `n2`, `n3`: Components of the local beam 1-axis direction vector
- `GammaO`: (kwarg) Sectorial moment — for open sections; omitted if 0.0
- `GammaW`: (kwarg) Warping constant — for open sections; omitted if 0.0

# Returns
A vector of strings forming the keyword block.
"""
function BEAM_GENERAL_SECTION(elset_name, dims, n1, n2, n3; GammaO=0.0, GammaW=0.0)

    A, I11, I12, I22, J = dims

    line1 = "*Beam General Section, elset=" * elset_name * ", section=GENERAL"

    if GammaO == 0.0 && GammaW == 0.0
        line2 = @sprintf "%g, %g, %g, %g, %g" A I11 I12 I22 J
    else
        line2 = @sprintf "%g, %g, %g, %g, %g, %g, %g" A I11 I12 I22 J GammaO GammaW
    end

    line3 = @sprintf "%g, %g, %g" n1 n2 n3

    return [line1; line2; line3]

end


"""
    BEAM_ARBITRARY_SECTION(elset_name, material_name, nodes, thicknesses, n1, n2, n3)

Write a `*Beam Section, section=ARBITRARY` keyword block for an open thin-walled
section defined by node coordinates and wall thicknesses.

# Arguments
- `elset_name`: Element set name
- `material_name`: Material name
- `nodes`: `(n_seg+1) × 2` matrix of `(x1, x2)` coordinates in the local cross-section plane
- `thicknesses`: Vector of `n_seg` wall thicknesses, one per segment
- `n1`, `n2`, `n3`: Components of the local beam 1-axis direction vector

# Returns
A vector of strings forming the keyword block.
"""
function BEAM_ARBITRARY_SECTION(elset_name, material_name, nodes, thicknesses, n1, n2, n3)

    n_seg = length(thicknesses)
    @assert size(nodes, 1) == n_seg + 1 "BEAM_ARBITRARY_SECTION: need n_seg+1=$(n_seg+1) nodes, got $(size(nodes,1))"

    line1 = "*Beam Section, elset=" * elset_name * ", material=" * material_name * ", section=ARBITRARY"

    first_line = @sprintf "%d, %g, %g, %g, %g, %g" n_seg nodes[1,1] nodes[1,2] nodes[2,1] nodes[2,2] thicknesses[1]
    rest_lines  = [@sprintf "%g, %g, %g" nodes[i+1,1] nodes[i+1,2] thicknesses[i] for i in 2:n_seg]
    line_orient = @sprintf "%g, %g, %g" n1 n2 n3

    return [line1; first_line; rest_lines; line_orient]

end


"""
    SPRING(elset, dof, stiffness)

Write a `*Spring` keyword block for a linear spring element.

# Arguments
- `elset`: Element set name
- `dof`: Degree of freedom (written twice as `dof, dof` per Abaqus format)
- `stiffness`: Spring stiffness value

# Returns
A vector of strings forming the keyword block.
"""
function SPRING(elset, dof, stiffness)

    lines = @sprintf "*Spring, elset=%s" elset
    lines = [lines; @sprintf "%1d, %1d" dof dof]
    lines = [lines; @sprintf "%7.4f" stiffness]

    return lines

end


"""
    STATIC(stabilize, allsdtol, continue_flag, initial_time_increment,
           step_time_period, minimum_time_increment, maximum_time_increment)

Write a `*Static` keyword block with automatic stabilization.

# Arguments
- `stabilize`: Stabilization factor
- `allsdtol`: Allowable stabilization-to-strain-energy ratio
- `continue_flag`: Continue flag string (`"YES"` or `"NO"`)
- `initial_time_increment`: Initial time increment
- `step_time_period`: Total step time
- `minimum_time_increment`: Minimum time increment
- `maximum_time_increment`: Maximum time increment

# Returns
A vector of strings forming the keyword block.
"""
function STATIC(stabilize, allsdtol, continue_flag, initial_time_increment, step_time_period, minimum_time_increment, maximum_time_increment)

    lines = @sprintf "*Static, stabilize=%7.5f, allsdtol=%7.5f, continue=%s" stabilize allsdtol continue_flag
    lines = [lines; @sprintf "%7.4f,%7.4f, %7.4E,%7.4f" initial_time_increment step_time_period minimum_time_increment maximum_time_increment]

end


"""
    STEP(name, nlgeom, inc::Int)
    STEP(name, nlgeom, perturbation::String)
    STEP(name, nlgeom, inc::Int, convert_SDI)
    STEP(name, nlgeom)

Write a `*Step` keyword line.

Four methods covering common step configurations:
- **With increment limit** — `inc=` set to an integer maximum increment count
- **With perturbation** — for linear perturbation steps (e.g. `"perturbation"`)
- **With increment limit and SDI conversion** — adds `convert SDI=` option
- **Minimal form** — name and nlgeom only

# Arguments
- `name`: Step name
- `nlgeom`: Geometric nonlinearity flag (`"YES"` or `"NO"`)
- `inc`: Maximum number of increments (Int)
- `perturbation`: Perturbation keyword string (String)
- `convert_SDI`: SDI conversion flag (`"YES"` or `"NO"`)

# Returns
A String (single line).
"""
function STEP(name, nlgeom, inc::Int)

    lines = @sprintf "*Step, name=%s, nlgeom=%s, inc=%16d" name nlgeom inc

end

function STEP(name, nlgeom, perturbation::String)

    lines = @sprintf "*Step, name=%s, nlgeom=%s, %s" name nlgeom perturbation

end

function STEP(name, nlgeom, inc::Int, convert_SDI)

    lines = @sprintf "*Step, name=%s, nlgeom=%s, inc=%16d, convert SDI=%s" name nlgeom inc convert_SDI

end

function STEP(name, nlgeom)

    lines = @sprintf "*Step, name=%s, nlgeom=%s" name nlgeom

end

"""
    SURFACE(surface_type, surface_name, elset_name, surface_face::String)
    SURFACE(surface_type, surface_name, nset_name, node_area_factor::Float64)

Write a `*Surface` keyword block.

Two methods:
- **Element-based** — shell element surface defined by element set and face label (e.g. `"S1"`)
- **Node-based** — node set surface with an area factor

# Arguments (element-based)
- `surface_type`: Surface type string (e.g. `"ELEMENT"`)
- `surface_name`: Surface name
- `elset_name`: Element set name
- `surface_face`: Face label string (e.g. `"SPOS"`, `"S1"`)

# Arguments (node-based)
- `surface_type`: Surface type string (e.g. `"NODE"`)
- `surface_name`: Surface name
- `nset_name`: Node set name
- `node_area_factor`: Area factor per node

# Returns
A vector of strings forming the keyword block.
"""
function SURFACE(surface_type, surface_name, elset_name, surface_face::String)

    lines = @sprintf "*Surface, type=%s, name=%s" surface_type surface_name
    lines = [lines; @sprintf "%s, %s" elset_name surface_face]

    return lines

end

function SURFACE(surface_type, surface_name, nset_name, node_area_factor::Float64)

    lines = @sprintf "*Surface, type=%s, name=%s" surface_type surface_name
    lines = [lines; @sprintf "%s, %7.4f" nset_name node_area_factor]

    return lines

end


"""
    SURFACE_BEHAVIOR(pressure_overclosure)

Write a `*Surface Behavior` keyword line.

# Arguments
- `pressure_overclosure`: Pressure-overclosure model (e.g. `"HARD"`, `"EXPONENTIAL"`)

# Returns
A String (single line).
"""
function SURFACE_BEHAVIOR(pressure_overclosure)

    lines = @sprintf "*Surface Behavior, pressure-overclosure=%s" pressure_overclosure

    return lines

end


"""
    SURFACE_INTERACTION(name, surface_out_of_plane_thickness)

Write a `*Surface Interaction` keyword block.

# Arguments
- `name`: Surface interaction name (quoted in output)
- `surface_out_of_plane_thickness`: Out-of-plane thickness for 2D or shell surfaces

# Returns
A vector of strings forming the keyword block.
"""
function SURFACE_INTERACTION(name, surface_out_of_plane_thickness)

    lines = @sprintf "*Surface Interaction, name=\"%s\"" name
    lines = [lines; @sprintf "%7.5f," surface_out_of_plane_thickness]

    return lines

end


"""
    TIE(name, master_surface, slave_surface, adjust)

Write a `*Tie` keyword block.

# Arguments
- `name`: Tie constraint name
- `master_surface`: Master surface name
- `slave_surface`: Slave surface name
- `adjust`: Adjust flag (`"YES"` or `"NO"`)

# Returns
A vector of strings forming the keyword block.
"""
function TIE(name, master_surface, slave_surface, adjust)

    lines = @sprintf "*Tie, name=%s, ADJUST=%s" name adjust
    lines = [lines; @sprintf "%s, %s" slave_surface master_surface]

    return lines

end


"""
    TIME_POINTS(name, points)

Write a `*TIME POINTS` keyword block.

# Arguments
- `name`: Time points table name
- `points`: Vector of time values at which output is requested

# Returns
A vector of strings forming the keyword block.
"""
function TIME_POINTS(name, points)

    lines = @sprintf "*TIME POINTS, name=%s" name

    for i in eachindex(points)
        lines = [lines; @sprintf "%9.5f" points[i]]
    end

    return lines

end


"""
    UEL_PROPERTY_DING_CONNECTOR(elset, inputs, dof)

Write a `*UEL property` keyword block for the DING connector user element.

The `inputs` named tuple must contain the following fields:

**Backbone curve:**
- `strain1p`–`strain4p`, `strain1n`–`strain4n`: Positive/negative backbone strain points
- `stress1p`–`stress4p`, `stress1n`–`stress4n`: Corresponding stress points

**Pinching/residual:**
- `rDispP`, `rForceP`, `uForceP`: Positive residual displacement, force, and unloading force
- `rDispN`, `rForceN`, `uForceN`: Negative equivalents

**Degradation:**
- `gammaK1`–`gammaK4`, `gammaKLimit`: Stiffness degradation parameters
- `gammaD1`–`gammaD4`, `gammaDLimit`: Deformation-based degradation parameters
- `gammaF1`–`gammaF4`, `gammaFLimit`: Force-based degradation parameters

**Other:**
- `d`: Displacement/strain history parameter
- `dmgtype`: Damage accumulation type — `"energy"` or `"cycle"`
- `gE`: Energy-based damage parameter

# Arguments
- `elset`: Element set name
- `inputs`: Named tuple with fields listed above
- `dof`: 2-element vector of active DOF numbers

# Returns
A vector of strings forming the keyword block.
"""
function UEL_PROPERTY_DING_CONNECTOR(elset, inputs, dof)

    (; d,
    dmgtype,
    strain1p, strain2p, strain3p, strain4p,
    strain1n, strain2n, strain3n, strain4n,
    stress1p, stress2p, stress3p, stress4p,
    stress1n, stress2n, stress3n, stress4n,
    rDispP, rForceP, uForceP,
    rDispN, rForceN, uForceN,
    gammaK1, gammaK2, gammaK3, gammaK4, gammaKLimit,
    gammaD1, gammaD2, gammaD3, gammaD4, gammaDLimit,
    gammaF1, gammaF2, gammaF3, gammaF4, gammaFLimit,
    gE) = inputs

    if dmgtype == "energy"
        dmgtype_key = 0
    elseif dmgtype == "cycle"
        dmgtype_key = 1
    end

    lines = @sprintf "*UEL property, elset = %s" elset
    lines = [lines; @sprintf "%9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e" strain1p strain2p strain3p strain4p stress1p stress2p stress3p stress4p]
    lines = [lines; @sprintf "%9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e" strain1n strain2n strain3n strain4n stress1n stress2n stress3n stress4n]
    lines = [lines; @sprintf "%9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e" rDispP rForceP uForceP rDispN rForceN uForceN gammaK1 gammaK2]
    lines = [lines; @sprintf "%9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e" gammaK3 gammaK4 gammaKLimit gammaD1 gammaD2 gammaD3 gammaD4 gammaDLimit]
    lines = [lines; @sprintf "%9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %9.6e, %d, %d" gammaF1 gammaF2 gammaF3 gammaF4 gammaFLimit gE dmgtype_key dof[1]]
    lines = [lines; @sprintf "%d" dof[2]]

    return lines

end


"""
    USER_ELEMENT(num_nodes, type, properties, coordinates, variables, dof)

Write a `*USER Element` keyword block for a user-defined element.

# Arguments
- `num_nodes`: Number of nodes in the element
- `type`: User element type label (e.g. `"U1"`)
- `properties`: Number of element properties
- `coordinates`: Number of coordinates per node
- `variables`: Number of solution-dependent state variables
- `dof`: 2-element vector of active DOF numbers

# Returns
A vector of strings forming the keyword block.
"""
function USER_ELEMENT(num_nodes, type, properties, coordinates, variables, dof)

    lines = @sprintf "*USER Element, nodes=%d, type=%s, properties=%d, coordinates=%d, variables=%d" num_nodes type properties coordinates variables
    lines = [lines; @sprintf "%d, %d" dof[1] dof[2]]

    return lines

end


end #module
