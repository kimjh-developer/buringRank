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
        if workoutManager.selectedWorkout == nil {
            ProgressView("운동 기록 저장 중...")
                .navigationBarHidden(true)
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    Text("운동 완료")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(WatchTheme.primaryOrange)
                        .padding(.top)
                    
                    VStack(spacing: 12) {
                        summaryRow(title: "운동 시간", value: durationFormatter.string(from: workoutManager.workout?.duration ?? 0.0) ?? "00:00:00")
                        
                        if workoutManager.selectedWorkout == .hiking || workoutManager.selectedWorkout == .running {
                            summaryRow(title: "이동 거리", value: String(format: "%.2f km", (workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0) / 1000))
                        }
                        
                        summaryRow(title: "소모 칼로리", value: "\(Int(workoutManager.workout?.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)) kcal")
                        
                        summaryRow(title: "평균 심박수", value: "142 bpm") // Mocked average
                    }
                    .padding()
                    .background(WatchTheme.surface)
                    .cornerRadius(20)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("버랭업 완료")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(WatchTheme.burningGradient.colors.first)
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SummaryView()
}
