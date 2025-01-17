# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

require File.expand_path(File.dirname(__FILE__) + '/neo')
require File.expand_path(File.dirname(__FILE__) + '/about_dice_project')
require File.expand_path(File.dirname(__FILE__) + '/about_scoring_project')

class Player
  attr_accessor :name, :total_score, :in_game

  def initialize(name)
    @name = name
    @total_score = 0
    @in_game = false
  end

  def can_enter_game?(turn_score)
    turn_score >= 300
  end
end

class GreedGame
  attr_reader :players, :dice, :winner

  def initialize(player_names)
    @players = player_names.map { |name| Player.new(name) }
    @dice = DiceSet.new
    @winner = nil
  end

  def play_turn(player, strategy = :cautious)
    turn_score = 0
    dice_count = 5

    loop do
      @dice.roll(dice_count)
      roll_score = score(@dice.values)

      if roll_score == 0
        return 0
      end

      turn_score += roll_score
      non_scoring = non_scoring_dice_count(@dice.values)
      dice_count = (non_scoring == 0) ? 5 : non_scoring

      break if strategy == :cautious || dice_count <= 2
    end

    if player.in_game || player.can_enter_game?(turn_score)
      player.in_game = true
      player.total_score += turn_score
    end

    turn_score
  end

  def non_scoring_dice_count(values)
    counts = Hash.new(0)
    values.each { |v| counts[v] += 1 }

    non_scoring = 0
    counts.each do |val, count|
      if val == 1 || val == 5
        # all 1s and 5s score
      else
        non_scoring += (count % 3)
      end
    end
    non_scoring
  end

  def game_over?
    @players.any? { |p| p.total_score >= 3000 }
  end
end

class AboutExtraCredit < Neo::Koan
  def test_player_initialization
    player = Player.new("Kirill")
    assert_equal "Kirill", player.name
    assert_equal 0, player.total_score
    assert_equal false, player.in_game
  end

  def test_player_entry_rule
    player = Player.new("Kirill")
    assert_equal false, player.can_enter_game?(250)
    assert_equal true, player.can_enter_game?(300)
    assert_equal true, player.can_enter_game?(450)
  end

  def test_game_creation
    game = GreedGame.new(["Kirill", "Master"])
    assert_equal 2, game.players.size
    assert_equal false, game.game_over?
  end

  def test_turn_scoring
    game = GreedGame.new(["Kirill"])
    score = game.play_turn(game.players.first)
    assert score >= 0
  end
end
