module Scripts

using ReadWriteFind, Printf

export generate_shell_mesh_from_stp_file, grab_connector_forces_from_odb,
       write_mesh_bash_script, write_ding_connector_uel_f_file,
       write_update_inp_macro

"""
    generate_shell_mesh_from_stp_file(stp_source_path, stp_source_filename,
        job_name, save_path, seed_size, stp_stitch_tolerance,
        maximum_deviation_factor, minimum_size_control_fraction)

Generate an Abaqus CAE Python meshing script for a shell model from a STEP file.

Reads the base script template from `assets/base_mesh_script_general.py`,
appends the call with the provided parameters, and writes the result to
`joinpath(save_path, job_name * ".py")`.

# Arguments
- `stp_source_path`: Directory containing the `.stp` file
- `stp_source_filename`: Filename of the `.stp` geometry file
- `job_name`: Abaqus job name; also used as the output `.py` filename stem
- `save_path`: Directory where the generated script is saved
- `seed_size`: Global mesh seed size
- `stp_stitch_tolerance`: Geometry stitch tolerance for STEP import
- `maximum_deviation_factor`: Max deviation factor for mesh quality
- `minimum_size_control_fraction`: Min element size as a fraction of seed size
"""
function generate_shell_mesh_from_stp_file(stp_source_path, stp_source_filename, job_name, save_path, seed_size, stp_stitch_tolerance, maximum_deviation_factor, minimum_size_control_fraction)

    function_file_source = joinpath(@__DIR__, "assets/base_mesh_script_general.py")

    part_name = "general_part"
    instance_name = "general_part-1"

    function_lines = ReadWriteFind.read_text_file(function_file_source)

    stp_filename = joinpath(stp_source_path, stp_source_filename)

    call_lines = ["stp_filename = '$stp_filename'"; "job_name = '$job_name'"; "part_name = '$part_name'"; "instance_name = '$instance_name'"; "seed_size = $seed_size"; "stp_stitch_tolerance = $stp_stitch_tolerance"; "maximum_deviation_factor = $maximum_deviation_factor"; "minimum_size_control_fraction = $minimum_size_control_fraction"; "MeshPart(stp_filename, job_name, part_name, instance_name, seed_size, stp_stitch_tolerance, maximum_deviation_factor, minimum_size_control_fraction)"]

    lines = [function_lines; call_lines]

    save_filename = joinpath(save_path, job_name * ".py")
    ReadWriteFind.write_file(save_filename, lines)

end

"""
    grab_connector_forces_from_odb(odb_source_path, odb_source_filename,
        output_save_path, output_save_filename, macro_name, macro_save_path)

Generate an Abaqus CAE Python macro that extracts connector forces from an `.odb` file.

Reads the base script from `assets/get_connector_macro_general.py`, appends
the call, and saves the macro to `joinpath(macro_save_path, macro_name * ".py")`.

# Arguments
- `odb_source_path`: Directory containing the `.odb` results file
- `odb_source_filename`: Filename of the `.odb` file
- `output_save_path`: Directory where extracted force data will be written
- `output_save_filename`: Filename for the extracted force output
- `macro_name`: Name stem for the generated `.py` macro file
- `macro_save_path`: Directory where the macro is saved
"""
function grab_connector_forces_from_odb(odb_source_path, odb_source_filename, output_save_path, output_save_filename, macro_name, macro_save_path)

    function_file_source = joinpath(@__DIR__, "assets/get_connector_macro_general.py")

    function_lines = ReadWriteFind.read_text_file(function_file_source)

    odb_filename = joinpath(odb_source_path, odb_source_filename)

    output_filename = joinpath(output_save_path, output_save_filename)

    call_lines = ["odb_filename = '$odb_filename'"; "output_filename = '$output_filename'"; "get_connector_forces(odb_filename, output_filename)"]

    lines = [function_lines; call_lines]

    save_filename = joinpath(macro_save_path, macro_name * ".py")
    ReadWriteFind.write_file(save_filename, lines)

