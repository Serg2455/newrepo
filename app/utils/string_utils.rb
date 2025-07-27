# Titleizes a given string (e.g. "hello world" => "Hello World")
# @param [String] str - The string to titleize
# @return [String] The titleized string
def titleize str
    str.split.map { |word| word.capitalize }.join(' ')
end

# Determines whether a given character is a vowel.
# @param [Char] ch - The given character
# @return [Boolean] true if vowel; false otherwise
def vowel? ch
    # Sanitizes character
    ch = ch.downcase
    
    # The character is a vowel
    return true if ch == 'a'
    return true if ch == 'e'
    return true if ch == 'i'
    return true if ch == 'o'
    return true if ch == 'u'

    # The character is not a vowel
    return false
end

# Word wraps a given string.
# @param [String] str - The string to word wrap
# @param [Integer] max_line_length - The maximum length of each line
# @return [Array[String]] - The word wrapped lines
def word_wrap str, max_line_length
    words = str.split
    lines = []
    current_line = ''

    words.each do |word|
        if current_line.empty?
            current_line = word
        elsif (current_line + ' ' + word).length <= max_line_length
            current_line += ' ' + word
        else
            lines << current_line
            current_line = word
        end
    end

    lines << current_line unless current_line.empty?
    lines
end
