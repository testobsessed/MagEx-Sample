After do |s| 
  
end

Before do
  @game = MagexGame.new
  @game.players.length.should == 5
end

def extract_array_from_prose(text)
  items = text.split(",").map{|item| item.strip} # take a first pass
  if !(items.last.match(/and/).nil?)
    # last entry contains 2 names
    add_items = items.pop.match(/(.*),? and (.*)/)
    items += [add_items[1], add_items[2]]
  end
  items
end

def get_offer_id(player, item, quantity)
  found_offer_id = -1
  @game.market.offers.keys.each {|offer_id|
    offer = @game.market.offers[offer_id]
    offer_matches = (offer[:quantity] == quantity.to_i) && (offer[:item] == item) && (offer[:seller] == player)
    found_offer_id = offer_id if offer_matches
  }
  found_offer_id 
end

def pluralize(item)
   item = "#{item}s" if !item.end_with? "s"
end