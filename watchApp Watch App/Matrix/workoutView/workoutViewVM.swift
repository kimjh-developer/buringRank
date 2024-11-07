//
//  workoutViewVM.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/14/24.
//

import Foundation
import HealthKit

class workoutViewVM:ObservableObject{
    @Published var CircleColor : CircleColor = .yellowCircle
    var workoutManager:WorkoutManager
    
    init(workoutManager: WorkoutManager) {
        self.workoutManager = workoutManager
    }
    
    func changeCircleColor(heartRate : Double){
//        var levels =
        
        print("highLevel : \(workoutManager.workoutLevel)")
        print("lowLevel : \(workoutManager.workoutLevel?.cLevel?.highLevel)")
        print("lowLevel : \(workoutManager.workoutLevel?.cLevel?.lowLevel)")
        
//        if let level = workoutLevel.fLevel{rate * level.}
//        if let level = workoutLevel.cLevel{rate * level.}
//        if let level = workoutLevel.hLevel{rate * level.}
//        if let level = workoutLevel.mLevel{rate * level.}
    }
}


