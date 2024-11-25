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
        
    let grids : [GridItem] = [GridItem(.flexible(),spacing: 10),GridItem(.flexible(),spacing: 10)]
    
    init(hKWorkoutActivityType: HKWorkoutActivityType,Gohome:Binding<Bool>) {
        self.hKWorkoutActivityType = hKWorkoutActivityType
        self._Gohome = Gohome
    }
    
    var body: some View {
        ZStack(content: {
            VStack(content: {
                ScrollView {
                    switch hKWorkoutActivityType {
                    case .functionalStrengthTraining : gridMatrix(Fitem: .bulkup)
                    case .running : gridMatrix(Citem: .level1)
                    case .hiking : gridMatrix(Hitem: .lowLevel)
                    case .mindAndBody : gridMatrix(Mitem: .normalLevel)
                    default:EmptyView()
                    }
                }
                Spacer()
                
                Btn(defaultString: isSelected ? "갓쮸아" : "선택", defaultColor: isSelected ? Color.btnActivate : Color.btnInactivate)
                    .onTapGesture {
                        if isSelected{moveNext.toggle()}
                    }
            })
        })
        .padding(.horizontal)
        .onAppear(perform: {
            if hKWorkoutActivityType == .running || hKWorkoutActivityType == .hiking{
                workoutManager.requestLocationAuthorization()
            }
            
        })
        .navigationTitle({
            HStack(content: {
                hKWorkoutActivityType.icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                Text(hKWorkoutActivityType.name)
                    .style(fontName: .kbold, fontSize: 15, fontColor: .white)
            })
        })
        .navigationDestination(isPresented: $moveNext) {
            TimerCount(Gohome: $Gohome)
        }
    }
    
    // MARK: - cell
    @ViewBuilder
    private func gridMatrix(
        Fitem : FunctionWorkLevel? = nil,
        Citem : CardioLevel? = nil,
        Hitem : HikeLevel? = nil,
        Mitem : MeditationLevel? = nil
    ) -> some View{
        VStack(content: {
            LazyVGrid(columns: grids, content: {
                if let _ = Fitem{
                    ForEach(FunctionWorkLevel.allCases, id: \.self) { item in
                        gridCell(title: item.name, low: item.lowLevel, high: item.highLevel, isActivate: item == workoutManager.workoutLevel?.fLevel)
                            .onTapGesture {
                                workoutManager.workoutLevel = WorkoutLevel(fLevel: item)
                                isSelected = true
                            }
                    }
                }
                if let _ = Citem{
                    ForEach(CardioLevel.allCases, id: \.self) { item in
                        gridCell(title: item.name,low: item.lowLevel,high: item.highLevel,isActivate : item == workoutManager.workoutLevel?.cLevel)
                            .onTapGesture {
                                print("item:\(item)")
                                workoutManager.workoutLevel = WorkoutLevel(cLevel: item)
                                isSelected = true
                            }
                    }
                }
                if let _ = Hitem{
                    ForEach(HikeLevel.allCases, id: \.self) { item in
                        gridCell(title: item.name,low: item.lowLevel,high: item.highLevel,isActivate : item == workoutManager.workoutLevel?.hLevel)
                            .onTapGesture {
                                workoutManager.workoutLevel = WorkoutLevel(hLevel: item)
                                isSelected = true
                            }
                    }
                }
                if let _ = Mitem{
                    ForEach(MeditationLevel.allCases, id: \.self) { item in
                        gridCell(title: item.name,low: item.lowLevel,high: item.highLevel,isActivate : item == workoutManager.workoutLevel?.mLevel)
                            .onTapGesture {
                                workoutManager.workoutLevel = WorkoutLevel(mLevel: item)
                                isSelected = true
                            }
                    }
                }
            })
        })
    }
    
    // MARK: - gridCell
    @ViewBuilder
    private func gridCell(title:String,low:Double,high:Double,isActivate : Bool) -> some View{
        VStack(spacing: 6,content: {
            Text(title)
                .style(fontName: .kmedium,fontSize: 15,fontColor: isActivate ? Color.btnActivate : .white)
            if let baselineHeartRate = workoutManager.baselineHeartRate,
               let selectedWorkout = workoutManager.selectedWorkout{
                HStack(content: {
                    
                    Text("\((baselineHeartRate*low/100).toString(withDecimalPlaces:0))~\((baselineHeartRate*high/100).toString(withDecimalPlaces: 0))bpm"
                    )
                        .style(fontName: .klight,fontSize: 10,fontColor: isActivate ? Color.btnActivate : .white)
                        .frame(maxWidth: .infinity)
                    
                })
            }
            
        })
        .padding(.vertical,16)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActivate == true ? Color.btnActivate : .white, lineWidth: 2.0)
        }
    }
}

#Preview {
    ChooseDificulty(hKWorkoutActivityType: .functionalStrengthTraining, Gohome: .constant(true))
        .environmentObject(WorkoutManager())
}

