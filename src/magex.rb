class MagexGame
  attr :players
  attr :market
  
  def initialize
    @market = Market.new
    @players = default_players
  end
  
  def find_player(name)
    @players.each { | player |
      return player if player.named?(name)
    }
  end
  
  def player_names
    names = []
    @players.each{ | player | 
      names.push player.name
    }
    names
  end
  
  def accept_bid(bid_id)

    bid = @market.bids[bid_id]
    offer = @market.offers[bid[:offer_id]]
    seller = find_player(offer[:seller])
    buyer = find_player(bid[:bidder])
    
    #first exchange the money
    buyer.portfolio.pull_from_escrow("Gold", bid[:amount])
    seller.portfolio.receive("Gold", bid[:amount])
    
    # remove the successful bid since we will process this separately
    @market.remove_bid(bid_id)
    
    # restore money from escrow to all remaining bidding players
    @market.bids_for_offer(bid[:offer_id]).each { |a_bid|
      player = find_player(a_bid[:bidder])
      player.portfolio.escrow("Gold", -(a_bid[:amount]))
    }
    
    seller.portfolio.escrow_account[offer[:item]] = 0
    
    buyer.portfolio.receive(offer[:item], offer[:quantity])
    @market.remove_bids_for_offer(bid[:offer_id])
    @market.remove_offer(bid[:offer_id])
  end

  def default_player_data 
    {
      "Fairy Godmother" => {
            "Gold" => 1000,
            "Wishing Wands" => 100
       },
       "Jack" => {
             "Gold" => 1000,
             "Magic Beanbags" => 100
        },
        "T-Bell" => {
              "Gold" => 1000,
              "Pixie Dust Vials" => 100
         },
         "Ali Baba" => {
               "Gold" => 1000,
               "Flying Carpets" => 100
          },
          "Merlin" => {
                "Gold" => 1000,
                "Singing Swords" => 100
           },
    }    
  end
  
  def default_players
    players = []
    player_data = default_player_data
    player_data.keys.each { |player_name|
      players.push Player.new(player_name, player_data[player_name], @market)
    }
    players
  end
  
end

class Player
  attr :portfolio
  attr :name
  attr :market
  
  def initialize(name, portfolio_data, market=nil)
    @market = market
    @name = name
    @portfolio = Portfolio.new(portfolio_data)
  end
  
  def named?(name)
    return @name == name
  end
  
  def offer(item, quantity)
    if portfolio.available(item) >= quantity
      @portfolio.escrow(item, quantity)
      @market.for_sale({:seller => @name, :item => item, :quantity => quantity}) if @market
    else
      return nil
    end
  end
  
  def bid(offer_id, amount)
    @portfolio.escrow("Gold", amount)
    @market.bid({:bidder => @name, :offer_id => offer_id, :amount => amount}) if @market
  end
  
  def retract_bid(bid_id)
    bid = @market.bids[bid_id]
    @market.remove_bid(bid_id)
    @portfolio.escrow("Gold", -(bid[:amount]))
  end
end

class Portfolio
  attr :escrow_account
  attr :available_account
  attr :market_value
  
  def initialize(contents, market_value={})
    @escrow_account = {}
    @available_account = contents
    @market_value = market_value
  end
  
  def escrow(item, quantity)
    return if @available_account[item] < quantity
    @available_account[item] -= quantity
    @escrow_account[item] = @escrow_account[item].to_i + quantity
  end
  
  def pull_from_escrow(item, quantity)
    @escrow_account[item] = @escrow_account[item].to_i - quantity
  end
  
  def receive(item, quantity)
    @available_account[item] = @available_account[item].to_i + quantity
  end
  
  def contains?(item)
    return 0 < @available_account[item].to_i
  end
  
  def available(item)
    return @available_account[item].to_i
  end
  
  def in_escrow(item)
    return @escrow_account[item].to_i
  end
  
  def value
    sum = 0
    @available_account.each {|item, quantity|
      if item == "Gold"
        sum += quantity
      else
        sum += (quantity * @market_value[item].to_i)
      end
    }
    sum
  end
end

class Market
  attr :offers
  attr :bids
  attr :next_id
  attr :current_market_values
  
  def initialize()
    @offers = {}
    @bids = {}
    @next_id = 0
    @current_market_values = {}
  end
  
  def for_sale(offer)
    offer_id = get_next_id
    @offers[offer_id] = offer
    offer_id
  end
  
  def bid(bid)
    bid_id = get_next_id
    @bids[bid_id] = bid
    bid_id
  end
  
  def closing_bell
    @offers = {}
    @bids = {}
  end
  
  def get_next_id
    return @next_id += 1
  end
  
  def bids_for_offer(offer_id)
    bids_on_offer = []
    @bids.keys.each {|key|
      bids_on_offer.push @bids[key] if @bids[key][:offer_id] == offer_id
    }
    bids_on_offer
  end
  
  def remove_bids_for_offer(offer_id)
    @bids.keys.each {|key|
      @bids.delete(key) if @bids[key][:offer_id] == offer_id
    }
  end
  
  def remove_offer(offer_id)
    @offers.delete(offer_id)
  end
  
  def remove_bid(bid_id)
    @bids.delete(bid_id)
  end
  
  def find_bid_id_matching(clues)
    seller_name = clues[:seller]
    buyer_name = clues[:bidder]
    found_bid_id = -1
    @bids.keys.each {|bid_id|
      bid = @bids[bid_id]
      offer = @offers[bid[:offer_id]]
      found_bid_id = bid_id if ((bid[:bidder] == buyer_name) && (offer[:seller] == seller_name))
    }
    found_bid_id
  end
  
  def find_offer_id_for_item(item)
    found_offer_id = -1
    @offers.keys.each {|offer_id|
      found_offer_id = offer_id if (@offers[offer_id][:item] == item)
    }
    found_offer_id
  end
end