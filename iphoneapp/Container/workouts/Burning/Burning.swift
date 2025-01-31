//
//  Burning.swift
//  iphoneapp
//
//  Created by mac on 10/20/24.
//

import SwiftUI
import HealthKit
struct Burning: View {
    
    @StateObject var vm = BurningVM()
    let grids : [GridItem] = [GridItem(.flexible(),spacing: 10),GridItem(.flexible(),spacing: 10)]
    let workoutTypes : [HKWorkoutActivityType] = [.functionalStrengthTraining,.running,.hiking]//,.mindAndBody,]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("운동 타입을 선택해주세요")
                    .style(fontName: .kbold, fontSize: 25, fontColor: .white)
                GeometryReader { proxy in
                    VStack {
                        ForEach(workoutTypes, id: \.self) { row in
                            cell(item: row, proxy: proxy)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Button {
                    if vm.selectedWorkout != nil {
                        vm.nextPageActivate = true
                    }
                } label: {
                    Btn(defaultString: "다음", fontsize: 20, fontcolor: .white, defaultColor: vm.selectedWorkout != nil ? Color.themeRed : Color.btnInactivate)
                        .cornerRadius(50)
                        .padding()
                }
            }
            // navigationDestination을 VStack 외부로 이동
            .navigationDestination(isPresented: $vm.nextPageActivate) {
                if vm.selectedWorkout == .functionalStrengthTraining {
                    Counter()
                } else {
//                    GroupMembers()
                    Tracker()
                }
            }
        }
    }

    // MARK: - cell
    @ViewBuilder
    private func cell(item:HKWorkoutActivityType,proxy : GeometryProxy) -> some View{
        let color = item == vm.selectedWorkout ? Color.themeRed : .white
        Button {
            vm.selectedWorkout = item
        } label: {
            ZStack {
                item.detailImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .frame(height: proxy.size.height/3-10)
                Color.black.opacity(item == vm.selectedWorkout ? 0.5 : 0)
                Text(item.name)
                    .style(fontName: .kbold, fontSize: 25, fontColor: color)
                RoundedRectangle(cornerRadius: 13)
                    .stroke(color, lineWidth: 5.0)
            }
            .frame(height: proxy.size.height/3-10)
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
