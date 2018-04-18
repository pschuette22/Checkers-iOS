//
//  Tile.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/3/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation

enum TileColor {
    case black
    case white
}

enum TilePiece {
    case outOfPlay
    case empty
    case pawn
    case king
}

class Tile {

    let color: TileColor
    var piece: TilePiece
    var owner: Player? {
        didSet {
            if piece != .outOfPlay {
                piece = .empty
            }
        }
    }

    init(color: TileColor, piece: TilePiece, owner: Player?) {
        self.color = color
        self.piece = piece
        self.owner = owner
    }
    
    init(tile: Tile) {
        self.color = tile.color
        self.owner = tile.owner
        self.piece = tile.piece
    }
}
