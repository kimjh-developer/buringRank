//
//  MatrixView.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/14/24.
//

import SwiftUI
import WatchKit
import HealthKit
struct MatrixView: View {
    @EnvironmentObject var workoutManager : WorkoutManager
    @Binding var Gohome : Bool
    @State private var selection : Tab = .workouts
    @State private var showingSummaryView : Bool = false
    enum Tab{
        case controls,workouts,nowPlay
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                ControlView(Gohome: $Gohome).tag(Tab.controls)
                workoutView(vm: workoutViewVM(workoutManager: workoutManager)).tag(Tab.workouts)
                NowPlayingView().tag(Tab.nowPlay)
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        .onAppear(perform: {
            if let selectedWorkout = workoutManager.selectedWorkout{
                workoutManager.startWorkout(workoutType: selectedWorkout)
            }
        })
        .onChange(of: workoutManager.running) { oldValue, newValue in
            if newValue{
                displayWorkoutView()
            }
        }
        .onChange(of: workoutManager.workout) { oldValue, newValue in
            if newValue != nil{
                showingSummaryView = true
            }
        }
    }
    
    private func displayWorkoutView(){
        withAnimation {
            selection = .workouts
        }
    }
}

#Preview {
    MatrixView(Gohome: .constant(true))
        .environmentObject(WorkoutManager())
}



