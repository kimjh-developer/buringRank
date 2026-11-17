//
//  ChooseDificulty.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/10/24.
//

import SwiftUI
import HealthKit

struct ChooseDificulty: View {
    var hKWorkoutActivityType : HKWorkoutActivityType
    @Binding var Gohome : Bool
    @EnvironmentObject var workoutManager : WorkoutManager
    @State var isSelected : Bool = false
    @State var moveNext : Bool = false
    
    let grids : [GridItem] = [GridItem(.flexible(),spacing: 12),GridItem(.flexible(),spacing: 12)]
    
    init(hKWorkoutActivityType: HKWorkoutActivityType, Gohome: Binding<Bool>) {
        self.hKWorkoutActivityType = hKWorkoutActivityType
        self._Gohome = Gohome
    }
    
    var body: some View {
        VStack {
            Text("강도 선택")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            ScrollView {
                switch hKWorkoutActivityType {
                case .functionalStrengthTraining : gridMatrix(Fitem: .bulkup)
                case .running : gridMatrix(Citem: .level1)
                case .hiking : gridMatrix(Hitem: .lowLevel)
                case .mindAndBody : gridMatrix(Mitem: .normalLevel)
                default: EmptyView()
                }
                
                Spacer(minLength: 20)
                
                Button(action: {
                    if isSelected { moveNext = true }
                }) {
                    Text(isSelected ? "준비 완료" : "강도를 선택하세요")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(isSelected ? WatchTheme.primaryRed : .gray)
                .disabled(!isSelected)
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            if hKWorkoutActivityType == .running || hKWorkoutActivityType == .hiking {
                workoutManager.requestLocationAuthorization()
            }
        }
        .navigationTitle("")
        .navigationDestination(isPresented: $moveNext) {
            TimerCount(Gohome: $Gohome)
        }
    }
    
    @ViewBuilder
    private func gridMatrix(
        Fitem : FunctionWorkLevel? = nil,
        Citem : CardioLevel? = nil,
        Hitem : HikeLevel? = nil,
        Mitem : MeditationLevel? = nil
    ) -> some View {
        LazyVGrid(columns: grids, spacing: 12) {
            if let _ = Fitem {
                ForEach(FunctionWorkLevel.allCases, id: \.self) { item in
                    gridCell(title: item.name, low: item.lowLevel, high: item.highLevel, isActivate: item == workoutManager.workoutLevel?.fLevel)
                        .onTapGesture {
                            withAnimation {
                                workoutManager.workoutLevel = WorkoutLevel(fLevel: item)
                                isSelected = true
                            }
                        }
                }
            }
            if let _ = Citem {
                ForEach(CardioLevel.allCases, id: \.self) { item in
                    gridCell(title: item.name, low: item.lowLevel, high: item.highLevel, isActivate: item == workoutManager.workoutLevel?.cLevel)
                        .onTapGesture {
                            withAnimation {
                                workoutManager.workoutLevel = WorkoutLevel(cLevel: item)
                                isSelected = true
                            }
                        }
                }
            }
            // ... Hiking and Meditation similar patterns ...
            if let _ = Hitem {
                ForEach(HikeLevel.allCases, id: \.self) { item in
                    gridCell(title: item.name, low: item.lowLevel, high: item.highLevel, isActivate: item == workoutManager.workoutLevel?.hLevel)
                        .onTapGesture {
                            withAnimation {
                                workoutManager.workoutLevel = WorkoutLevel(hLevel: item)
                                isSelected = true
                            }
                        }
                }
            }
            if let _ = Mitem {
                ForEach(MeditationLevel.allCases, id: \.self) { item in
                    gridCell(title: item.name, low: item.lowLevel, high: item.highLevel, isActivate: item == workoutManager.workoutLevel?.mLevel)
                        .onTapGesture {
                            withAnimation {
                                workoutManager.workoutLevel = WorkoutLevel(mLevel: item)
                                isSelected = true
                            }
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func gridCell(title: String, low: Double, high: Double, isActivate: Bool) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: isActivate ? .bold : .medium))
                .foregroundColor(isActivate ? .white : .white.opacity(0.8))
            
            if let baselineHeartRate = workoutManager.baselineHeartRate {
                Text("\((baselineHeartRate*low/100).toString(withDecimalPlaces:0))~\((baselineHeartRate*high/100).toString(withDecimalPlaces:0))")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(isActivate ? .white : .white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            if isActivate {
                WatchTheme.burningGradient
                    .cornerRadius(12)
            } else {
                WatchTheme.surface
                    .cornerRadius(12)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActivate ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    ChooseDificulty(hKWorkoutActivityType: .functionalStrengthTraining, Gohome: .constant(true))
        .environmentObject(WorkoutManager())
}

