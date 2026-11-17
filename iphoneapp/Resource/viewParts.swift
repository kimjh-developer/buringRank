//
//  viewParts.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/11/24.
//

import SwiftUI

struct Btn: View {
    var defaultString:String = "선택"
    var fontsize : CGFloat = 25
    var fontcolor : Color = .white
    var defaultColor : Color
    var body: some View {
        Text(defaultString)
            .style(fontName: .kmedium, fontSize: fontsize, fontColor: fontcolor)
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(defaultColor)
                    
            }
    }
}


