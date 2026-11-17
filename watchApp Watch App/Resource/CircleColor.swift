//
//  CircleColor.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/14/24.
//

import Foundation
import SwiftUI
enum CircleColor{
    case grayCircle,yellowCircle,blueCircle,orangeCircle,redCircle
    
    var colors:Array<Color>{
        switch self{
            case .grayCircle : return [Color.grayTop,Color.grayBottom]
            case .yellowCircle : return [Color.yellowTop,Color.yellowBottom]
            case .blueCircle : return [Color.blueTop,Color.blueBottom]
            case .orangeCircle : return [Color.orangeTop,Color.orangeBottom]
            case .redCircle : return [Color.redTop,Color.redBottom]
        }
    }
}
