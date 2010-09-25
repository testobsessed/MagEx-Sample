require File.expand_path(File.dirname(__FILE__) + '../../../src/magex.rb')

describe "Magical Commodity Exchange Game" do
  attr :game
  
  before(:each) do
    @game = MagexGame.new
  end
  
  it "can find players by name" do
    player = @game.find_player("Fairy Godmother")
    player.name.should == "Fairy Godmother"
  end
  
  it "updates market values based on last trade" do
    # pending
  end
  
  it "manages the buy and sell process" do
    seller = @game.find_player("Fairy Godmother")
    buyer = @game.find_player("Jack")
    offer_id = seller.offer("Wishing Wands", 10)
    bid_id = buyer.bid(offer_id, 15)
    @game.market.offers[offer_id].should_not be_nil
    @game.market.bids[bid_id].should_not be_nil
    @game.accept_bid(bid_id)
    @game.market.offers.should == {}
    @game.market.bids.should == {}
    seller.portfolio.available("Wishing Wands").should == 90
    seller.portfolio.in_escrow("Wishing Wands").should == 0
    seller.portfolio.available("Gold").should == 1015
    buyer.portfolio.available("Wishing Wands").should == 10
    buyer.portfolio.in_escrow("Gold").should == 0
    buyer.portfolio.available("Gold").should == 985
  end
  
  it "removes unsuccessful bids and replaces funds in escrow" do
    seller = @game.find_player("Fairy Godmother")
    buyer = @game.find_player("Jack")
    offer_id = seller.offer("Wishing Wands", 10)
    offer_id.should == 1
    @game.market.offers[offer_id].should == {:seller => "Fairy Godmother", :item => "Wishing Wands", :quantity => 10}
    bid_id = buyer.bid(offer_id, 15)
    bid_id.should == 2
    @game.market.bids[bid_id].should == {:bidder => "Jack", :offer_id => offer_id, :amount => 15}
    @game.accept_bid(bid_id)
    seller.portfolio.available("Wishing Wands").should == 90
    seller.portfolio.in_escrow("Wishing Wands").should == 0
    seller.portfolio.available("Gold").should == 1015
    buyer.portfolio.available("Wishing Wands").should == 10
    buyer.portfolio.in_escrow("Gold").should == 0
    buyer.portfolio.available("Gold").should == 985
  end
  
  
end

describe "Player" do
  it "constructs a portfolio from the provided data" do
    player = Player.new("Dude", {"Rocks" => 100})
    player.portfolio.available_account.should == {"Rocks" => 100}
  end
  
  it "can offer an item for sale" do
    player = Player.new("Fred", {"Rocks" => 100})
    player.offer("Rocks", 10)
    player.portfolio.in_escrow("Rocks").should == 10
    player.portfolio.available("Rocks").should == 90
  end
  
  it "cannot offer item for sale if not enough inventory" do
    player = Player.new("Fred", {"Rocks" => 100})
    player.offer("Rocks", 110)
    player.portfolio.in_escrow("Rocks").should == 0
    player.portfolio.available("Rocks").should == 100
  end
  
  it "can bid on an offer" do
    player = Player.new("Fred", {"Gold" => 1000})
    player.bid({}, 10)
    player.portfolio.in_escrow("Gold").should == 10
    player.portfolio.available("Gold").should == 990
  end
  
  it "can retract a bid" do
    market = Market.new
    player = Player.new("Fred", {"Gold" => 1000}, market)
    
    bid_id = player.bid({}, 10)
    player.portfolio.in_escrow("Gold").should == 10
    player.portfolio.available("Gold").should == 990
    
    player.retract_bid(bid_id)
    market.bids[bid_id].should be_nil
    player.portfolio.in_escrow("Gold").should == 0
    player.portfolio.available("Gold").should == 1000
  end
  
end

