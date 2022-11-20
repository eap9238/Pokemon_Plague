### Force double battles even if player only has one pokemon
class Battle
    #=============================================================================
    # Makes sure all Pokémon exist that need to. Alter the type of battle if
    # necessary. Will never try to create battler positions, only delete them
    # (except for wild Pokémon whose number of positions are fixed). Reduces the
    # size of each side by 1 and tries again. If the side sizes are uneven, only
    # the larger side's size will be reduced by 1 each time, until both sides are
    # an equal size (then both sides will be reduced equally).
    #=============================================================================
    def pbEnsureParticipants
      # Prevent battles larger than 2v2 if both sides have multiple trainers
      # NOTE: This is necessary to ensure that battlers can never become unable to
      #       hit each other due to being too far away. In such situations,
      #       battlers will move to the centre position at the end of a round, but
      #       because they cannot move into a position owned by a different
      #       trainer, it's possible that battlers will be unable to move close
      #       enough to hit each other if there are multiple trainers on both
      #       sides.
      if trainerBattle? && (@sideSizes[0] > 2 || @sideSizes[1] > 2) &&
         @player.length > 1 && @opponent.length > 1
        raise _INTL("Can't have battles larger than 2v2 where both sides have multiple trainers")
      end
      # Find out how many Pokémon each trainer has
      side1counts = pbAbleTeamCounts(0)
      side2counts = pbAbleTeamCounts(1)
      # Change the size of the battle depending on how many wild Pokémon there are
      if wildBattle? && side2counts[0] != @sideSizes[1]
        if @sideSizes[0] == @sideSizes[1]
          # Even number of battlers per side, change both equally
          @sideSizes = [side2counts[0], side2counts[0]]
        else
          # Uneven number of battlers per side, just change wild side's size
          @sideSizes[1] = side2counts[0]
        end
      end
      # Check if battle is possible, including changing the number of battlers per
      # side if necessary
      loop do
        needsChanging = false
        2.times do |side|   # Each side in turn
          next if side == 1 && wildBattle?   # Wild side's size already checked above
          sideCounts = (side == 0) ? side1counts : side2counts
          requireds = []
          # Find out how many Pokémon each trainer on side needs to have
          @sideSizes[side].times do |i|
            idxTrainer = pbGetOwnerIndexFromBattlerIndex((i * 2) + side)
            requireds[idxTrainer] = 0 if requireds[idxTrainer].nil?
            requireds[idxTrainer] += 1
          end
          # Compare the have values with the need values
          if requireds.length > sideCounts.length
            raise _INTL("Error: def pbGetOwnerIndexFromBattlerIndex gives invalid owner index ({1} for battle type {2}v{3}, trainers {4}v{5})",
                        requireds.length - 1, @sideSizes[0], @sideSizes[1], side1counts.length, side2counts.length)
          end
          sideCounts.each_with_index do |_count, i|
            if !requireds[i] || requireds[i] == 0
              case side
              when 0
                raise _INTL("Player-side trainer {1} has no battler position for their Pokémon to go (trying {2}v{3} battle)",
                            i + 1, @sideSizes[0], @sideSizes[1])
              when 1
                raise _INTL("Opposing trainer {1} has no battler position for their Pokémon to go (trying {2}v{3} battle)",
                            i + 1, @sideSizes[0], @sideSizes[1])
              end
            end
            next if requireds[i] <= sideCounts[i]   # Trainer has enough Pokémon to fill their positions
            next if sideCounts[i] >= 1 # CHANGE: Trainer 'has enough pokemon' as long as they have at least one pokemon
            if requireds[i] == 1
              raise _INTL("Player-side trainer {1} has no able Pokémon", i + 1) if side == 0
              raise _INTL("Opposing trainer {1} has no able Pokémon", i + 1) if side == 1
            end
            # Not enough Pokémon, try lowering the number of battler positions
            needsChanging = true
            break
          end
          break if needsChanging
        end
        break if !needsChanging
        # Reduce one or both side's sizes by 1 and try again
        if wildBattle?
          PBDebug.log("#{@sideSizes[0]}v#{@sideSizes[1]} battle isn't possible " +
                      "(#{side1counts} player-side teams versus #{side2counts[0]} wild Pokémon)")
          newSize = @sideSizes[0] - 1
        else
          PBDebug.log("#{@sideSizes[0]}v#{@sideSizes[1]} battle isn't possible " +
                      "(#{side1counts} player-side teams versus #{side2counts} opposing teams)")
          newSize = @sideSizes.max - 1
        end
        if newSize == 0
          raise _INTL("Couldn't lower either side's size any further, battle isn't possible")
        end
        2.times do |side|
          next if side == 1 && wildBattle?   # Wild Pokémon's side size is fixed
          next if @sideSizes[side] == 1 || newSize > @sideSizes[side]
          @sideSizes[side] = newSize
        end
        PBDebug.log("Trying #{@sideSizes[0]}v#{@sideSizes[1]} battle instead")
      end
    end
  
  end