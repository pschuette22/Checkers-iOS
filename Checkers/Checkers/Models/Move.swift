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

struct Move: Equatable {

    let target: TileIndex!
    let destination: TileIndex!
    // List of indexes that were jumped during this turn
    let jumps: [TileIndex]?

    let type: MoveType

    init(target: TileIndex, destination: TileIndex, jumps: [TileIndex]?) {
        self.target = target
        self.destination = destination
        self.jumps = jumps

        if jumps?.count ?? 0 > 0 {
            type = .jump
        } else if target == destination {
            type = .stay
        } else {
            type = .simple
        }
    }

    static func ==(lhs: Move, rhs: Move) -> Bool {
        // True if all the elements are the same
        if let lhsJumps = lhs.jumps, lhsJumps.count == rhs.jumps?.count ?? 0 {
            for jump in lhsJumps {
                if !(rhs.jumps?.contains(jump) ?? false) {
                    return false
                }
            }
        }
        return lhs.destination == rhs.destination && lhs.target == rhs.target
    }
}
