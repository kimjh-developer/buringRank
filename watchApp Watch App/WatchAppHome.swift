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
    let grids : [GridItem] = [GridItem(.flexible(),spacing: 10),GridItem(.flexible(),spacing: 10)]
    var workoutTypes : [HKWorkoutActivityType] = [.functionalStrengthTraining,.running,.hiking,.mindAndBody,]
    @State var moveNext : Bool = false
    var body: some View {
        VStack {
            ScrollView {
                Text("운동 타입을 선택해주세요")
                    .style(fontName: .kmedium, fontSize: 16, fontColor: .white)
                    .padding(.vertical)
                LazyVGrid(columns: grids,spacing: 10, content: {
                    ForEach(workoutTypes, id: \.self) { item in
                        cell(type: item)
                    }
                })
                Btn(defaultString: "다음", defaultColor: workoutManager.selectedWorkout == nil ? Color.btnInactivate : Color.btnActivate)
                    .padding(.vertical)
                    .onTapGesture {
                        moveNext.toggle()
                    }
            }
        }
        .padding(.horizontal)
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented:$moveNext) {
            if let type = workoutManager.selectedWorkout{
                ChooseDificulty(hKWorkoutActivityType: type,Gohome: $moveNext)
            }
        }
        
        
    }
    
    // MARK: - 그리그셀
    @ViewBuilder
    private func cell(type:HKWorkoutActivityType) -> some View{
        VStack{
            type.icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 25)
                .foregroundStyle(type == workoutManager.selectedWorkout ? Color.btnActivate : .white)
                
            Text(type.name)
                .style(fontName: .kmedium, fontSize: 10, fontColor: type == workoutManager.selectedWorkout ? Color.btnActivate : .white)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(type == workoutManager.selectedWorkout ? Color.btnActivate : .white, lineWidth: 2.0)
                
        }
        .onTapGesture {
            workoutManager.selectedWorkout = type
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

