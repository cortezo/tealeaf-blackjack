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

DECK_OF_CARDS = {}
