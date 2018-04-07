//
//  Player.swift
//  Checkers
//
//  Created by Schuette, Peter on 4/7/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation
import UIKit

class Player: Hashable {

    var hashValue: Int

    var name: String

    var color: UIColor
    
    // The direction this players pawns are traveling
    var pawnDirection: Direction

    /// Initialize a player object
    ///
    /// - Parameters:
    ///   - name: name of the new player being initialized
    ///   - color: color of this players pieces
    init(name: String, color: UIColor, pawnDirection: Direction) {
        self.hashValue = pawnDirection.hashValue
        self.name = name
        self.color = color
        self.pawnDirection = pawnDirection
    }

    /// Copy constructor
    ///
    /// - Parameter Player: Player to copy
    convenience init(player: Player) {
        self.init(name: player.name, color: player.color, pawnDirection: player.pawnDirection)
    }

}


// MARK: - Static functions
extension Player {
    
    /// Check the equality of two players
    ///
    /// - Parameters:
    ///   - lhs: one player
    ///   - rhs: another player
    /// - Returns: true if these players have the same hash value
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


// MARK: - class functions
extension Player {

    /// This player's turn has started
    func startTurn() {
        // Do nothing for now, this user's turn has started
        print("\(name)'s turn has started!")
    }
    
}

