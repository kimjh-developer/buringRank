//
//  SelectWorkoutLevel.swift
//  iphoneapp
//
//  Created by mac on 10/21/24.
//

import SwiftUI

struct SelectWorkoutLevel: View {
    @EnvironmentObject var workoutManager : WorkoutManager
    @Binding var workoutDone : Bool
    @State private var moveNext : Bool = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                if let selectedWorkout = workoutManager.selectedWorkout{
                    HStack{
                        selectedWorkout.icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25)
                        Text("운동 강도를 선택해주세요")
                            .style(fontName: .kbold, fontSize: 25, fontColor: .white)
                    }
                    
                    ScrollView {
                        switch selectedWorkout{
                        case .functionalStrengthTraining:functionalStrengthTraining()
                        case .running : running()
                        case .hiking : hiking()
                        case .mindAndBody : mindAndBody()
                        default : EmptyView()
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        moveNext.toggle()
                    } label: {
                        Btn(defaultString: workoutManager.workoutLevel == nil ? "선택하세요" : "갓쮸아!!", fontsize: 25, fontcolor: .white, defaultColor: workoutManager.workoutLevel == nil ? Color.btnInactivate : Color.themeRed)
                            .cornerRadius(50)
                    }
                    .padding(.bottom, 30) // Adjusted for navigation bar
                }
            }
        }
        .navigationDestination(isPresented: $moveNext) {
            if workoutManager.selectedWorkout == .functionalStrengthTraining {
                Counter()
            } else {
                Onworkout(workoutDone: $workoutDone)
            }
        }
        
    }
    // MARK: - 쇠질
    @ViewBuilder
    private func functionalStrengthTraining() -> some View{
        ForEach(FunctionWorkLevel.allCases, id: \.self) { item in
            Button {
                workoutManager.workoutLevel = nil
                workoutManager.workoutLevel = WorkoutLevel(fLevel: item)
            } label: {
                row(title: item.name, content: item.detail,isActivate: workoutManager.workoutLevel?.fLevel == item)
            }
        }
    }
    // MARK: - 달리기
    @ViewBuilder
    private func running() -> some View{
        ForEach(CardioLevel.allCases, id: \.self) { item in
            Button {
                workoutManager.workoutLevel = nil
                workoutManager.workoutLevel = WorkoutLevel(cLevel: item)
            } label: {
                row(title: item.name, content: item.detail,isActivate: workoutManager.workoutLevel?.cLevel == item)
            }
        }
    }
    // MARK: - 달리기
    @ViewBuilder
    private func hiking() -> some View{
        ForEach(HikeLevel.allCases, id: \.self) { item in
            Button {
                workoutManager.workoutLevel = nil
                workoutManager.workoutLevel = WorkoutLevel(hLevel: item)
            } label: {
                row(title: item.name, content: item.detail,isActivate: workoutManager.workoutLevel?.hLevel == item)
            }
        }
    }
    // MARK: - 숨쉬기
    @ViewBuilder
    private func mindAndBody() -> some View{
        ForEach(MeditationLevel.allCases, id: \.self) { item in
            Button {
                workoutManager.workoutLevel = nil
                workoutManager.workoutLevel = WorkoutLevel(mLevel: item)
            } label: {
                row(title: item.name, content: item.detail,isActivate: workoutManager.workoutLevel?.mLevel == item)
            }
        }
    }
    
    // MARK: - rowItem
    @ViewBuilder
    private func row(title:String,content:String,isActivate : Bool = false) -> some View{
        VStack(spacing:10) {
            Text(title)
                .style(fontName: .kbold, fontSize: 25, fontColor: isActivate ? Color.themeRed : .white)
                .frame(maxWidth: .infinity,alignment: .leading)
            Text(content)
                .style(fontName: .kmedium, fontSize: 22, fontColor: isActivate ? Color.themeRed : .white)
                .frame(maxWidth: .infinity,alignment: .leading)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActivate ? Color.themeRed : .white, lineWidth: 2.0)
        }
        .padding(5)
    }
}

#Preview {
    SelectWorkoutLevel(workoutDone: .constant(true))
        .environmentObject(WorkoutManager())
}

