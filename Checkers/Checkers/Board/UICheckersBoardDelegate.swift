//
//  UICheckersBoardDelegate.swift
//  Checkers
//
//  Created by Schuette, Peter on 3/1/18.
//  Copyright © 2018 Zeppa. All rights reserved.
//

import Foundation

protocol UICheckersBoardDelegate {

    func getTitle(x: Int, y: Int) -> Tile

}
