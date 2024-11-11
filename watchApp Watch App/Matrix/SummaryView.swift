//
//  SummaryView.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/14/24.
//

import SwiftUI
import HealthKit
struct SummaryView: View {
    @EnvironmentObject var workoutManager : WorkoutManager
    @Environment(\.dismiss) var dismiss
    @State private var durationFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour,.minute,.second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var body: some View {
        if workoutManager.selectedWorkout == nil{
            ProgressView("운동을 저장중입니다.")
                .navigationBarHidden(true)
        }else{
            VStack {
                ScrollView {
                    VStack(spacing: 15) {
                        singleRow(title: "운동 시간", content:
                                    durationFormatter.string(from:workoutManager.workout?.duration ?? 0.0) ?? "")
                        if workoutManager.selectedWorkout == .hiking || workoutManager.selectedWorkout == .running{
                            singleRow(title: "이동 거리",
                                      content: Measurement(value: workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0, unit: UnitLength.meters).formatted(.measurement(width: .abbreviated,usage: .road)),measure: "m")
                        }
                    
                    singleRow(title: "최고 심박수", content: "170",fColor: Color.themeRed,measure: "BPM")
                    singleRow(title: "소모 칼로리", content: 1231.addComma(),measure: "KCAL")
                        ActivityRingView(healthStore: workoutManager.healthStore)
                            .frame(width: 50, height: 50)
                        
                        Btn(defaultString: "버랭업 완료", fontsize: 20, fontcolor: .white, defaultColor: Color.btnActivate)
                            .padding(.vertical)
                            .onTapGesture {
                                dismiss()
                            }
                }
                    
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
