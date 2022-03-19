module RandomJapaneseSentence

export get_japanese_english_pair_table,
       japanese,
       english

using DataFrames

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
    return parse_lines(expa, lines)
end

abstract type SentencePair end

japanese(sp::SentencePair) = sp.japanese
english(sp::SentencePair) = sp.english

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

japanese(tp::TanakaPair) = tp.japanese_a

function parse_lines(tp::TatoebaParser, lines::Lines)
    parsed = TatoebaPair{eltype(lines)}[]
    for line in lines
        jp_id, jp, en_id, en = string.(split(line, '\t'))
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

function get_japanese_english_pair_table()
    pairs = vcat(
                 get_sentences(TanakaParser(),   TANAKA_C_FILE),
                 get_sentences(TatoebaParser(),  TATOEBA_FILE)
                )
    col_names = ["english", "japanese"]
    cols = [english.(pairs), japanese.(pairs)]
    return DataFrame(cols, col_names)
end

export jap_eng_quiz
function jap_eng_quiz()
    enjp = get_japanese_english_pair_table()
    stop = false
    while !stop
        row = rand(1:nrow(enjp))
        en = enjp[row, "english"]
        jp = enjp[row, "japanese"]
        
        println("Translate from English to Japanese:")
        println("(Press 'Enter' to reveal)")
        println()
        print(jp)
        readline()
        println(en)
        println()
        print("Would you like to continue? [y]/n: ")
        response = readline()
        stop = any(==(response), ["no","n"])
    end
end

end # module
