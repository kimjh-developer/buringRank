//
//  Burning.swift
//  iphoneapp
//
//  Created by mac on 10/20/24.
//

import SwiftUI
import HealthKit
struct Burning: View {
    @EnvironmentObject var workoutManager : WorkoutManager
    let grids : [GridItem] = [GridItem(.flexible(),spacing: 10),GridItem(.flexible(),spacing: 10)]
    var workoutTypes : [HKWorkoutActivityType] = [.functionalStrengthTraining,.running,.hiking,.mindAndBody,]
    @State var nextPageActivate : Bool = false
    
    var body: some View {
        
        VStack {
            Text("운동 타입을 선택해주세요")
                .style(fontName: .kbold, fontSize: 25, fontColor: .white)
            LazyVGrid(columns: grids) {
                ForEach(workoutTypes, id: \.self) { row in
                    cell(item: row)
                }
            }
            .padding()
            Spacer()
            
            Button {
                if workoutManager.selectedWorkout != nil{
                    nextPageActivate = true
                }
            } label: {
                Btn(defaultString: "다음", fontsize: 20, fontcolor: .white, defaultColor: workoutManager.selectedWorkout != nil ? Color.themeRed : Color.btnInactivate)
                    .cornerRadius(50)
                    .padding()
            }
        }
        .navigationDestination(isPresented: $nextPageActivate) {
            SelectWorkoutLevel(workoutDone: $nextPageActivate)
        }
        
    }
    // MARK: - cell
    @ViewBuilder
    private func cell(item:HKWorkoutActivityType) -> some View{
        let color = item == workoutManager.selectedWorkout ? Color.themeRed : .white
        Button {
            workoutManager.selectedWorkout = item
        } label: {
            ZStack {
                item.detailImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                Color.black.opacity(item == workoutManager.selectedWorkout ? 0.5 : 0)
                Text(item.name)
                    .style(fontName: .kbold, fontSize: 25, fontColor: color)
                RoundedRectangle(cornerRadius: 13)
                    .stroke(color, lineWidth: 5.0)
            }
            
            .cornerRadius(10)
        }
    }
}

#Preview {
    Container()
        .environmentObject(WorkoutManager())
}

extension HKWorkoutActivityType:@retroactive Identifiable{
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
    
    var detailImage : Image{
        switch self{
        case .functionalStrengthTraining : return Image("functionalStrengthTraining")
        case .running : return Image("running")
        case .hiking : return Image("hiking")
        case .mindAndBody : return Image("mindAndBody")
        default : return Image("")
        }
    }
    
    var icon : Image{
        switch self{
        case .functionalStrengthTraining : return Image("health")
        case .running : return Image("cadio")
        case .hiking : return Image("hike")
        case .mindAndBody : return Image("mind")
        default : return Image("")
        }
    }
}
