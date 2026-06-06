module Mesh

using ReadWriteFind

export get_nodes_from_file, get_elements_from_file

"""
    get_nodes_from_file(mesh_filename, start_target, end_target)

Read node coordinates from an Abaqus mesh file between two marker strings.

Searches `mesh_filename` for lines matching `start_target` and `end_target`,
then parses every line in between as a node record.

# Arguments
- `mesh_filename`: Path to the mesh text file
- `start_target`: String marking the line immediately before the node block
- `end_target`: String marking the line immediately after the node block

# Returns
A matrix of type `Union{Float64, Int64}` with columns `[node_number, x, y, z]`.
"""
function get_nodes_from_file(mesh_filename, start_target, end_target)

    lines = ReadWriteFind.read_text_file(mesh_filename)

    target_string = start_target
    start_index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)

    target_string = end_target
    end_index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)

    node_lines = lines[start_index+1:end_index-1]

    node_geometry = Matrix{Float64}(undef, (size(node_lines)[1], 3))
    node_numbers = Vector{Int64}(undef, size(node_lines)[1])

    for i in eachindex(node_lines)

        io = split(node_lines[i][1:end], " ")
        io = filter(x->x != "", io)
        node_number = parse(Int, io[1][1:end-1])
        x = parse(Float64, io[2][1:end-1])
        y = parse(Float64, io[3][1:end-1])
        z = parse(Float64, io[4])

        node_geometry[i, :] = [x, y, z]
        node_numbers[i] = node_number

    end

    nodes = Union{Float64, Int64}[node_numbers node_geometry]

    return nodes

end


"""
    get_elements_from_file(mesh_filename, start_target, end_target, nodes_per_element)

Read element connectivity from an Abaqus mesh file between two marker strings.

# Arguments
- `mesh_filename`: Path to the mesh text file
- `start_target`: String marking the line immediately before the element block
- `end_target`: String marking the line immediately after the element block
- `nodes_per_element`: Number of nodes per element (e.g. 2 for beams, 4 for quads)

# Returns
An `Int64` matrix with `nodes_per_element + 1` columns: `[element_number, node1, node2, ...]`.
"""
function get_elements_from_file(mesh_filename, start_target, end_target, nodes_per_element)

    lines = ReadWriteFind.read_text_file(mesh_filename)

    target_string = start_target
    start_index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)

    target_string = end_target
    end_index = ReadWriteFind.find_target_line_in_text_file(target_string, lines)

    lines = lines[start_index+1:end_index-1]

    elements = Matrix{Int64}(undef, (size(lines)[1], nodes_per_element + 1))

    for i in eachindex(lines)

        io = split(lines[i][1:end], " ")
        io = filter(x->x != "", io)

        for j = 1:nodes_per_element + 1

            if j == nodes_per_element + 1
                elements[i, j] = parse(Int, io[j])
            else
                elements[i, j] = parse(Int, io[j][1:end-1])
            end

        end

    end

    return elements

end


end #module
