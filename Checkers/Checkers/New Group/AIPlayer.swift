//
//  AIPlayer.swift
//  Checkers
//
//  Created by Schuette, Peter on 4/7/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation
import UIKit

/// Class for a computer minded player
class AIPlayer: Player {
    
    var level: Int
    let strategy: AIStrategy
    
    init(name: String, color: UIColor, pawnDirection: Direction, level: Int, strategy: AIStrategy) {
        self.level = level
        self.strategy = strategy
        super.init(name: name, color: color, pawnDirection: pawnDirection)
        
        self.strategy.player = self
    }
    
    
    override func startTurn() {
        // The AI Player's turn has started.
        // It should calculate a scoring index by thinking (self.level) steps ahead
        print("\(name)'s (AI) turn has started!")

    }
    
}

extension AIPlayer {
    
    func getMove() -> AIPotentialMove {
        if let move = strategy.findBestMove() {
            return move
        }
        
        fatalError("Unable to find the next best move")
    }
    
}
