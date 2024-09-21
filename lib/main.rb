require 'json'

class Hangman
  def initialize
    @loaded_data = load_existing_game
    @word = @loaded_data[0]
    @lives = 5
    @word_copy = @word
    @guessed_words = Array.new(@word.length, '_')
    @incorrect_guess = Array.new(0)
    @total_guessed = @loaded_data[1]
  end

  def display_word
    puts "\nRemaining lives: #{@lives}"
    puts "Guessed: #{@guessed_words.join('')}"
    puts "Incorrect: #{@incorrect_guess.join(',')}"
  end

  def check_guessed(input)
    w_guessed = input.split('')
    guessed = false

    c = @word_copy.split('')
    w_guessed.each_with_index do |letter, _position|
      c.each_with_index do |l1, p1|
        next unless letter == l1

        @guessed_words[p1] = l1
        guessed = true
        @word_copy[p1] = '_'
      end
    end
    guessed
  end

  def check_finished
    return unless @guessed_words.join('').delete('_').length == @word.length

    @total_guessed += 1
    puts "You won! You guessed #{@total_guessed} in total"
    true
  end

  def game_loop
    loop do
      if @lives == 0
        puts 'Game Over!'
        break
      end

      print "\nEnter a letter(type exit to quit): "
      choice = gets.chomp.downcase
      exit! if choice == 'exit'
      choice = choice[0]
      is_guessed = check_guessed(choice)
      if is_guessed == false
        @lives -= 1
        @incorrect_guess.push(choice)
      end

      display_word

      is_finished = check_finished
      break if is_finished == true
    end
  end

  def play
    display_word
    quit = false

    loop do
      # p @word
      game_loop

      loop do
        print "\n1-Continue 0-Exit: "
        choice = gets.chomp.to_i

        next unless choice.between?(0, 1)

        quit = true if choice == 0
        break
      end

      break if quit == true

      new_game
    end
  end

  def new_game
    @word = load_word if @word != ''
    loop do
      print "\n1-Save 0-Don't save: "
      choice = gets.chomp.to_i

      if choice.between?(0, 1)
        save_game if choice == 1
        break
      else
        puts 'Incorrect Choice...'
      end
    end
    @lives = 5
    @word_copy = @word
    @guessed_words = Array.new(@word.length, '_')
    @incorrect_guess = Array.new(0)
  end

  def save_game
    Dir.mkdir('saves') unless Dir.exist?('saves')
    existing_files
    print 'Enter a name for your save: '
    save_name =  gets.chomp

    save_name = "saves/#{save_name}.json"
    data = {
      'word' => @word,
      'total_guessed' => @total_guessed
    }
    puts "Your file was saved at: #{save_name}"

    File.open(save_name, 'w') do |file|
      file.write(JSON.pretty_generate(data))
    end
  end

  def existing_files
    # puts "Old saves"
    all_saves = Dir.children('saves')

    puts 'Your saved games: '
    all_saves.each_with_index do |save, index|
      puts "#{index}-#{save.split('.')[0]}"
    end

    puts "\n"

    all_saves
  end

  def load_game
    all_saves = existing_files
    loop do
      print "\nChoose the number corresponding to the file you want to load: "
      choice = gets.chomp
      puts "Choice: #{choice}"

      begin
        if choice.to_i.between?(0, all_saves.length - 1)
          file = File.open "saves/#{all_saves[choice.to_i]}"
          data = JSON.load file
          file.close

          return data
          break
        else
          puts 'Incorrect choice'
        end
      rescue StandardError
        puts 'Incorrect choice...'
      end
    end
  end

  def load_existing_game
    number_of_files = existing_files.length
    dt = [load_word, 0]

    if number_of_files >= 1
      print '1-Load existing game: '
      choice = gets.chomp.to_i

      if choice == 1
        data = load_game
        # print "This is the data"
        # p data
        dt[0] = data['word']
        dt[1] = data['total_guessed']
      end
    end
    dt
  end

  def load_word
    loop do
      all_words = File.readlines('google-10000-english-no-swears.txt')
      selected_word = all_words[rand(0..all_words.length)]
      return selected_word.chomp if selected_word.length.between?(6, 13) == true
    end
  end
end

def display_word(word, w_guessed)
  w_guessed = w_guessed.split('')
  guessed = false
  c = word.split('')
  w_guessed.each_with_index do |letter, _position|
    c.each_with_index do |l1, p1|
      next unless letter == l1

      @guessed_words[p1] = l1
      guessed = true
      c[p1] = '_'
    end
  end
  p gg.join('')
  gg
end

def input
  word = 'hello'
  guessed_words = []

  loop do
    p display_word(word, '')
    print "\nEnter a letter: "
    choice = gets.chomp[0].downcase
    guessed_words.push(display_word(word, choice)).flatten! if display_word(word, choice).length > 0
  end
end

game = Hangman.new
game.play
