//
//  ElapsedTimeView.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/14/24.
//

import SwiftUI

struct ElapsedTimeView: View {
    var elapsedTime : TimeInterval = 0
    var showSubseconds : Bool = true
    var fontName : StringType = .kmedium
    var fontSize : CGFloat = 12
    var fontColor : Color = .white

    @State private var timeFormatter = ElapsedTimeFormatter()
    var body: some View {
        Text(NSNumber(value:elapsedTime),formatter: timeFormatter)
            .style(fontName: fontName, fontSize: fontSize, fontColor: fontColor)
            .onChange(of: showSubseconds) { _, newValue in
                timeFormatter.showSubseconds = newValue
            }
    }
}

#Preview {
    ElapsedTimeView()
}

class ElapsedTimeFormatter : Formatter{
    let componentsFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute,.second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var showSubseconds = true
    
    override func string(for value:Any?) ->String?{
        guard let time = value as? TimeInterval else {return nil}
        
        guard let formattedString = componentsFormatter.string(from: time) else {return nil}
        
        if showSubseconds{
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1))*100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString,decimalSeparator, hundredths)
        }
        return formattedString
    }
    
}


