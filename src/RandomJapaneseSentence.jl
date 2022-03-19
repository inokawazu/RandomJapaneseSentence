module RandomJapaneseSentence

# TODO: import japanese sentences English and Japanese version
# TODO: parse sentences to table

"""
to_data_dir makes a valid path to data file
"""
to_data_dir(data_name) = joinpath([@__DIR__,"..","data",data_name])

const TATOEBA_FILE  = to_data_dir("tatoeba_EN_JP.tsv")
const TANAKA_C_FILE = to_data_dir("tanaka_corpus.txt")

end # module
