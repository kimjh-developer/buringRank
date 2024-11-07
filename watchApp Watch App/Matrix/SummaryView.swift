//
//  SummaryView.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/14/24.
//

import SwiftUI
import HealthKit
struct SummaryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var durationFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour,.minute,.second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var body: some View {
            VStack {
                ScrollView {
                    VStack(spacing: 15) {
                    singleRow(title: "운동 시간", content: "00:58:24")
                    singleRow(title: "이동 거리", content: 10.addComma(),measure: "km")
                    singleRow(title: "최고 심박수", content: "170",fColor: Color.themeRed,measure: "BPM")
                    singleRow(title: "소모 칼로리", content: 1231.addComma(),measure: "KCAL")
                        ActivityRingView(healthStore: HKHealthStore())
                            .frame(width: 50, height: 50)
                }
                    
                Btn(defaultString: "버랭업 완료", fontsize: 20, fontcolor: .white, defaultColor: Color.btnActivate)
                    .padding(.vertical)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
    }
    // MARK: - 제목 내용라인
    @ViewBuilder
    private func singleRow(title:String,content:String,fColor:Color = .white,measure:String? = nil) -> some View{
        HStack {
            Text(title)
                .style(fontName: .kmedium, fontSize: 14, fontColor: .white)
            Spacer()
            Text(content)
                .style(fontName: .kmedium, fontSize: 14, fontColor: fColor)
            if let value = measure{
                Text(value)
                    .style(fontName: .kmedium, fontSize: 14, fontColor: .white)
            }
            
        }
    }
}

#Preview {
    SummaryView()
}
