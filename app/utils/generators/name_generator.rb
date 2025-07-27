# Generates randomized names.
# @attr [Array[String]] name_parts - The substrings to generate a name from
class NameGenerator
    class << self
        attr_accessor :name_parts
    end

    @name_parts = []

    # Sanitizes a name by reducing repeated characters.
    # @private
    # @param [String] name - The name to sanitize
    # @return [String] name - The sanitized name
    def self.sanitize_name name
        name = name.downcase

        sanitized_name = ''

        name.chars.each_with_index do |ch, i|
            if i > 0
                next if ch == 'a' and name[i - 1] == 'a'
                next if ch == 'i' and name[i - 1] == 'i'
                next if ch == 'u' and name[i - 1] == 'u'
            end

            if i > 1
                next if ch == 'e' and name[i - 1] == 'e' and name[i - 2] == 'e'
                next if ch == 'o' and name[i - 1] == 'o' and name[i - 2] == 'o'
            end

            sanitized_name = sanitized_name + ch
        end

        sanitized_name
    end

    # Generates a randomized name.
    # @return [String] The randomized name
    def self.generate_name
        parts = []
        Array.new(rand(1) + 2) do
            parts << @name_parts.sample
        end
        (sanitize_name(parts.join)).capitalize
    end

    # Generates a randomized full name.
    # @param [Boolean] include_middle - Generate a middle name (default: false)
    # @return [String] The randomized full name
    def self.generate_full_name include_middle=false
        return [ generate_name, generate_name ].join(' ') if not include_middle
        [ generate_name, generate_name, generate_name ].join(' ')
    end

    # Logs all possible names to an output file ('output.txt').
    # NOTE: This is primarily for debugging purposes.
    # @return [void]
    def self.log_all_possible_names
        File.open('output.txt', 'w') do |file|
            @name_parts.each do |a|
                @name_parts.each do |b|
                    file.puts((sanitize_name([ a, b ].join(' '))).capitalize)
                    @name_parts.each do |c|
                        file.puts((sanitize_name([ a, b, c ].join(' '))).capitalize)
                    end
                end
            end
        end
    end
end

# Generates randomized dwarf names.
class DwarfNameGenerator < NameGenerator
    @name_parts = [
        'te', 'moc',
        'to', 'bor',
        'en', 'arc',
        'dal', 'las',
        'col', 'lin',
        'mit', 'of', 'the', 'so', 'uth' # UTD: MIT of the South!
    ]
end

# Generates randomized goblin names.
class GoblinNameGenerator < NameGenerator
    @name_parts = [
        'tor', 'bjorn',
        'as', 'orc',
        'orx', 'slo',
        'ork', 'baa',
        'ax', 'agz',
        'asb','asp',
        'was', 'kiz',
        'cra', 'grak',
        'prag', 'lak',
        'tam', 'zink',
        'sreg', 'lux',
        'te', 'moc',
        'to', 'bor',
        'en', 'arc',
        'dal', 'las',
        'col', 'lin',
        'mit', 'of', 'the', 'so', 'uth' # UTD: MIT of the South!
    ]
end
