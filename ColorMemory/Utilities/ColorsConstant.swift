//
//  ColorsConstant.swift
//  ColorMemory
//
//  Created by ArunPrasanth R on 25/01/16.
//  Copyright © 2016 ArunPrasanth R. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<self.count
        {
            sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}

extension String
{
    func trimWhite() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

let NAME = "name"
let SCORE = "score"
let DATE = "date"
