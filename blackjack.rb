require 'pry'
require 'colorize'

RANKS = %w{2 3 4 5 6 7 8 9 10 J Q K A}
SUITS = %w{Hearts Spades Diamonds Clubs}

# Build deck of cards, with blackjack value and color black/red based on suit
def build_deck_of_cards(deck)
  SUITS.each do |suit|
    RANKS.each do |rank|
      if suit == "Hearts" || suit == "Diamonds"
        if rank.match(/[B-Z]/)
          deck["#{rank} of #{suit}".red] = 10
        elsif rank.match("A")
          deck["#{rank} of #{suit}".red] = 11
        else
          deck["#{rank} of #{suit}".red] = rank.to_i
        end
      else
        if rank.match(/[B-Z]/)
          deck["#{rank} of #{suit}".light_black] = 10
        elsif rank.match("A")
          deck["#{rank} of #{suit}".light_black] = 11
        else
          deck["#{rank} of #{suit}".light_black] = rank.to_i
        end
      end
    end
  end
end

def deal_card(hand, deck)
  card = deck.keys.sample
  hand[card] = deck[card]
  deck.delete(card)
end

def show_player_hand(hand, player_name)
  puts "\n*** #{player_name}'s Hand -- Value: #{calculate_hand_value(hand)} ***"
  hand.each_key do |card|
    puts "#{card}"
  end
end

# Display hands, hiding dealer's first card.
def display_hands(player_hand, computer_hand, player_name)
  sleep(1)
  system 'clear'
  i = 0
  puts "\n*** Computer's Hand ***"
  puts "* of ******"
  computer_hand.each_key do |card|
    puts "#{card}"if i > 0
    i += 1
  end

  show_player_hand(player_hand, player_name)
  puts ""
end

# Display hands, revealing dealer's first card.
def display_final_hands(player_hand, computer_hand, player_name)
  sleep(1)
  system 'clear'

  puts "\n*** Computer's Hand  -- Value: #{calculate_hand_value(computer_hand)} ***"
  computer_hand.each_key do |card|
    puts "#{card}"
  end

  show_player_hand(player_hand, player_name)
  puts ""
end

# Return hand value, decreasing value of an Ace if it would cause the hand to exceed 21
def calculate_hand_value(hand)
  value = 0
  if hand.values.reduce(:+) <= 21
    value = hand.values.reduce(:+)
  elsif hand.values.reduce(:+) > 21 && hand.keys.any? {|card| card.include?("A") }
    hand.keys.each do |card|
      hand[card] = 1 if card.include?("A")
      value = hand.values.reduce(:+)
      break if value <= 21
    end
    value
  else
    value = hand.values.reduce(:+)
  end

end

def check_final_winner(player_hand, computer_hand, player_name)
  display_final_hands(player_hand, computer_hand, player_name)

  if calculate_hand_value(player_hand) > calculate_hand_value(computer_hand)
    puts "#{player_name} wins!"
  elsif calculate_hand_value(player_hand) < calculate_hand_value(computer_hand)
    puts "Computer wins.  :-("
  else
    puts "Push."
  end
end

# Game loop
loop do

  puts "\nWould you like to play blackjack?  (y/n)"
  break if gets.chomp.downcase != 'y'

  system 'clear'

  # Initialize deck, player/computer hands for new game, hit/stand check variable (before hit/stay loop).
  card_deck = {}
  build_deck_of_cards(card_deck)
  player_hand = {}
  computer_hand = {}
  hit_or_stand = "hit"

  puts "Lets go!\n"
  puts "Please enter your name:"
  player_name = gets.chomp.capitalize

  # Deal first hands
  2.times { deal_card(computer_hand, card_deck) }
  2.times { deal_card(player_hand, card_deck) }

  display_hands(player_hand, computer_hand, player_name)

  # Check for first-hand victory
  if calculate_hand_value(player_hand) == 21
    display_final_hands(player_hand, computer_hand, player_name)
    puts "Blackjack!   #{player_name} wins!"
    next
  elsif calculate_hand_value(computer_hand) == 21
    display_final_hands(player_hand, computer_hand, player_name)
    puts "Computer wins with 21."
    next
  end

  # Enter hit/stay cycle
  loop do
    # Prevent further prompting if player didn't choose to hit in a previous pass through loop.
    if hit_or_stand == "hit"
      loop do
        puts "Would you like to (hit) or (stand)?"
        hit_or_stand = gets.chomp.downcase
        break if hit_or_stand == "stand" || hit_or_stand =="hit"
        puts "Please enter a valid input of 'hit' or 'stand'"
      end
    end

    # Player hit or stand
    if hit_or_stand == "hit"
      puts  "#{player_name} hits."
      deal_card(player_hand, card_deck)
    else
      puts "#{player_name} stands."
    end

    display_hands(player_hand, computer_hand, player_name)

    # Check for player bust
    if calculate_hand_value(player_hand) > 21
      display_final_hands(player_hand, computer_hand, player_name)
      puts "#{player_name} busts!"
      puts "Computer wins.  :-("
      break
    end

    # Should Computer hit?
    if calculate_hand_value(computer_hand) < 17
      puts "Computer hits."
      deal_card(computer_hand, card_deck)
    elsif calculate_hand_value(computer_hand) >= 17 && calculate_hand_value(computer_hand) <= 21
      puts "Computer stands."
    end

    display_hands(player_hand, computer_hand, player_name)

    # Check for computer bust
    if calculate_hand_value(computer_hand) > 21
      display_final_hands(player_hand, computer_hand, player_name)
      puts "Computer busts!"
      puts "#{player_name} wins!"
      break
    end

    display_hands(player_hand, computer_hand, player_name)

    # Check for victory if player stands and player/computer didn't bust earlier.  Iterate again if computer is < 17.
    if hit_or_stand != "hit"
      if calculate_hand_value(computer_hand) < 17
        next
      else
        check_final_winner(player_hand, computer_hand, player_name)
        break
      end
    end
  end
end









