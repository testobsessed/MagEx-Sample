Feature: Players Start with Default Portfolios
        
    Scenario: Starting the game
        When I start the game
        Then there are 5 players named Fairy Godmother, Ali Baba, T-Bell, Merlin and Jack
        And Fairy Godmother has 100 Wishing Wands
        And Ali Baba has 100 Flying Carpets
        And T-Bell has 100 Pixie Dust Vials
        And Merlin has 100 Singing Swords
        And Jack has 100 Magic Beanbags
        And all players have 1000 gold
        And all portfolios are worth 1000 gold
        
