require 'csv'
require 'json'
puts "EventManager initialized.\n\n"

#, headers:true, header_converters: :symbol
# p contents.to_a.sample
class Game
  attr_accessor :word,:used_letters,:correct_guess,:display,:guess
  def initialize
   @correct_guess = ''
   @used_letters = ''
  end
  def save_state
    state = {}
    self.instance_variables.each {|variable|
      state[variable] = self.instance_variable_get(variable)
    }
    puts state
    puts'\n'
    puts 'save'
    # state = "#{@word},#{@used_letters},#{@correct_guess},#{@display},#{@guess}"
    File.write('state.txt', state)
  end
  def load_state
    state = eval(File.read 'state.txt')
    p state
    state.each { |k,v|
      self.instance_variable_set(k,v)
    }
    # self.instance_variable_set
  end
  def get_word
    words = File.readlines '5desk.txt'
    begin
     @word = words.to_a.sample.chomp.downcase
     length = @word.length
    end until (length >= 5 && length <= 12)
    @display = '_'*length
  end

  def ask_guess
    @guess = ''
    begin
      puts `clear`
      puts "You Guessed\n#{used_letters.split('').join(',')}\n",'.'*60 unless used_letters == ''
      puts display_status,@word,"\nPlease guess a letter, \nyou have #{remainder} guesses left"
      puts "Press '0' to save"
      @guess = gets.chomp.downcase
      save_state if @guess == '0'
    end until (@guess.length == 1 && @guess[/[a-zA-Z]+/]  == @guess) #check to see if only one letter
    if @used_letters.include? @guess
      puts `clear`,"\nAlready guessed that!"
      sleep(1.2)
      ask_guess
    else
      @used_letters << @guess
    end
  end
  def apply_guess
    @word.split('').each_with_index { |letter,index|
      # p "index #{index}"
      if letter == @guess
        # p "match #{index} - #{letter}"
        update_display(letter,index)
      end
    }
  end
  def update_display(letter,index)
    temp_display = ''
    @display.split('').each_with_index { |blank,blank_index|
      if blank_index == index
        temp_display << letter
        @correct_guess << @guess
      else
        temp_display << @display[blank_index]
      end
    }
    @display = temp_display
  end
  def check_status
    if remainder == 0
      return true
    end
    @correct_guess.length.to_i == @word.length.to_i
  end
  def remainder
    15-@used_letters.length
  end
  def display_status
    puts @display.split('').join(' ')
  end
end


newGame = Game.new
puts "Type 'load' to load state?"
gets.chomp == 'load' ? newGame.load_state : newGame.get_word
begin
newGame.ask_guess
newGame.apply_guess
stop = newGame.check_status
end until stop
puts `clear`,"You win!!!   The word was #{newGame.word}"