end


"""
    write_mesh_bash_script(all_filenames, script_filename)

Write a bash script that runs each `.py` mesh script via `abaqus cae noGUI=`.

One `abaqus cae noGUI=<name>.py` line is written per entry in `all_filenames`.
The script is saved to `joinpath(@__DIR__, script_filename)`.

# Arguments
- `all_filenames`: Vector of `.py` filenames (with extension)
- `script_filename`: Output bash script filename (relative to `src/`)
"""
function write_mesh_bash_script(all_filenames, script_filename)

    lines = []

    for i in eachindex(all_filenames)

        push!(lines, "abaqus cae noGUI=" * all_filenames[i][1:end-2] * ".py")

    end

    filename = joinpath(@__DIR__, script_filename)
    ReadWriteFind.write_file(filename, lines)

end


"""
    write_ding_connector_uel_f_file(save_path, filename, uel_output_path,
        KPNT, KSEC, KORIENT, KOUTPUT)

Patch the DING connector UEL Fortran template with runtime parameters and save it.

Reads `assets/DING_connector_UEL.f`, replaces the `FILEPATH`, `KPNT`, `KSEC`,
`KORIENT`, and `KOUTPUT` parameter lines with the supplied values, and writes
the result to `joinpath(save_path, filename)`.

# Arguments
- `save_path`: Output directory
- `filename`: Output `.f` filename
- `uel_output_path`: Path string inserted as the `FILEPATH` Fortran parameter
- `KPNT`: Number of section points
- `KSEC`: Section integration flag
- `KORIENT`: Orientation flag
- `KOUTPUT`: Output flag
"""
function write_ding_connector_uel_f_file(save_path, filename, uel_output_path, KPNT, KSEC, KORIENT, KOUTPUT)

    function_file_source = joinpath(@__DIR__, "assets/DING_connector_UEL.f")

    lines = ReadWriteFind.read_text_file(function_file_source)

    target_string = "PARAMETER (FILEPATH"
    index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)
    lines[index] = "      PARAMETER (FILEPATH = '$uel_output_path')"

    target_string = "KPNT = 3"
    index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)
    lines[index] = @sprintf"      KPNT = %s" string(KPNT)

    target_string = "KSEC = 0"
    index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)
    lines[index] = @sprintf"      KSEC = %s" string(KSEC)

    target_string = "KORIENT = 1"
    index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)
    lines[index] = @sprintf"      KORIENT = %s" string(KORIENT)

    target_string = "KOUTPUT = 1"
    index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)
    lines[index] = @sprintf"      KOUTPUT = %s" string(KOUTPUT)

    save_filename = joinpath(save_path, filename)
    ReadWriteFind.write_file(save_filename, lines)

end


"""
    write_update_inp_macro(model_name, model_remote_path_and_filename,
        save_path, save_filename)

Generate an Abaqus CAE Python macro that updates an `.inp` file in a CAE model.

Reads `assets/update_inp_file.py`, appends the call with `model_name` and
the full remote path to the `.inp` file, and saves to
`joinpath(save_path, save_filename)`.

# Arguments
- `model_name`: CAE model name to update
- `model_remote_path_and_filename`: Full path (including filename) to the `.inp` file
- `save_path`: Directory where the macro is saved
- `save_filename`: Output `.py` filename
"""
function write_update_inp_macro(model_name, model_remote_path_and_filename, save_path, save_filename)

    function_file_source = joinpath(@__DIR__, "assets/update_inp_file.py")

    lines = ReadWriteFind.read_text_file(function_file_source)

    call_lines = ["model_name = '$model_name'"; "path_with_filename = '$model_remote_path_and_filename'"; "updateinp(model_name, path_with_filename)"]

    lines = [lines; call_lines]

    save_path_and_filename = joinpath(save_path, save_filename)
    ReadWriteFind.write_file(save_path_and_filename, lines)

end

end  #module
