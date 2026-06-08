module IO

using ReadWriteFind, DelimitedFiles, DataFrames

export write_file, parse_nodal_output, get_number_of_steps_in_analysis,
       get_nodal_output, write_model_qsub_batch_file, get_sta,
       get_buckling_loads_from_dat

"""
    write_file(save_filename, lines)

Write a vector of strings to a file, one line per entry. Thin wrapper over
`ReadWriteFind.write_file`.
"""
write_file(save_filename, lines) = ReadWriteFind.write_file(save_filename, lines)


"""
    parse_nodal_output(data_lines, data_width)

Parse raw Abaqus nodal-output text lines into a numeric matrix.

The first column of each line is treated as an integer (node number); all
remaining columns are parsed as `Float64`.

# Arguments
- `data_lines`: Vector of strings, each representing one node's output record
- `data_width`: Total number of columns expected per line (including node number)

# Returns
A `Matrix{Union{Float64, Int64}}` of size `(length(data_lines), data_width)`.
"""
function parse_nodal_output(data_lines, data_width)

    data = Matrix{Union{Float64, Int64}}(undef, (size(data_lines)[1], data_width))

    for i in eachindex(data_lines)
        io = split(data_lines[i][1:end], " ")
        io = filter(x->x != "", io)

        for j in eachindex(io)
            if j == 1
                data[i, j] = parse(Int, io[j])
            else
                data[i, j] = parse(Float64, io[j])
            end
        end
    end

    return data

end


"""
    get_number_of_steps_in_analysis(lines, result_type)

Count the number of output steps in an Abaqus `.dat` or `.fil` file by
searching for occurrences of `result_type` (e.g. `"N O D E   O U T P U T"`).

# Arguments
- `lines`: Vector of strings read from the output file
- `result_type`: Header string that appears once per step in the output

# Returns
Integer count of steps found.
"""
function get_number_of_steps_in_analysis(lines, result_type)

    data_type_search_name = result_type
    step_line_numbers = ReadWriteFind.find_phrase_in_string_chunk(lines, data_type_search_name)
    num_steps = length(step_line_numbers)

    return num_steps

end


"""
    get_nodal_output(lines, step_number, search_names, line_offsets, data_width, result_type)

Extract nodal output data for a specific step from an Abaqus output file.

# Arguments
- `lines`: Full vector of strings from the output file
- `step_number`: 1-based index of the step to extract
- `search_names`: Two-element vector of strings bounding the data block
- `line_offsets`: Two-element vector of integer offsets from each search string
- `data_width`: Number of columns per node record (including node number)
- `result_type`: Header string used to locate each step (e.g. `"N O D E   O U T P U T"`)

# Returns
A numeric matrix — see [`parse_nodal_output`](@ref).
"""
function get_nodal_output(lines, step_number, search_names, line_offsets, data_width, result_type)

    data_type_search_name = result_type
    step_line_numbers = ReadWriteFind.find_phrase_in_string_chunk(lines, data_type_search_name)

    string_chunk = lines[step_line_numbers[step_number]:end]
    data_lines = ReadWriteFind.get_specific_string_chunk(string_chunk, search_names[1], line_offsets[1], search_names[2], line_offsets[2])
    data = parse_nodal_output(data_lines, data_width)

    return data

end

"""
    write_model_qsub_batch_file(inp_folder, model_details, batch_filename)

Generate a batch script that calls `qsub` on every `.sub` file found in
`joinpath(inp_folder, model_details)`, then writes the script to that same directory.

# Arguments
- `inp_folder`: Root folder containing model subdirectories
- `model_details`: Subdirectory name for this model
- `batch_filename`: Name of the output batch script file
"""
function write_model_qsub_batch_file(inp_folder, model_details, batch_filename)

    file_list = readdir(joinpath(inp_folder, model_details))

    file_list_ext = [file_list[i][end-2:end] for i in eachindex(file_list)]

    index = findall(fileext -> fileext == "sub", file_list_ext)

    lines = []
    for i in eachindex(index)

        push!(lines, "qsub " * file_list[index[i]])

    end

    ReadWriteFind.write_file(joinpath(inp_folder, model_details, batch_filename), lines)

end


"""
    get_sta(filename, file_path)

Parse an Abaqus `.sta` status file into a `DataFrame`.

Skips the header rows and any unconverged increment rows (rows containing a
`U` flag). Always includes the final row of the file.

# Arguments
- `filename`: Name of the `.sta` file
- `file_path`: Directory containing the file

# Returns
A `DataFrame` with columns:
`step`, `increment`, `attempts`, `severe_discontinuity_iterations`,
`equilibrium_iterations`, `total_iterations`, `total_time`, `step_time`,
`time_increment`.
"""
function get_sta(filename, file_path)

    data = DelimitedFiles.readdlm(joinpath(file_path, filename))
    data = data[6:end-1, 1:end-3]

    index = findall(inc -> typeof(inc)==SubString{String}, data[:, 3])

    keep_index = setdiff(1:size(data)[1], index)

    if keep_index[end] != size(data)[1]
        keep_index = [keep_index; size(data)[1]]
        data[size(data)[1], 3] = parse(Int, data[size(data)[1], 3][1:end-1])
    end

    data = data[keep_index, :]

    column_names = [:step, :increment, :attempts, :severe_discontinuity_iterations, :equilibrium_iterations, :total_iterations, :total_time, :step_time, :time_increment]
    sta = DataFrame(data, column_names)

    for i=1:6
        sta[!, column_names[i]] = Vector{Int64}(sta[!, column_names[i]])
    end

    for i = 7:9
        sta[!, column_names[i]] = Vector{Float64}(sta[!, column_names[i]])
    end

    return sta

end


"""
    get_buckling_loads_from_dat(file_path, filename)

Extract buckling load multipliers (eigenvalues) from an Abaqus `.dat` file
produced by a `*Buckle` step.

# Arguments
- `file_path`: Directory containing the `.dat` file
- `filename`: Name of the `.dat` file

# Returns
A `Vector{Float64}` of eigenvalues in ascending order as reported by Abaqus.
"""
function get_buckling_loads_from_dat(file_path, filename)

    lines = ReadWriteFind.read_text_file(joinpath(file_path, filename))

    target_string = "E I G E N V A L U E    O U T P U T "
    line_index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)

    lines = lines[line_index:end]

    target_string = "                    E I G E N V A L U E    N U M B E R     1"
    line_index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)

    lines = lines[11:line_index-5]

    buckling_loads = [parse(Float64, split(lines[i])[2]) for i in eachindex(lines)]

    return buckling_loads

end

end #module
