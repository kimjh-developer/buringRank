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
            
//            purchases()
            
            Button {
                print("clicked")
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
    
    // MARK: - 구독
//    @ViewBuilder
//    private func purchases() -> some View{
//        VStack(spacing: 20) {
//                   Text("구독 상태: \(storeManager.subscriptionStatus ? "활성화됨" : "비활성화됨")")
//                       .font(.headline)
//                       .padding()
//
//                   List(storeManager.products, id: \.id) { product in
//                       VStack(alignment: .leading) {
//                           Text(product.displayName)
//                               .font(.headline)
//                           Text(product.description)
//                               .font(.subheadline)
//                           Button(action: {
//                               Task {
//                                   await storeManager.purchase(product)
//                               }
//                           }) {
//                               Text("\(product.displayPrice)로 구독")
//                           }
//                       }
//                   }
//               }
//        .background(content: {
//            Color.white
//        })
//               .onAppear {
//                   Task {
//                       await storeManager.requestProducts()
//                   }
//               }
//    }
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
