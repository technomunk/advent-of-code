include("utils.jl")

# Helper structs

struct Rule
    param::Union{Char,Nothing}
    op::Char
    val::Int
    target::String
end

Item = Dict{Char,Int}
ItemClass = Dict{Char,UnitRange}

totalsize(ic::ItemClass)::Int = values(ic) .|> length |> prod

function Base.parse(::Type{Rule}, s::AbstractString)::Rule
    subparts = split(s, ':')
    if length(subparts) == 1
        return Rule(nothing, ' ', 0, subparts[1])
    end
    target = subparts[2]
    if '<' ∈ subparts[1]
        param, val = split(subparts[1], '<')
        op = '<'
    else
        param, val = split(subparts[1], '>')
        op = '>'
    end
    return Rule(param[1], op, parse(Int, val), target)
end

function apply(r::Rule, i::Item)::Union{String,Nothing}
    if isnothing(r.param)
        return r.target
    end
    if r.op == '<'
        if i[r.param] < r.val
            return r.target
        end
    else
        if i[r.param] > r.val
            return r.target
        end
    end
    return nothing
end
function shrinksplit(ic::ItemClass, r::Rule)
    # returns (passing, failing) tuple
    if isnothing(r.param)
        return copy(ic), nothing
    end
    class_range = ic[r.param]
    if r.op == '<'
        if class_range[end] < r.val
            return copy(ic), nothing
        elseif class_range[1] >= r.val
            return nothing, ic
        end
        passing = copy(ic)
        passing[r.param] = class_range[1]:(r.val-1)
        failing = copy(ic)
        failing[r.param] = r.val:class_range[end]
        return passing, failing
    else  # '>'
        if class_range[1] > r.val
            return copy(ic), nothing
        elseif class_range[end] <= r.val
            return nothing, copy(ic)
        end
        passing = copy(ic)
        passing[r.param] = (r.val+1):class_range[end]
        failing = copy(ic)
        failing[r.param] = class_range[1]:r.val
        return passing, failing
    end
end
function apply(r::Rule, ic::ItemClass)
    passing, failing = shrinksplit(ic, r)
    return passing, failing, r.target
end

Workflow = Vector{Rule}

function apply(w::Workflow, i::Item)::String
    for rule in w
        result = apply(rule, i)
        if !isnothing(result)
            return result
        end
    end
end

WorkflowSet = Dict{String,Workflow}

function passes(i::Item, ws::WorkflowSet)::Bool
    step = "in"
    while step != "R" && step != "A"
        step = apply(ws[step], i)
    end
    return step == "A"
end

function passing(ic::ItemClass, ws::WorkflowSet)::Vector{ItemClass}
    result = Vector{ItemClass}()
    function passing!(ic::ItemClass, wf::Workflow)
        failing = ic
        for rule in wf
            passing, failing, step = apply(rule, failing)
            if step == "A"
                if !isnothing(passing)
                    push!(result, passing)
                end
            elseif step != "R"
                if !isnothing(passing)
                    passing!(passing, ws[step])
                end
            elseif isnothing(failing)
                break
            end
        end
    end
    passing!(ic, ws["in"])
    return result
end

Base.parse(::Type{Workflow}, s::AbstractString)::Workflow = parse.(Rule, split(s, ','))
function Base.parse(::Type{Dict{SubString,Workflow}}, s)::WorkflowSet
    result = WorkflowSet()
    for line in s
        name, wf = split(line, '{')
        result[name] = parse(Workflow, (@view wf[1:end-1]))
    end
    return result
end

function Base.parse(::Type{Item}, s::AbstractString)::Item
    result = Item()
    for elem in split((@view s[2:end-1]), ',')
        param, val = split(elem, '=')
        result[param[1]] = parse(Int, val)
    end
    return result
end

value(i::Item)::Int = values(i) |> sum

# High level solution

function solve()
    workflows, items = spliton(readlines(), "")
    workflows = parse(Dict{SubString,Workflow}, workflows)
    items = parse.(Item, items)

    # part one
    filter(i -> passes(i, workflows), items) .|> value |> sum |> println
    # part two
    class = ItemClass('x' => 1:4000, 'm' => 1:4000, 'a' => 1:4000, 's' => 1:4000)
    passing(class, workflows) .|> totalsize |> sum |> println
end


solve()
