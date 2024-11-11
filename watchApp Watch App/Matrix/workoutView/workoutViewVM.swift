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
        if let Llevel = workoutManager.workoutLevel?.fLevel?.lowLevel,
           let Hlevel = workoutManager.workoutLevel?.fLevel?.highLevel,
           let baselineHeartRate = workoutManager.baselineHeartRate
        {
            print("heartRate/baselineHeartRate * 100:\(heartRate/baselineHeartRate * 100)")
            switch heartRate/baselineHeartRate * 100 {
            case ..<Llevel: // Llevel보다 낮은 경우
                CircleColor = .yellowCircle // 예: 낮은 심박수일 때
            case Llevel...Hlevel: // Llevel과 Hlevel 사이
                CircleColor = .blueCircle // 예: 정상 범위의 심박수일 때
            case Hlevel...: // Hlevel보다 높은 경우
                CircleColor = .orangeCircle // 예: 높은 심박수일 때
            default:
                CircleColor = .grayCircle // 기본값
            }
        }
        
        if let Llevel = workoutManager.workoutLevel?.cLevel?.lowLevel,
           let Hlevel = workoutManager.workoutLevel?.cLevel?.highLevel,
           let baselineHeartRate = workoutManager.baselineHeartRate
        {
            print("heartRate/baselineHeartRate * 100:\(heartRate/baselineHeartRate * 100)")
            switch heartRate/baselineHeartRate * 100 {
            case ..<Llevel: // Llevel보다 낮은 경우
                CircleColor = .yellowCircle // 예: 낮은 심박수일 때
            case Llevel...Hlevel: // Llevel과 Hlevel 사이
                CircleColor = .blueCircle // 예: 정상 범위의 심박수일 때
            case Hlevel...: // Hlevel보다 높은 경우
                CircleColor = .orangeCircle // 예: 높은 심박수일 때
            default:
                CircleColor = .grayCircle // 기본값
            }
        }
        
        if let Llevel = workoutManager.workoutLevel?.hLevel?.lowLevel,
           let Hlevel = workoutManager.workoutLevel?.hLevel?.highLevel,
           let baselineHeartRate = workoutManager.baselineHeartRate
        {
            switch heartRate/baselineHeartRate * 100 {
            case ..<Llevel: // Llevel보다 낮은 경우
                CircleColor = .yellowCircle // 예: 낮은 심박수일 때
            case Llevel...Hlevel: // Llevel과 Hlevel 사이
                CircleColor = .blueCircle // 예: 정상 범위의 심박수일 때
            case Hlevel...: // Hlevel보다 높은 경우
                CircleColor = .orangeCircle // 예: 높은 심박수일 때
            default:
                CircleColor = .grayCircle // 기본값
            }
        }

        if let Llevel = workoutManager.workoutLevel?.mLevel?.lowLevel,
           let Hlevel = workoutManager.workoutLevel?.mLevel?.highLevel,
           let baselineHeartRate = workoutManager.baselineHeartRate
        {
            print("heartRate/baselineHeartRate * 100:\(heartRate/baselineHeartRate * 100)")
            switch heartRate/baselineHeartRate * 100 {
            case ..<Llevel: // Llevel보다 낮은 경우
                CircleColor = .yellowCircle // 예: 낮은 심박수일 때
            case Llevel...Hlevel: // Llevel과 Hlevel 사이
                CircleColor = .blueCircle // 예: 정상 범위의 심박수일 때
            case Hlevel...: // Hlevel보다 높은 경우
                CircleColor = .orangeCircle // 예: 높은 심박수일 때
            default:
                CircleColor = .grayCircle // 기본값
            }
        }

    }
}



