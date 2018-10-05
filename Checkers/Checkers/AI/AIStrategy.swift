//
//  Strategy.swift
//  Checkers
//
//  Created by Schuette, Peter on 4/7/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation



/// Class responsible for carrying out the strategy of an AI Player
class AIStrategy {
    
    /// AIPlayer strategy is for
    weak var player: AIPlayer?

    /// Strategy delegate for retrieving game info
    weak var delegate: AIStrategyDelegate?
    
    let weights: [String: Double]

    let depth = 4
    
    let topMovePruning = 5
    
    let bottomMovePruning = 5
    
    // The board strength delta needed before a potential move to be considered
    // This is relative to the "best" potential move per back and
    let pruningDelta = 3
    
    
    /// Initialize the strategy for the AI Player
    ///
    /// - Parameter delegate: delegate class for retrieving components needed in carrying out a strategy
    init(delegate: AIStrategyDelegate) {
        self.delegate = delegate
        // TODO: add weight parameters for the strategy
        // This will include piece, cluster, location, futures, etc.
        // Hard coded for now
        weights = [
            "pawn": 1.0,
            "king": 2.5,
            "futureWeight": 0.85,
        ]
    }
    
}

extension AIStrategy {
    
    func myBoardScore() -> Double {
        return boardScore(for: player!)
    }
    
    func opponentBoardScore() -> Double {
        let other = delegate!.otherPlayer(player: player!)
        return boardScore(for: other)
    }
    
    func boardScore(for player: Player) -> Double {
        guard let tiles = self.delegate?.board.tiles(for: player) else {
            return 0
        }
        
        var score = 0.0
        let pawnWeight = weights["pawn"]!
        let kingWeight = weights["king"]!
        for tile in tiles {
            switch tile.tile.piece {
            case .king:
                score += kingWeight
            case .pawn:
                score += pawnWeight
            default:
                print("tried calculating tile weight for an unowned tile")
            }
        }
        return score
    }
    
    func findBestMove() -> AIPotentialMove? {
        
        guard let board = delegate?.board, let other = self.delegate?.otherPlayer(player: player!) else {
            return nil
        }
        
        let startingState = CheckersBoard(board: board)
        
        let firstLevel = AIThoughtLevel(strategy: self, boardState: startingState, active: player!, other: other, level: 0, myBoardScore: boardScore(for: player!), opponentBoardScore: boardScore(for: other))
        
        // Builds a tree of potential moves this AI could make
        firstLevel.buildPotentialMoves()
        
        return firstLevel.potentialMoves.sorted(by: { (move1, move2) -> Bool in
            return move1.calculateTotalScore() >= move2.calculateTotalScore()
        }).first
    }
    
}



/// Class that evaluates each level of thought for the AI at a given board state
class AIThoughtLevel {
    
    weak var strategy: AIStrategy?
    let boardState: CheckersBoard
    let active: Player
    let other: Player
    let level: Int
    
    let myBoardScore: Double
    let opponentBoardScore: Double
    
    var potentialMoves = [AIPotentialMove]()
    
    /// Initialize the thought level
    ///
    /// - Parameters:
    ///   - strategy: move strategy for this AI
    ///   - boardState: state of the board coming into this
    ///   - active: active player during this turn
    ///   - other: other player during this turn
    ///   - level: level of recursion
    init(strategy: AIStrategy, boardState: CheckersBoard, active: Player, other: Player, level: Int, myBoardScore: Double, opponentBoardScore: Double) {
        print("init ThoughtLevel with level \(level)")
        self.strategy = strategy
        self.boardState = boardState
        self.active = active
        self.other = other
        self.level = level
        self.myBoardScore = myBoardScore
        self.opponentBoardScore = opponentBoardScore
    }
    
    
    func buildPotentialMoves() {
        
        // Retrieve the tiles owned by this player
        let tiles = boardState.tiles(for: active)
        
        for item in tiles {
//            let tile = item.tile
            let index = item.index
            guard let moves = strategy?.delegate?.engine.calculateMoves(for: active, in: boardState, at: index, jumpsOnly: false), !moves.isEmpty else {
                continue
            }
            
            // These are all possible moves the AI could make from this game state
            // Wrap this as a potential
            for move in moves {
                let movePotentials = buildPotentialMoves(from: move, with: boardState, priorMoves: nil, myBoardScore: myBoardScore, opponentBoardScore: opponentBoardScore)
                potentialMoves.append(contentsOf: movePotentials)
            }
        }
        
        // If there should be more levels to this, build them
        if level >= strategy?.depth ?? 0 {
            return
        }

        // Prune the potential moves
        potentialMoves.sort { (lhs, rhs) -> Bool in
            return lhs.netScore > rhs.netScore
        }
        
        // Do Alpha Beta move pruning.
        
        
        let topMovePruning = strategy?.topMovePruning ?? 0
        let bottomMovePruning = strategy?.bottomMovePruning ?? 0
        
        if potentialMoves.count > topMovePruning + bottomMovePruning {
            
            // Remove the medium value moves that are out of top move range
            potentialMoves.removeSubrange(topMovePruning+1..<potentialMoves.count-bottomMovePruning)
            potentialMoves.remove(at: topMovePruning + 1)
        }
        
        for potentialMove in potentialMoves where !potentialMove.isEndOfGame() {
            potentialMove.buildNextLevel()
        }

    }
    
