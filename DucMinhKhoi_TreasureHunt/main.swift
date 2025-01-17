//
//  main.swift
//  DucMinhKhoi_TreasureHunt
//
//  Created by Duc Minh Khoi Tran on 2025-01-13.
//

import Foundation


// Data structures
struct Island {
    var name: String
    var treasures: Int
    var specialTreasure: Bool
}

struct Player {
    var name: String
    var points: Int
    var treasures: Int
    var turnsSkipped: Bool
}

// Game Set up
var islands = [
    Island(name: "Emerald Isle", treasures: Int.random(in: 3...7), specialTreasure: false),
    Island(name: "Ruby Cove", treasures: Int.random(in: 3...7), specialTreasure: false),
    Island(name: "Sapphire Shore", treasures: Int.random(in: 3...7), specialTreasure: false)
]

var players: [Player] = []

var luckyIsland = Int.random(in: 0..<islands.count)
var currentPlayer = 0
var turnCount = 0


// Game functions
func menuOptions() {
    print("\n--- Treasure Hunt ---")
    print("1. Start a new game")
    print("2. Show scoreboard")
    print("3. Exit")
    print("Choose an option: ", terminator: "")
}

func initializeGame() {
    
    // set up island
    for i in 0..<islands.count {
        islands[i].specialTreasure = false
        islands[i].treasures = Int.random(in: 3...7)
    }
    
    luckyIsland = Int.random(in: 0..<islands.count)
    turnCount = 0
    
    // Setup players
    players.removeAll()
    print("Enter Player 1 name: ", terminator: "")
    let player1 = readLine() ?? "Player 1"
    print("Enter player 2 name: ", terminator: "")
    let player2 = readLine() ?? "Player 2"
    
    players.append(Player(name: player1, points: 0, treasures: 0, turnsSkipped: false))
    players.append(Player(name: player2, points: 0, treasures: 0, turnsSkipped: false))
    
    let startingPlayerIndex = Int.random(in: 0..<players.count)
    currentPlayer = startingPlayerIndex
    print("\n\(players[currentPlayer].name) will go first.")
}

func displayIslands() {
    print("\nCurrent Treasures:")
    for(index, island) in islands.enumerated() {
        print("\(index + 1): \(island.name) (\(island.treasures) treasures)")
    }
}

func playTurn() {
    let player = players[currentPlayer]
    if player.turnsSkipped {
        print("\n \(player.name)'s turn is skipped due to a previous penalty.")
        currentPlayer = (currentPlayer + 1) % players.count
        return
    }
    
    turnCount += 1
    print("\n \(player.name)'s turn.")
    displayIslands()
    
    // check for stealing option
    if turnCount == 3 {
        print("This is your 3rd turn. Do you want to steal treasures from the opponent? (yes/no): ", terminator: "")
        let stealInput = readLine()?.lowercased() ?? "no"
        
        if stealInput == "yes" {
            Stealing()
            return
        }
    }
    
    print("Select an island by number:", terminator: "")
    guard let islandChoice = Int(readLine() ?? ""), islandChoice >= 1, islandChoice <= islands.count else {
        print("Invalid choice! Turn skipped.\n")
        return
    }
    
    let islandIndex = islandChoice - 1
    let selectedIsland = islands[islandIndex]
    print("How many treasures do you want to collect form \(selectedIsland.name)?")
    guard let treasureToCollect = Int(readLine() ?? ""), treasureToCollect > 0, treasureToCollect <= selectedIsland.treasures else {
        print("Invalid choice! Turn skipped.\n")
        return
    }
    
    // collect treasures
    islands[islandChoice - 1].treasures -= treasureToCollect
    players[currentPlayer].treasures += treasureToCollect
    
    var pointGained = treasureToCollect * 5
    
    // check for lucky Island bonus
    if islandIndex == luckyIsland{
        pointGained *= 2
        luckyIsland = -1
        print( "\nYou found the lucky island! Your score is multiplied by 2.")
    }
    
    // Check for special treasure
    if !selectedIsland.specialTreasure && Int.random(in: 1...selectedIsland.treasures) == treasureToCollect {
        islands[islandIndex].specialTreasure = true
        print("🎉 Special Treasure Found! \(player.name) gets an extra turn!")
        players[currentPlayer].points += pointGained
        return
    }
    
    // Add points to player
    players[currentPlayer].points += pointGained
    print("\(player.name) collected \(treasureToCollect) treasures from \(selectedIsland.name).")
    print("Treasures: \(players[currentPlayer].treasures), Points: \(players[currentPlayer].points)\n")
    
    
    addRandomTreasures()
    
    // Switch turn
    currentPlayer = (currentPlayer + 1) % players.count
}

func Stealing() {
    let opponentIndex = (currentPlayer + 1) % players.count
    let opponent = players[opponentIndex]
    
    print("How many treasures tdo you want to steal?", terminator: "")
    guard let treasuresToSteal = Int(readLine() ?? ""), treasuresToSteal > 0, treasuresToSteal <= opponent.treasures
    else {
        print("Invalid number of treasures to steal.")
        return
    }
    players[currentPlayer].treasures += treasuresToSteal
    players[currentPlayer].points += treasuresToSteal * 5
    players[opponentIndex].treasures -= treasuresToSteal
    players[opponentIndex].points -= treasuresToSteal * 5
    players[currentPlayer].turnsSkipped = true // Lose next turn
    
    print("\(players[currentPlayer].name) stole \(treasuresToSteal) treasures from \(opponent.name)")
}

func addRandomTreasures() {
    let randomIslandIndex = Int.random(in: 0..<islands.count)
    let treasureToAdd = Int.random(in: 1...5)
    islands[randomIslandIndex].treasures += treasureToAdd
    print("A random treasure was added to \(islands[randomIslandIndex].name). It now has \(islands[randomIslandIndex].treasures) treasures.")
}
func checkGameEnd() -> Bool {
    return islands.allSatisfy { $0.treasures == 0 }
}

func showScoreboard() {
    print("---- Scoreboard -----")
    for player in players {
        print("\(player.name):")
                print("  Treasures: \(player.treasures)")
                print("  Points: \(player.points)")
                print("--------------------------")
    }
}

// main game

while true {
    menuOptions()
    guard let choice = Int(readLine() ?? ""), choice >= 1, choice <= 3 else
    {
        print("Invalid choice! Try again.")
                continue
    }
    
    switch choice {
    case 1:
        initializeGame()
        while !checkGameEnd() {
            playTurn()
        }
        print("Game Over! All treasures have been collected")
        let winner = players.max { $0.points < $1.points }!
        print("🎉 Congratulations, \(winner.name)! You won the game!")
    case 2:
        showScoreboard()
    case 3:
        print("Exiting the game. Goodbye!")
        exit(0)
        default :
        break
    }
}



