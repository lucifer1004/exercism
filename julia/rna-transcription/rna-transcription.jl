dna_to_rna = Dict('G' => 'C', 'C' => 'G', 'T' => 'A', 'A' => 'U')

function to_rna(dna)
    map(c -> get(() -> throw(ErrorException("Invalid DNA sequence")), dna_to_rna, c), dna)
end
