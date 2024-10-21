//
//  watchAppApp.swift
//  watchApp Watch App
//
//  Created by mac on 10/18/24.
//

import SwiftUI

@main
struct watchApp_Watch_AppApp: App {
    @StateObject var workoutManager = WorkoutManager()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environmentObject(workoutManager)
        }
    }
}