    func weightedAverageMoveScore() -> Double {
        // Average out the potential scores
        var total = 0.0
        for potentialMove in potentialMoves {
            total += potentialMove.calculateTotalScore()
        }
        total /= Double(potentialMoves.count)
        
        if level > 0, let futuresWeigth = self.strategy?.weights["future"] {
            // If this is not the base level,
            // Weight the scores
            total *= pow(futuresWeigth, Double(level))
        }
        
        return total
    }
    

    private func buildPotentialMoves(from move: Move, with boardState: CheckersBoard, priorMoves: [Move]?, myBoardScore: Double, opponentBoardScore: Double) -> [AIPotentialMove] {
    
        var results = [AIPotentialMove]()
        
        // Copy the state of the board and move
        let resultState = CheckersBoard(board: boardState)
        resultState.player(active, did: move)
        
        var moveChain = [Move]()
        if let _priorMove = priorMoves {
            moveChain.append(contentsOf: _priorMove)
        }
        moveChain.append(move)
        
        var _myBoardScore = myBoardScore
        var _opponentBoardScore = opponentBoardScore
        
        if boardState.isKingingTile(at: move.target, for: active) {
            let scoreDelta = strategy!.weights["king"]! - strategy!.weights["pawn"]!
            if self.active == self.strategy?.player {
                _myBoardScore += scoreDelta
            } else {
                _opponentBoardScore += scoreDelta
            }
        }
        
        if let jumpIndex = move.jump {
            let jumped = boardState.tile(at: jumpIndex)
            
            let pieceWeight = jumped.piece == .king ? strategy!.weights["king"]! : strategy!.weights["pawn"]!
            
            if self.active == self.strategy?.player {
                _opponentBoardScore -= pieceWeight
            } else {
                _myBoardScore -= pieceWeight
            }
            
            if let chainMoves = strategy?.delegate?.engine.calculateMoves(for: active, in: resultState, at: move.destination, jumpsOnly: true),
                !chainMoves.isEmpty {
                for chainMove in chainMoves {
                    let childPotentials = buildPotentialMoves(from: chainMove, with: resultState, priorMoves: moveChain, myBoardScore: _myBoardScore, opponentBoardScore: _opponentBoardScore)
                    results.append(contentsOf: childPotentials)
                }
                
                // Add the stay move potential
                let stayMove = Move(target: move.destination, destination: move.destination, jump: nil)
                var copyChain = [Move]()
                copyChain.append(contentsOf: moveChain)
                copyChain.append(stayMove)
                results.append(AIPotentialMove(thoughtLevel: self, moveQueue: copyChain, result: resultState, myBoardScore: _myBoardScore, opponentBoardScore: _opponentBoardScore))
                // Early return
                return results
            }
        }
        
        let potentialMove = AIPotentialMove(thoughtLevel: self, moveQueue: moveChain, result: resultState, myBoardScore: _myBoardScore, opponentBoardScore: _opponentBoardScore)
        results.append(potentialMove)
        
        return results
    }
    
}


/// Wrapper class for a potential move, it's result, and a scoring index
class AIPotentialMove {
    
    // The level at this move
    weak var thoughtLevel: AIThoughtLevel?
    var nextThoughtLevel: AIThoughtLevel?
    let moveQueue: [Move] // Needed for multi-jump moves
    let resultBoard: CheckersBoard // State of the board after this move
    
    private let myBoardScore: Double
    private let opponentBoardScore: Double
    let netScore: Double
    
    var totalScore: Double?
    
    init(thoughtLevel: AIThoughtLevel, moveQueue: [Move], result: CheckersBoard, myBoardScore: Double, opponentBoardScore: Double) {
        self.thoughtLevel = thoughtLevel
        self.moveQueue = moveQueue
        self.resultBoard = result
        self.myBoardScore = myBoardScore
        self.opponentBoardScore = opponentBoardScore
        self.netScore = myBoardScore - opponentBoardScore
    }
    
    func isEndOfGame() -> Bool {
        return opponentBoardScore == 0.0 || myBoardScore == 0.0
    }

    func buildNextLevel() {
        
        guard let _strategy = thoughtLevel?.strategy,
            // Switch active and other as it is the next players turn
            let activePlayer = thoughtLevel?.other,
            let otherPlayer = thoughtLevel?.active,
            let level = thoughtLevel?.level else {
            return
        }
        self.nextThoughtLevel = AIThoughtLevel(strategy: _strategy, boardState: resultBoard, active: activePlayer, other: otherPlayer, level: level + 1, myBoardScore: self.myBoardScore, opponentBoardScore: self.opponentBoardScore)
        self.nextThoughtLevel?.buildPotentialMoves()
    }
    
    func calculateTotalScore() -> Double {
        
        // If already calculated, return it
        if let _totalScore = totalScore {
            return _totalScore
        }
        
        guard let childScores = self.nextThoughtLevel?.weightedAverageMoveScore() else {
            totalScore = netScore
            return netScore
        }
        // Average this move score and the weighted child scores together
        totalScore = (netScore + childScores) / 2
        
        return totalScore!
    }
    
}
