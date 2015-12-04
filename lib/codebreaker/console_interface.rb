require_relative './game'

class ConsoleInterface
  attr_reader :game
  LEVELS = ['e', 'm', 'h']

  def start
    select_level
    @game.start
  end

  def select_level
    puts "Select level:"
    puts "Press 'e' for easy   level"
    puts "Press 'm' for medium level"
    puts "Press 'h' for hard   level"

    loop do
      print "Your choise: "
      input = gets.chomp
      next unless LEVELS.include?(input)

      case input
      when 'e'
        @game = Codebreaker::Game.new('easy')
      when 'm'
        @game = Codebreaker::Game.new('medium')
      when 'h'
        @game = Codebreaker::Game.new('hard')
      end
      break
    end
  end

  def game_result
    puts "Game is over."
    if @game.won? 
      @game.count_up_score
      puts "You won. Total score: #{@game.score}"
    else
      puts "You lose."
    end
  end

  def play
    puts "Game 'Codebreaker'"
    loop do
      start
      puts "You must break 4 number code. You have #{@game.chances} chances."
      puts "You can press 'e' to exit the game."
      puts "You can press 'h' to get a hint (only once)."

      until @game.over? do
        print "Enter your guess (#{@game.chances} chances left): "
        input = gets.chomp

        case input 
        when 'h'
          puts "Secret code include number #{@game.hint}"
        when 'e'
          puts "See you next time."
          exit
        else
          answer = @game.guess(input)
          puts "Answer: #{answer}"
          break if @game.won?
        end
      end

      game_result
      save_result

      play_again
    end
  end

  def play_again
    puts "Press 'a' if you want to play again."
    puts "Press 'e' if you want to exit."
    print "Your choise: "
    input = gets.chomp

    case input
    when 'a' then play
    when 'e' then exit
    else 
      puts "Wrong input. Game is over."
      exit
    end
  end

  def save_result
    print "Enter your name: "
    input = gets.chomp
    @game.save_result(input)
    puts "Result is saved."
  end
end