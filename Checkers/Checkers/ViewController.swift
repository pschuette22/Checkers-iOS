//
//  ViewController.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/1/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICheckersBoardDelegate {

    var boardView: UICheckersBoard!
    let board = CheckersBoard()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        drawInitialBoard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func drawInitialBoard() {

        let topPadding = UIApplication.shared.statusBarFrame.size.height + 8

        // Top padding of 8, side padding 0. Must be a square
        var maxHeight = self.view.frame.height - topPadding
        var maxWidth = self.view.frame.width

        if (maxHeight > maxWidth) {
            maxHeight = maxWidth
        } else {
            maxWidth = maxHeight
        }

        let leftPadding = (self.view.frame.width - maxWidth) / 2

        let frame = CGRect(x: leftPadding, y: topPadding, width: maxWidth, height: maxHeight)
        boardView = UICheckersBoard(frame: frame, delegate: self)
        self.view.addSubview(boardView)

    }

}

// MARK: - UICheckersBoardDelegate methods
extension ViewController {

    func getTitle(x: Int, y: Int) -> Tile {
        return board.getTile(x:x, y:y)
    }

}
