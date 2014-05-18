require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def handcount(hand)
  handvalue = 0
  aces_in_hand = 0
  hand.each do |card|
    cardvalue = 0
    if card[1] == "2"
      cardvalue = 2
    elsif card[1] == "3"
      cardvalue = 3
    elsif card[1] == "4"
      cardvalue = 4
    elsif card[1] == "5"
      cardvalue = 5
    elsif card[1] == "6"
      cardvalue = 6
    elsif card[1] == "7"
      cardvalue = 7
    elsif card[1] == "8"
      cardvalue = 8
    elsif card[1] == "9"
      cardvalue = 9
    elsif card[1] == "10"
      cardvalue = 10
    elsif card[1] == "jack"
      cardvalue = 10
    elsif card[1] == "queen"
      cardvalue = 10
    elsif card[1] == "king"
      cardvalue = 10
    elsif card[1] == "ace"
      cardvalue = 11
      aces_in_hand = aces_in_hand + 1
    end
    handvalue = handvalue + cardvalue
  end
  while aces_in_hand > 0 do
    if handvalue > 21
      handvalue = handvalue - 10
    end
    aces_in_hand = aces_in_hand - 1
  end
  handvalue = handvalue + 0
end

  def card_image(card)
    "<img src='/images/cards/#{card[0]}_#{card[1]}.jpg' class='card_image'>"
  end

  def winner(msg)
    @play_again = true
    @show_buttons = false
    @error = "<strong>#{session[:player_name]} wins!</strong> #{msg}"
  end

  def loser(msg)
    @play_again = true
    @show__buttons = false
    @error = "<strong>#{session[:player_name]} loses.</strong> #{msg}"
  end

  def tie(msg)
    @play_again = true
    @show_buttons = false
    @error = "<strong>It's a tie!</strong> #{msg}"
  end

end

before do
  @show_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/set_player_name'
  end
end

# get '/betting' do
#   erb :betting
# end

get '/set_player_name' do
  erb :setplayername
end

post '/nameset' do
  session[:player_name] = params["playernameinput"]
  session[:wallet] = 500
  redirect '/game'
end

# post '/current_bet' do
#   session[:current_bet] = params["currentbet"]
#   redirect '/game'
# end

post '/game/player/hit' do
  session[:player_hand] << session[:deck].pop
  session[:player_hand_value] = handcount(session[:player_hand])
  if session[:player_hand_value] == 21
    winner("#{session[:player_name]} hit blackjack.")
  elsif session[:player_hand_value] > 21
    loser("#{session[:player_name]} busted at #{session[:player_hand_value]}.")
    @show_buttons = false
  end
  erb :game
end

post '/game/player/stay' do
  @error = "You have chosen to stay."
  @show_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_buttons = false
  session[:dealer_hand_value] = handcount(session[:dealer_hand])
  if session[:dealer_hand_value] == 21
    loser("Dealer hit blackjack.")
  elsif session[:dealer_hand_value] > 21
    winner("Dealer busted at #{session[dealer_hand_value]}.")
  elsif session[:dealer_hand_value] >= 17
    redirect 'game/evaluate'
  else
    @show_dealer_hit_button = true
  end
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_hand] << session[:deck].pop
  redirect 'game/dealer'
end

get '/game' do
  session[:turn] = session[:player_name]
  suits = ["hearts", "diamonds", "spades", "clubs"]
  cards = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace"]
  session[:deck] = suits.product(cards).shuffle!
  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand_value] = handcount(session[:player_hand])
  session[:dealer_hand_value] = handcount(session[:dealer_hand])
  erb :game
end

get '/game/evaluate' do
  @show_buttons = false
  session[:player_hand_value] = handcount(session[:player_hand])
  session[:dealer_hand_value] = handcount(session[:dealer_hand])
  if session[:player_hand_value] > session[:dealer_hand_value]
    winner("#{session[:player_name]} stayed at #{session[:player_hand_value]}, and the dealer stayed at #{session[:dealer_hand_value]}.")
  elsif session[:player_hand_value] < session[:dealer_hand_value]
    loser("#{session[:player_name]} stayed at #{session[:player_hand_value]}, and the dealer stayed at #{session[:dealer_hand_value]}.")
  else
    tie("Both #{session[:player_name]} and the dealer stayed at #{session[:player_hand_value]}.")
  end
  erb :game
end

post '/game/playon' do
  redirect '/game'
end

get '/game_over' do
  erb :game_over
end
