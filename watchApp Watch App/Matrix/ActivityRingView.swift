//
//  ActivityRingView.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/15/24.
//
import Foundation
import SwiftUI
import HealthKit

struct ActivityRingView : WKInterfaceObjectRepresentable{
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceObjectType, context: Context) {
        
    }
    
    let healthStore : HKHealthStore
    
    func makeWKInterfaceObject(context: Context) -> some WKInterfaceObject {
        let activityRingsObject = WKInterfaceActivityRing()
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.era,.year,.month,.day], from: Date())
        components.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: components)
        
        
        let query = HKActivitySummaryQuery(predicate: predicate) { query, summaries, error in
            DispatchQueue.main.async {
                activityRingsObject.setActivitySummary(summaries?.first, animated: true)
            }
        }
        
        return activityRingsObject
    }
    
    
    
}

#Preview {
    ActivityRingView(healthStore: HKHealthStore())
}
