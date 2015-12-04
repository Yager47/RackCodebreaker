require_relative './code'
require 'date'

module Codebreaker
  class Game
    attr_reader :chances, :score, :level

    def initialize(level = 'easy')
      set_level(level)
      @won = false
    end

    def check(code)
      secret_copy = Code.new(@secret_code.to_s)
      code_copy   = Code.new(code.to_s)
      answer = ''

      code.each_with_index do |num, i| 
        if num == @secret_code[i]
          answer << '+'
          secret_copy[i] = code_copy[i] = '0'  
        end
      end
      secret_copy.delete('0')
      code_copy.delete('0')

      code_copy.each_with_index do |num, i|
        if secret_copy.include?(num)
          answer << '-'
          secret_copy.delete_first(num)
        end  
      end
      answer
    end

    def count_up_score
      @score = @coef * @chances + @level_points
    end

    def guess(code)
      @guess = Code.new(code)
      @chances -= 1
      answer = check(@guess)
      @won = true if answer == '++++'
      answer
    end

    def hint
      @hint ||= @secret_code[rand(0..3)]
    end

    def over?
      @chances <= 0
    end

    def save_result(name)
      raise ArgumentError, 'player should be a string' unless name.is_a?(String)
      f = File.open("../history/#{name.downcase}", 'a')
      datetime = DateTime.now.strftime('%F %R')
      result = won? ? "won" : "lose"
      chances_used = 30 - @coef - @chances
      f.puts  "#{@score} \t#{chances_used} \t#{result} \t#{datetime}"
      f.close
    end

    def start
      @secret_code = Code.new
    end

    def won?
      @won
    end

    private

    def set_level(level)
      case level
      when 'easy'   then @chances = 20
      when 'medium' then @chances = 15
      when 'hard'   then @chances = 10
      else raise ArgumentError, "level should be 'easy', 'medium' or 'hard'"
      end
      @level_points = 900 / @chances
      @coef = 30 - @chances
      @level = level    
    end
  end
end