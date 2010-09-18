When /^I start the game$/ do
  @game = MagexGame.new
end

Then /^there are (\d+) players named (.*)$/ do |num_players, names|
  player_names = extract_array_from_prose(names)
  @game.players.length.should == player_names.length
  @game.player_names.sort.should == player_names.sort
end
  
Then /^(.*) has (\d+) (.*)s?$/ do |name, amount, item|
  @game.find_player(name).portfolio.available(item).should == amount.to_i
end

Then /^all players have (\d+) gold$/ do |arg1|
  @game.players.each { |player| 
    player.portfolio.available("Gold").should == 1000
  }
end

Then /^all portfolios are worth (\d+) gold$/ do |amount|
  @game.players.each { |player| 
    player.portfolio.value.should == amount.to_i
  }
end

Given /^(.*) offers (\d+) (.*)s?$/ do |player, quantity, item|
  player = @game.find_player(player)
  @offer_id = player.offer(item, quantity.to_i)
end

Then /^the market shows an offer for (\d+) (.*)s? from (.*)$/ do |quantity, item, player|
  offer_id = get_offer_id(player, item, quantity)
  offer_id.should > 0
end

Then /^the market does not show an offer for (\d+) (.*)s? from (.*)$/ do |quantity, item, player|
  offer_id = get_offer_id(player, item, quantity)
  offer_id.should < 0
end

When /^(.*) bids (\d+) Gold for (.*)'s (\d+) (.*)s?$/ do |buyer, amount, seller, quantity, item|
  offer_id = get_offer_id(seller, item, quantity)
  buyer = @game.find_player(buyer)
  buyer.bid(offer_id, amount.to_i)
end


When /^(.*) bids (\d+) [gG]old$/ do |buyer, amount|
  buyer = @game.find_player(buyer)
  @bid_id = buyer.bid(@offer_id, amount.to_i)
end

When /accepts the bid$/ do
  @game.accept_bid(@bid_id)
end

When /^(.*) accepts (.*)'s bid$/ do |seller, buyer|
  bid_id = @game.market.find_bid_id_matching({:bidder => buyer, :seller => seller})
  @game.accept_bid(bid_id)
end

Given /^the following offers:$/ do |table|
  table.hashes.map { |offer|
    player = @game.find_player(offer[:seller])
    player.offer(offer[:item], offer[:quantity].to_i)
  }
end

Given /^the following bids:$/ do |table|
  table.hashes.map { |bids|
    offer_id = @game.market.find_offer_id_for_item(bids[:item])
    bidder = @game.find_player(bids[:bidder])
    bidder.bid(offer_id, bids[:gold].to_i)
  }
end

Then /^player inventories are:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end


Then /^there are no offers in the market$/ do
  @game.market.offers.length.should == 0
end

Then /^there are no bids in the market$/ do
  @game.market.bids.length.should == 0
end
