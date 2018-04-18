//
//  GameEngineDelegate.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/3/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation

/// Delegate for responding to game actions
protocol GameEngineDelegate: class {
    
    var board: CheckersBoard! { get }
    
    func player(going direction: Direction) -> Player

    func selectIgnored(_ message: String)

    func didUnselectTile(at index: TileIndex, with moves: [Move])

    func didStartTurn(at index: TileIndex, with moves: [Move])

    func didMove(_ move: Move, ignoring otherMoves: [Move])

    func didFinishGame(_ winner: Player)
    
    func turnDidStart(for player: Player)
}
