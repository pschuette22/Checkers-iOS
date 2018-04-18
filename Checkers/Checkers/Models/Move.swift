//
//  Move.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/3/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation

enum MoveType {
    case simple // simple change of tile
    case jump // jump piece
    case stay // stay during chain jump
}

struct Move: Equatable, Hashable {
    var hashValue: Int

    let target: TileIndex!
    let destination: TileIndex!
    // List of indexes that were jumped during this turn
    let jump: TileIndex?

    let type: MoveType

    init(target: TileIndex, destination: TileIndex, jump: TileIndex?) {
        self.hashValue = "\(target.hashValue)\(destination.hashValue)\(String(describing: jump?.hashValue))".hashValue
        self.target = target
        self.destination = destination
        self.jump = jump

        if jump != nil {
            type = .jump
        } else if target == destination {
            type = .stay
        } else {
            type = .simple
        }
    }

    static func ==(lhs: Move, rhs: Move) -> Bool {
        // True if all the elements are the same
        return lhs.jump == rhs.jump && lhs.destination == rhs.destination && lhs.target == rhs.target
    }
}
