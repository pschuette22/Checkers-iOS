//
//  UIBoardTile.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/1/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation
import UIKit

class UIBoardTile: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UIBoardTile {

    /// Draw the tile based on the color and piece
    ///
    /// - Parameter tile: <#tile description#>
    func doDraw(tile: Tile) {

        switch (tile.color) {
        case .black:
            self.backgroundColor = UIColor.black
        case .white:
            self.backgroundColor = UIColor.white
        }

        // TODO: draw over the tile with the piece value

    }

}
