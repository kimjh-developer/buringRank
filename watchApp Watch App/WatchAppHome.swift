//
//  WatchAppHome.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/9/24.
//

import SwiftUI
import HealthKit

struct WatchAppHome: View {
    @EnvironmentObject var workoutManager : WorkoutManager
    let grids : [GridItem] = [GridItem(.flexible(),spacing: 12),GridItem(.flexible(),spacing: 12)]
    var workoutTypes : [HKWorkoutActivityType] = [.functionalStrengthTraining,.running,.hiking,.mindAndBody,]
    @State var moveNext : Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("운동 타입 선택")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                
                ScrollView {
                    LazyVGrid(columns: grids, spacing: 12) {
                        ForEach(workoutTypes, id: \.self) { item in
                            cell(type: item)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    Button(action: {
                        if workoutManager.selectedWorkout != nil {
                            moveNext = true
                        }
                    }) {
                        Text("다음 단계로")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(workoutManager.selectedWorkout == nil ? .gray : WatchTheme.primaryRed)
                    .disabled(workoutManager.selectedWorkout == null)
                }
            }
            .padding(.horizontal, 8)
            .navigationDestination(isPresented: $moveNext) {
                if let type = workoutManager.selectedWorkout {
                    ChooseDificulty(hKWorkoutActivityType: type, Gohome: $moveNext)
                }
            }
        }
    }
    
    @ViewBuilder
    private func cell(type: HKWorkoutActivityType) -> some View {
        let isSelected = (type == workoutManager.selectedWorkout)
        
        VStack(spacing: 8) {
            type.icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 28)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            
            Text(type.name)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            if isSelected {
                WatchTheme.burningGradient
                    .cornerRadius(16)
            } else {
                WatchTheme.surface
                    .cornerRadius(16)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            withAnimation(.spring()) {
                workoutManager.selectedWorkout = type
            }
        }
    }
}



#Preview {
    WatchAppHome()
        .environmentObject(WorkoutManager())
}

extension HKWorkoutActivityType:Identifiable{
    public var id : UInt{
        return rawValue
    }
    
    var name :String{
        switch self{
        case .functionalStrengthTraining : return "쇠질"
        case .running : return "유산소"
        case .hiking : return "등산/하이킹"
        case .mindAndBody : return "숨쉬기 운동"
        default : return ""
        }
    }
    
    var icon : Image{
        switch self{
        case .functionalStrengthTraining : return Image("functionalStrengthTraining")
        case .running : return Image("running")
        case .hiking : return Image("hiking")
        case .mindAndBody : return Image("mindAndBody")
        default : return Image("")
        }
    }
    
}

