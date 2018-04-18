//
//  AIStrategyDelegate.swift
//  Checkers
//
//  Created by Schuette, Peter on 4/7/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation


protocol AIStrategyDelegate: class {
    
    var board: CheckersBoard! { get }
    
    var engine: GameEngine! { get }
    
    func otherPlayer(player: Player) -> Player
    
}
