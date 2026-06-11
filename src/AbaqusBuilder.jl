"""
    AbaqusBuilder

Julia package for programmatically generating Abaqus finite-element input files
and post-processing results.

# Submodules
- `Keyword` — write `*Keyword` blocks for Abaqus `.inp` files (90+ functions)
- `Mesh` — read node and element data from mesh files
- `IO` — parse Abaqus output files (`.sta`, `.dat`, nodal output)
- `Scripts` — generate Abaqus CAE Python scripts and macros
"""
module AbaqusBuilder

include("Keyword.jl")
using .Keyword

include("Mesh.jl")
using .Mesh

include("IO.jl")
using .IO

include("Scripts.jl")
using .Scripts

# Re-export all public symbols so users can call AbaqusBuilder.BOUNDARY etc.
# and Documenter.jl can collect everything under one module.
using .Keyword: AMPLITUDE, BOUNDARY, BUCKLE, CLOAD, CONN3D2,
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

using .Mesh: get_nodes_from_file, get_elements_from_file
export get_nodes_from_file, get_elements_from_file

using .IO: write_file, parse_nodal_output, get_number_of_steps_in_analysis,
    get_nodal_output, write_model_qsub_batch_file, get_sta,
    get_buckling_loads_from_dat
export write_file, parse_nodal_output, get_number_of_steps_in_analysis,
    get_nodal_output, write_model_qsub_batch_file, get_sta,
    get_buckling_loads_from_dat

using .Scripts: generate_shell_mesh_from_stp_file, grab_connector_forces_from_odb,
    write_mesh_bash_script, write_ding_connector_uel_f_file, write_update_inp_macro
export generate_shell_mesh_from_stp_file, grab_connector_forces_from_odb,
    write_mesh_bash_script, write_ding_connector_uel_f_file, write_update_inp_macro

end # module AbaqusBuilder
