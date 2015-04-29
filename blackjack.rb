# -start of game-
# 1. Deal cards (2 for dealer (one visible), 2 for player)
# 2. Check for winner
#     -- Player has 21
#         -- Player wins
#     -- Dealer has 21
#         -- Dealer wins
#     -- Both have 21
#         -- Push? or Player auto wins?
#
# -loop-
# 4. Ask player to hit or stay.
#     -- hit?  -  draw and display card from deck
#     -- stay?  -  do nothing
# 5. Did player hit or stay?
#     -- Stay  -  dealer hits until over 17 or bust
#         -- bust?  -  player wins
#         -- over 17?  -  check for winner or push
#     -- Hit  -  dealer hits once
#         -- dealer over 17 or bust?
#             -- bust?  -  player wins
#             -- over 17?  -  check for winner or push
#             -- not over 17?  -  got back to start of loop


require 'pry'
require 'colorize'

RANKS = %w{2 3 4 5 6 7 8 9 10 J Q K A}
SUITS = %w{Hearts Spades Diamonds Clubs}


# Build deck of cards and color black/red based on suit
def build_deck_of_cards(deck)
  SUITS.each do |suit|
    RANKS.each_with_index do |rank, i|
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

# Shouldn't need to actually use this in-game
def print_cards(deck)
  deck.each { |k,v| puts "#{k} -- #{v}"}
end

def deal_card(hand, deck)
  card = deck.keys.sample
  hand[card] = deck[card]
  deck.delete(card)
end

def show_player_hand(hand, player_name)
  puts "\n*** #{player_name}'s Hand -- Value: #{get_hand_value(hand)} ***"
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

# Display hands, including dealer's first card.
def display_final_hands(player_hand, computer_hand, player_name)
  sleep(1)
  system 'clear'

  puts "\n*** Computer's Hand  -- Value: #{get_hand_value(computer_hand)} ***"
  computer_hand.each_key do |card|
    puts "#{card}"
  end

  show_player_hand(player_hand, player_name)
  puts ""
end

def get_hand_value(hand)
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

def bust?(hand)
  if get_hand_value(hand) > 21
    true
  else
    false
  end
end

loop do

  puts "\nWould you like to play blackjack?  (y/n)"
  break if gets.chomp.downcase != 'y'

  system 'clear'

  # Initialize deck, player/computer hands for new game, hit/stand check variable (before loop).
  card_deck = {}
  player_hand = {}
  computer_hand = {}
  hit_or_stand = ""
  build_deck_of_cards(card_deck)

  puts "Lets go!\n"
  puts "Please enter your name:"
  player_name = gets.chomp.capitalize

  # Deal first hands
  deal_card(computer_hand, card_deck)
  deal_card(player_hand, card_deck)
  deal_card(computer_hand, card_deck)
  deal_card(player_hand, card_deck)

  display_hands(player_hand, computer_hand, player_name)

  # Check for first-hand victory
  if get_hand_value(player_hand) == 21
    display_final_hands(player_hand, computer_hand, player_name)
    puts "Blackjack!   #{player_name} wins!"
    next
  elsif get_hand_value(computer_hand) == 21
    display_final_hands(player_hand, computer_hand, player_name)
    puts "Computer wins with 21."
    next
  end

  # Enter hit/stay cycle
  loop do
    if hit_or_stand != "stand"
      puts "Would you like to (hit) or (stand)?"
      hit_or_stand = gets.chomp.downcase
    end

    #Player hit or stand
    if hit_or_stand == "hit"
      puts  "#{player_name} hits."
      deal_card(player_hand, card_deck)
    else
      puts "#{player_name} stands."
    end

    display_hands(player_hand, computer_hand, player_name)

    # Check for player bust
    if bust?(player_hand)
      display_final_hands(player_hand, computer_hand, player_name)
      puts "#{player_name} busts!"
      puts "Computer wins.  :-("
      break
    end

    # Computer hit?
    if get_hand_value(computer_hand) < 17
      puts "Computer hits."
      deal_card(computer_hand, card_deck)
    elsif get_hand_value(computer_hand) >= 17 && get_hand_value(computer_hand) <= 21
      puts "Computer stands."
    end

    display_hands(player_hand, computer_hand, player_name)

    # Check for computer bust
    if get_hand_value(computer_hand) > 21
      display_final_hands(player_hand, computer_hand, player_name)
      puts "Computer busts!"
      puts "#{player_name} wins!"
      break
    end

    display_hands(player_hand, computer_hand, player_name)

    # Check for victory if player stands and player/computer didn't bust earlier.  Iterate again if computer is < 17.
    if hit_or_stand == "stand"
      if get_hand_value(computer_hand) < 17
        next
      elsif get_hand_value(player_hand) > get_hand_value(computer_hand)
        display_final_hands(player_hand, computer_hand, player_name)
        puts "#{player_name} wins!"
        break
      elsif get_hand_value(player_hand) < get_hand_value(computer_hand)
        display_final_hands(player_hand, computer_hand, player_name)
        puts "Computer wins!"
        break
      else
        puts "Push."
        break
      end
    end
  end
end









