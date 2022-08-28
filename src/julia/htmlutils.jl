function remove_number_suffix(s::String)::String
    i::Int64 = length(s)
    while (isdigit(s[i]) || s[i] == ' ')
        i = i - 1
    end
    return s[1:i]
end