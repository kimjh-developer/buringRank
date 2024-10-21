//
//  StringExt.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/9/24.
//

import Foundation
import SwiftUI

enum StringType{
    case klight,kmedium,kbold,player
    var name : String{
        switch self {
            case .klight: return "KBO-Dia-Gothic-Light"
            case .kmedium: return "KBO-Dia-Gothic-Medium"
            case .kbold: return "KBO-Dia-Gothic-Bold"
            case .player: return "I-AM-A-PLAYER"
        }
    }
}

extension Text {
    func style(fontName: StringType, fontSize: CGFloat = 24, fontColor: Color = .black) -> some View {
        self
            .font(Font.custom(fontName.name, size: fontSize))
            .foregroundColor(fontColor)
    }
}




