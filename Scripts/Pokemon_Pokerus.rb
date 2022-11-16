#===============================================================================
# Pokérus condition of Pokémon.
#===============================================================================
class Pokemon
  class Pokerus
    # Stage of Pokerus infection
    # 0 (not infected), 1 (infected), 2 (cured), and 3 (perished)
    attr_reader :stage
    # Is the infection dangerous
    attr_reader :plague
    # Strain of infection
    # 0 (very long), 1 (long), 2 (medium), 3 (short), and 4 (very short)
    attr_reader :strain
    # Steps remaining in current stage
    attr_reader :step

    # Generates a pokérus state
    def initialize
      @stage   = 0
      @plague = false
      @strain   = 0
      @step = 0
    end
      
    def givePokerus(strain = -1, seed = 5)
      @strain = strain
      @strain = rand(3...4) if strain < 0 || strain >= 16
      
      step = seed * 6 - strain
    end
      
    def givePlague(strain = -1, seed = 5)
      @strain = strain
      @strain = rand(0...4) if strain < 0 || strain >= 16
      
    end
      
    def decreaseStep
      step -= 1
    end
    
  end
end