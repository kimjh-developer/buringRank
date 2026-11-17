//
//  ControlView.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/14/24.
//

import SwiftUI

struct ControlView: View {
    @Binding var Gohome : Bool
    @State var nowSaving:Bool = false
    @EnvironmentObject var workoutManager : WorkoutManager
    
    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                // End Workout
                VStack(spacing: 8) {
                    Button(action: {
                        withAnimation {
                            nowSaving = true
                            workoutManager.endWorkout()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 60, height: 60)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Text("종료")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                }
                
                // Pause / Resume
                VStack(spacing: 8) {
                    Button(action: {
                        withAnimation {
                            workoutManager.togglePause()
                        }
                    }) {
                        Image(systemName: workoutManager.running ? "pause.fill" : "play.fill")
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 60, height: 60)
                            .background(workoutManager.running ? Color.white.opacity(0.1) : WatchTheme.primaryOrange.opacity(0.2))
                            .foregroundColor(workoutManager.running ? .white : WatchTheme.primaryOrange)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Text(workoutManager.running ? "일시정지" : "계속")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(workoutManager.running ? .white : WatchTheme.primaryOrange)
                }
            }
            
            if nowSaving {
                ZStack {
                    WatchTheme.background.opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(WatchTheme.primaryOrange)
                        Text("운동 기록 저장 중")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onChange(of: workoutManager.showingSummaryView) { oldValue, newValue in
            if newValue {
                self.Gohome.toggle()
            }
        }
    }
}

#Preview {
    ControlView(Gohome: .constant(true))
}
