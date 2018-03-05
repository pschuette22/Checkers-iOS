//
//  Move.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/3/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation

struct Move: Equatable {

    let target: TileIndex!
    let destination: TileIndex!
    let jump: TileIndex?

    init(target: TileIndex, destination: TileIndex, jump: TileIndex?) {
        self.target = target
        self.destination = destination
        self.jump = jump
    }

    static func ==(lhs: Move, rhs: Move) -> Bool {
        // True if all the elements are the same
        return lhs.destination == rhs.destination && lhs.target == rhs.target && lhs.jump == rhs.jump
    }
}
