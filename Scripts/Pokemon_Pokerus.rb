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
    # 0 (very short) ... 15 (very long)
    attr_reader :strain
    # Steps remaining in current stage
    attr_reader :step
    # Steps remaining in asymptomatic stage
    attr_reader :incubation

    # Generates a pokérus state
    def initialize
      @stage   = 0
      @plague = false
      @strain   = 0
      @step = 0
      @incubation = 0
    end
      
    def givePokerus(strain)
      @strain = strain

      if @strain < 0 || @strain >= 16
        @strain = rand(1...16)
      end

      @plague = false
      @step = @strain * 100
      @incubation = @strain * 10
      @stage = 1
    end
      
    def givePlague(strain)
      @strain = strain

      if @strain < 0 || @strain >= 16
        @strain = rand(1...16) 
        adjust = (Settings::PLAGUE_CHANCE / 1000).ceil()

        @strain = ((@strain + adjust) / 2).ceil()
      end

      @plague = true
      @step = @strain * 100
      @incubation = @strain * 10
      @stage = 1
    end

    def severity()
      if @strain == 0 || @strain == 2 || !@plague
        # Return perfect condition if safe strain, or if not infected/cured
        return 1
      else
        # Return percentage of symptomatic time remaining
        return (@step / (@strain * 100.0))
      end
    end

    def reset()
      @step = @strain * 100
      @incubation = @strain * 10
    end

    def cure()
      if stage == 1 && stage == 3
        stage = 2
      end

      @step = 0
      @incubation = 0
    end

    def clear()
      @stage   = 0
      @plague = false
      @strain   = 0
      @step = 0
      @incubation = 0
    end
      
    def decreaseStep(count)
      return if @stage != 1

      if @incubation > 0
        @incubation -= count

        if @incubation < 0
          count += @incubation
          @incubation = 0
        end
      end

      if @step > 0 && @incubation == 0
        @step -= count
      end

      if @step <= 0 && @incubation == 0
        if @plague
          @stage = 3
        else
          @stage = 2
        end
      end
    end

    def symptomatic()
      return ((@stage == 1 && @incubation <= 0) || @stage == 3)
    end
    
  end
end