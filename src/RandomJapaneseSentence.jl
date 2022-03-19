module RandomJapaneseSentence

# TODO: parse sentences to table

"""
to_data_dir makes a valid path to data file
"""
to_data_dir(data_name) = joinpath([@__DIR__,"..","data",data_name])

const TATOEBA_FILE  = to_data_dir("tatoeba_EN_JP.tsv")
const TANAKA_C_FILE = to_data_dir("tanaka_corpus.txt")

abstract type ExampleParser end

export TatoebaParser, TanakaParser
struct TatoebaParser <: ExampleParser end
struct TanakaParser <: ExampleParser end

const Lines = Vector{<:AbstractString}

function get_sentences(expa::ExampleParser, file::AbstractString)
    @assert isfile(file) "$file should be a file"

    lines = readlines(file)
    # filter_lines!(lines, expa)
    # parsed = parse_line.(Ref(expa), lines)
    return parse_lines(expa, lines)
end

abstract type SentencePair end
struct TatoebaPair{T<:AbstractString} <: SentencePair 
    english::T
    japanese::T
    english_id::Int64
    japanese_id::Int64
end

struct TanakaPair{T<:AbstractString} <: SentencePair 
    english::T
    japanese_a::T
    japanese_b::T
    id::Int64
end

function parse_lines(tp::TatoebaParser, lines::Lines)
    parsed = TatoebaPair{eltype(lines)}[]
    for line in lines
        en_id, en, jp_id, jp = string.(split(line, '\t'))
        push!(parsed, TatoebaPair(en,jp,
                                 parse(Int64,filter(isdigit,en_id)), 
                                 parse(Int64,filter(isdigit,jp_id))
                                )
             )
    end
    return parsed
end

function parse_lines(tp::TanakaParser, lines::Lines)
    parsed = TanakaPair{eltype(lines)}[]
    for nrow in 1:2:length(lines)
        aline = lines[nrow][4:end]
        jp_b = lines[nrow+1][4:end]

        jp_a, en, id = string.(split(aline, ('#','\t')))
        
        num_id = parse(Int64, filter(isdigit,id))
        push!(parsed, TanakaPair(en, jp_a, jp_b, num_id))
    end
    return parsed
end



end # module
