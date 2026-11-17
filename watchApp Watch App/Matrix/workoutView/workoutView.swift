//
//  workoutView.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/14/24.
//

import SwiftUI

struct workoutView: View {
    @EnvironmentObject var workoutManager : WorkoutManager
    @StateObject var vm: workoutViewVM

        // ViewModel을 외부에서 전달할 수 있는 생성자
    init(vm: workoutViewVM) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        circleView()
            .ignoresSafeArea()
    }
    
    // MARK: - 서클뷰
    @ViewBuilder
    private func circleView() -> some View{
        GeometryReader { geometry in
            let sizeMin = min(geometry.size.width, geometry.size.height) // 너비와 높이 중 작은 값으로 설정
            let strokeWidth: CGFloat = sizeMin/4.4 // Set stroke width to 40
            let adjustedSize = sizeMin - strokeWidth // Adjust size to account for stroke

            ZStack {
                Circle()
                    .stroke(LinearGradient(colors: vm.CircleColor.colors, startPoint: .top, endPoint: .bottom), lineWidth: strokeWidth)
                    .frame(width: adjustedSize, height: adjustedSize) // Adjust size to prevent stroke from overflowing
                
                ZStack {
                    ZStack(alignment: .top) {
                        Color.clear
                        vm.workoutManager.selectedWorkout?.icon
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle( vm.CircleColor == .yellowCircle || vm.CircleColor == .blueCircle || vm.CircleColor == .orangeCircle ? .black : .white)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            
                            
                    }
                    
                    if workoutManager.selectedWorkout == .running || workoutManager.selectedWorkout == .hiking{
                        ZStack(alignment: .leading) {
                            Color.clear
                            VStack(spacing: 0) {
                                Text(workoutManager.distanceWalkingRunning.toString(withDecimalPlaces: 1))
                                    .style(fontName: .player, fontSize: 25, fontColor: vm.CircleColor == .yellowCircle || vm.CircleColor == .blueCircle || vm.CircleColor == .orangeCircle ? .black : .white)
                                Text("km")
                                    .style(fontName: .player, fontSize: 10, fontColor: vm.CircleColor == .yellowCircle || vm.CircleColor == .blueCircle || vm.CircleColor == .orangeCircle ? .black : .white)
                            }
                        }
                        .padding(sizeMin*0.0001)
                        
                        ZStack(alignment: .trailing) {
                                Color.clear
                            VStack(spacing: 0) {
                                Text(workoutManager.speed?.toString(withDecimalPlaces: 0) ?? "0")
                                        .style(fontName: .player, fontSize: 25, fontColor: vm.CircleColor == .yellowCircle || vm.CircleColor == .blueCircle || vm.CircleColor == .orangeCircle ? .black : .white)
                                Text("m/s")
                                        .style(fontName: .player, fontSize: 10, fontColor: vm.CircleColor == .yellowCircle || vm.CircleColor == .blueCircle || vm.CircleColor == .orangeCircle ? .black : .white)
                                }
                        }
                        .padding(sizeMin/40)
                    }
                    
                    
                    TimelineView(MetricsTimelineScheeule(startDate: workoutManager.builder?.startDate ?? Date())) { context in
                        ZStack(alignment: .bottom) {
                            Color.clear
                            
                            ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime ?? 0,
                                            showSubseconds: context.cadence == .live ,
                                            fontName: .player,fontSize: 25,fontColor: vm.CircleColor == .yellowCircle || vm.CircleColor == .blueCircle || vm.CircleColor == .orangeCircle ? .black : .white)
                        }
                        .padding()
                    }
                    
                    
                    
                    
                    VStack {
                        Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))))
                            .style(fontName: .player, fontSize: 40, fontColor: .white)
                        Text("bpm")
                            .style(fontName: .player, fontSize: 20, fontColor: .white)
                    }
                    .onChange(of: workoutManager.heartRate) { oldValue, newValue in
                        vm.changeCircleColor(heartRate: newValue)
                    }
                }
                //여기
                .padding(5)
                .frame(width: sizeMin, height: sizeMin) // width와 height를 동일하게 설정하여 정사각형 유지
                
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // 중앙에 위치
            
        }
    }
}

#Preview {
    workoutView(vm: workoutViewVM(workoutManager: WorkoutManager()))
        .environmentObject(WorkoutManager())
}
private struct MetricsTimelineScheeule : TimelineSchedule{
    var startDate : Date
    
    init(startDate: Date) {
        self.startDate = startDate
    }
    
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: self.startDate,
                                 by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0)).entries(from: startDate, mode: mode)
    }
    
}

