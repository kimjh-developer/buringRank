//
//  BurningVM.swift
//  iphoneapp
//
//  Created by mac on 12/6/24.
//

import Foundation
import HealthKit
class BurningVM:ObservableObject{
    @Published var nextPageActivate : Bool = false
    @Published var selectedWorkout : HKWorkoutActivityType?
}
