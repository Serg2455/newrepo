# Generates randomized appearances.
# @attr [String] species - The species
# @attr [Array[String]] genders - The gender options
# @attr [Array[String]] hair_textures - The hair texture options
# @attr [Array[String]] hair_colors - The hair color options
# @attr [Array[String]] eye_descriptors - The eye descriptor options
# @attr [Array[String]] eye_colors - The eye color options
# @attr [Array[String]] height_descriptors - The height descriptor options
# @attr [Array[String]] skin_colors - The skin color options
# @attr [Array[String]] build_descriptors - The build descriptor options
# @attr [Array[String]] body_descriptors - The body descriptor options
class AppearanceGenerator
    class << self
        attr_accessor :species,
                      :genders,
                      :hair_textures,
                      :hair_colors,
                      :eye_descriptors,
                      :eye_colors,
                      :height_descriptors,
                      :skin_colors,
                      :build_descriptors,
                      :body_descriptors
    end
    
    @species = ''
    @genders = [ 'male', 'female' ]
    @hair_textures = []
    @hair_colors = []
    @eye_descriptors = []
    @eye_colors = []
    @height_descriptors = []
    @skin_colors = []
    @build_descriptors = []
    @body_descriptors = []

    # Generates a randomized appearance.
    # @return [String] The randomized appearance
    def self.generate_appearance
        # Samples descriptors
        gender = @genders.sample
        hair_texture = @hair_textures.sample
        hair_color = @hair_colors.sample
        eye_descriptor = @eye_descriptors.sample
        eye_color = @eye_colors.sample
        height_descriptor = @height_descriptors.sample
        skin_color = @skin_colors.sample
        build_descriptor = @build_descriptors.sample
        body_descriptor = @body_descriptors.sample

        # Defines articles
        body_article = (vowel?(height_descriptor[0]) ? 'an' : 'a')

        # Returns description
        "A #{gender} #{species} with #{hair_texture}, #{hair_color} hair, "    \
        "#{eye_descriptor}, #{eye_color} eyes, and #{body_article} "           \
        "#{height_descriptor}, #{skin_color}, and #{build_descriptor} "        \
        "#{body_descriptor}."
    end
end

# Generates randomized dwarf appearances.
# @attr [Array[String]] beard_descriptors - The beard descriptor options
class DwarfAppearanceGenerator < AppearanceGenerator
    @species = 'dwarf'
    
    @genders = [ 'male', 'female' ]

    @hair_textures = [
        'short',
        'long',
        'curly',
        'wavy',
        'spiky'
    ]

    @hair_colors = [
        'black',
        'light brown',
        'dark brown',
        'blonde',
        'red'
    ]

    @eye_descriptors = [
        'shifty',
        'sharp',
        'alert',
        'tired',
        'droopy',
        'leering',
        'bored',
        'unremarkable',
        'narrow',
        'innocent',
        'big',
        'curious',
        'inquisitive',
        'intelligent',
        'thoughtful',
        'kind'
    ]

    @eye_colors = [
        'green',
        'pale blue',
        'blue',
        'hazel',
        'gray',
        'brown',
        'dark brown',
        'almost black'
    ]
    
    @height_descriptors = [
        'very short',
        'short',
        'slightly shorter than average',
        'average-height',
        'slightly taller than average',
        'tall',
        'very tall'
    ]

    @skin_colors = [
        'pale',
        'fair-skinned',
        'olive-skinned',
        'tan',
        'light brown',
        'brown',
        'dark brown',
        'black'
    ]
    
    @build_descriptors = [
        'frail',
        'slim',
        'chubby',
        'fat',
        'muscular',
        'wide',
        'bulky',
        'heavy'
    ]
    
    @body_descriptors = [
        'build',
        'frame',
        'body'
    ]
    
    @beard_descriptors = [
        'patchy',
        'wispy',
        'neat',
        'tidy',
        'messy',
        'unkempt',
        'unimpressive',
        'sizeable',
        'thick',
        'bushy',
        'immense',
        'enormous',
        'gargantuan',
        'impressive',
        'regal'
    ]

    # Generates a randomized appearance.
    # @return [String] The randomized appearance
    def self.generate_appearance
        description = super

        # Samples descriptors
        beard_descriptor = @beard_descriptors.sample

        # Defines articles
        beard_article = (vowel?(beard_descriptor[0]) ? 'an' : 'a')

        # Defines pronoun
        pronoun = (description.include?('female') ? 'she' : 'he')

        # Returns description
        "#{description} #{pronoun.capitalize} has #{beard_article} "           \
        "#{beard_descriptor} beard."
    end
end

# Generates randomized goblin appearances.
class GoblinAppearanceGenerator < AppearanceGenerator
    @species = 'goblin'
    
    @genders = [ 'male', 'female' ]

    @hair_textures = [
        'short',
        'long',
        'curly',
        'wavy',
        'spiky'
    ]

    @hair_colors = [
        'black',
        'light brown',
        'dark brown',
        'red',
        'white',
        'blue',
        'purple',
        'green'
    ]

    @eye_descriptors = [
        'shifty',
        'sharp',
        'alert',
        'tired',
        'droopy',
        'leering',
        'bored',
        'unremarkable',
        'narrow',
        'evil',
        'big',
        'sneaky',
        'scary',
        'beady',
    ]

    @eye_colors = [
        'green',
        'pale blue',
        'blue',
        'hazel',
        'gray',
        'brown',
        'dark brown',
        'almost black',
        'red',
        'yellow'
    ]
    
    @height_descriptors = [
        'very short',
        'short',
        'slightly shorter than average',
        'average-height',
        'slightly taller than average',
        'tall',
        'very tall'
    ]

    @skin_colors = [
        'green',
        'dark green',
        'lime green',
        'almost neon green',
        'grayish green',
        'teal'
    ]
    
    @build_descriptors = [
        'frail',
        'slim',
        'chubby',
        'fat',
        'muscular',
        'wide',
        'bulky',
        'heavy'
    ]
    
    @body_descriptors = [
        'build',
        'frame',
        'body'
    ]

    # Generates a randomized appearance.
    # @return [String] The randomized appearance
    def self.generate_appearance
        description = super

        # Defines pronoun
        pronoun = (description.include?('female') ? 'she' : 'he')

        # Returns description
        "#{description} #{pronoun.capitalize} has pointy ears."
    end
end
