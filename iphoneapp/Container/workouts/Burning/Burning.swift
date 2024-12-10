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
    
    
//    @StateObject var storeManager = StoreManager()
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
            
            //구독할리스트 불러오기
            
            
            Button {
                
                if vm.selectedWorkout != nil{
                    vm.nextPageActivate = true
                }
            } label: {
                Btn(defaultString: "다음", fontsize: 20, fontcolor: .white, defaultColor: vm.selectedWorkout != nil ? Color.themeRed : Color.btnInactivate)
                    .cornerRadius(50)
                    .padding()
            }
        }
        .navigationDestination(isPresented: $vm.nextPageActivate) { // LazyVGrid 외부로 이동
//            Text("arrive")
            if vm.selectedWorkout == .functionalStrengthTraining{
                Counter()
            }else{
                Tracker()
            }
//                    SelectWorkoutLevel(workoutDone: $nextPageActivate)
        }
        
    }
    // MARK: - cell
    @ViewBuilder
    private func cell(item:HKWorkoutActivityType) -> some View{
        let color = item == vm.selectedWorkout ? Color.themeRed : .white
        Button {
            vm.selectedWorkout = item
        } label: {
            ZStack {
                item.detailImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                Color.black.opacity(item == vm.selectedWorkout ? 0.5 : 0)
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
