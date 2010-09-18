Feature: Players can buy and sell items on the market
    Background:
        Given I start the game
        
    Scenario: making an offer
        When Fairy Godmother offers 10 Wishing Wands
        Then the market shows an offer for 10 Wishing Wands from Fairy Godmother
        
    Scenario: a simple trade
        Given Fairy Godmother offers 10 Wishing Wands
        And Jack bids 15 gold
        When Fairy Godmother accepts the bid
        Then Fairy Godmother has 90 Wishing Wands
        And Fairy Godmother has 1015 Gold
        And Jack has 10 Wishing Wands
        And Jack has 985 Gold
        And there are no offers in the market
        
    Scenario: a trade with multiple bids on an offer
        Given Fairy Godmother offers 10 Wishing Wands
        And T-Bell bids 10 gold
        And Jack bids 15 gold
        When Fairy Godmother accepts the bid
        Then Fairy Godmother has 90 Wishing Wands
        And Fairy Godmother has 1015 Gold
        And T-Bell has 0 Wishing Wands
        And T-Bell has 1000 Gold
        And Jack has 10 Wishing Wands
        And Jack has 985 Gold
        And there are no bids in the market
        
    Scenario: a more complex trade
        Given Fairy Godmother offers 10 Wishing Wands
        And Ali Baba offers 12 Flying Carpets
        And Jack bids 10 Gold for Fairy Godmother's 10 Wishing Wands
        And Jack bids 18 Gold for Ali Baba's 12 Flying Carpets
        And T-Bell bids 15 Gold for Fairy Godmother's 10 Wishing Wands
        And T-Bell bids 14 Gold for Ali Baba's 12 Flying Carpets
        When Fairy Godmother accepts T-Bell's bid
        And Ali Baba accepts Jack's bid
        Then Jack has 12 Flying Carpets
        And Jack has 982 Gold
        And T-Bell has 10 Wishing Wands
        And T-Bell has 985 Gold
        And Fairy Godmother has 90 Wishing Wands
        And Fairy Godmother has 1015 Gold
        And Ali Baba has 88 Flying Carpets
        And Ali Baba has 1018 Gold
        
    Scenario: a more complex trade
        Given the following offers:
        | seller          | item           | quantity |
        | Fairy Godmother | Wishing Wands  | 10       |
        | Ali Baba        | Flying Carpets | 12       |
        
        And the following bids:
        | bidder | item           | gold |
        | Jack   | Wishing Wands  | 10   |
        | Jack   | Flying Carpets | 18   |
        | T-Bell | Wishing Wands  | 15   |
        | T-Bell | Flying Carpets | 14   |
        
        When Fairy Godmother accepts T-Bell's bid
        And Ali Baba accepts Jack's bid
        
        Then player inventories are:
        | player          | wands | carpets | gold |
        | Fairy Godmother |    90 |       0 | 1015 |
        | Ali Baba        |     0 |      88 | 1018 |
        | T-Bell          |    10 |       0 |  985 |
        | Jack            |     0 |      12 |  982 |
    