describe "Portfolios" do
  it "can tell us if they contain an item" do
    portfolio = Portfolio.new({"Rocks" => 100})
    portfolio.contains?("Rocks").should == true
  end
  
  it "can tell us how much of an item something has" do
    portfolio = Portfolio.new({"Rocks" => 100})
    portfolio.available("Rocks").should == 100
  end
  
  it "reports 0 items if item unknown" do
    portfolio = Portfolio.new({})
    portfolio.available("Rocks").should == 0
  end
  
  it "has value of 0 if empty" do
    portfolio = Portfolio.new({})
    portfolio.value.should == 0
  end
  
  it "has value of the gold if nothing else in it" do
    portfolio = Portfolio.new({"Gold" => 100})
    portfolio.value.should == 100
  end
  
  it "uses market values to value commodities" do
    market_data = {"Rocks" => 10}
    portfolio_contents = {"Rocks" => 100}
    portfolio = Portfolio.new(market_data, portfolio_contents)
    portfolio.value.should == 1000
  end
  
  it "can put items in escrow" do
    portfolio = Portfolio.new({"Gold" => 100})
    portfolio.escrow("Gold", 10)
    portfolio.available("Gold").should == 90
    portfolio.in_escrow("Gold").should == 10
  end
  
  it "can remove items from escrow" do
    portfolio = Portfolio.new({"Gold" => 100})
    portfolio.escrow("Gold", 10)
    portfolio.escrow("Gold", -10)
    portfolio.available("Gold").should == 100
    portfolio.in_escrow("Gold").should == 0
  end  
  
  it "will not put more in escrow than available" do
    portfolio = Portfolio.new({"Gold" => 100})
    portfolio.escrow("Gold", 110)
    portfolio.available("Gold").should == 100
    portfolio.in_escrow("Gold").should == 0
  end
  
  it "can receive items" do
    portfolio = Portfolio.new({})
    portfolio.receive("Gold", 10)
    portfolio.available("Gold").should == 10
  end
  
  it "can pull from escrow" do
    portfolio = Portfolio.new({"Gold" => 100})
    portfolio.escrow("Gold", 10)
    portfolio.pull_from_escrow("Gold", 10)
    portfolio.in_escrow("Gold").should == 0
    portfolio.available("Gold").should == 90
  end
end

describe "Market" do
  it "tracks offers" do
    market = Market.new
    offer_id = market.for_sale({:seller => "Fred", :item => "Rock", :quantity => 10})
    market.offers[offer_id].should == {:seller => "Fred", :item => "Rock", :quantity => 10}
  end
  
  it "emptys the offers and bids at closing bell" do
    market = Market.new
    market.for_sale({:seller => "Fred", :item => "Rock", :quantity => 10})
    market.offers.length.should == 1
    market.closing_bell
    market.offers.length.should == 0
    market.bids.length.should == 0
  end
  
  it "knows how to remove bids for an offer" do
    market = Market.new
    offer_id = 1
    10.times {market.bid({:offer_id => offer_id})}
    market.bids.length.should == 10
    market.remove_bids_for_offer(offer_id)
    market.bids.length.should == 0
  end
  
  it "knows how to remove an offer" do
    market = Market.new
    offer_id = market.for_sale({:name => "Pete"})
    market.remove_offer(offer_id)
    market.offers.length.should == 0
  end
  
  it "can provide a list of bids for an offer" do
    market = Market.new
    offer_id = 1
    10.times {market.bid({:offer_id => offer_id})}
    market.bids_for_offer(offer_id).length.should == 10
  end
  
  it "can find a bid id from clues" do
    market = Market.new
    offer = {:seller => "Fred"}
    offer_id = market.for_sale(offer)
    bid = {:bidder => "Barney", :offer_id => offer_id}
    bid_id = market.bid(bid)
    market.find_bid_id_matching({:bidder => "Barney", :seller => "Fred"}).should == bid_id
  end
  
  it "can find an offer for an item" do
    market = Market.new
    offer = {:item => "Beans"}
    market.for_sale(offer)
    market.find_offer_id_for_item("Beans").should == 1
  end
end