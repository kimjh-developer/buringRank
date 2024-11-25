//
//  iphoneappApp.swift
//  iphoneapp
//
//  Created by mac on 10/18/24.
//

import SwiftUI

@main
struct iphoneappApp: App {
    
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environmentObject(workoutManager)
            .tint(.white)
        }
    }
}
