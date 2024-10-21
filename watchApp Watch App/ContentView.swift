//
//  ContentView.swift
//  watchApp Watch App
//
//  Created by mac on 10/18/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager : WorkoutManager
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .onAppear {
                    workoutManager.requestAuthorization()
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}
