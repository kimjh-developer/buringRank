//
//  WorkoutManager.swift
//  iphoneapp
//
//  Created by mac on 10/21/24.
//


import Foundation
import HealthKit

class WorkoutManager:NSObject,ObservableObject{
    let healthStore = HKHealthStore()
    @Published var selectedWorkout : HKWorkoutActivityType?
    @Published var workoutLevel : WorkoutLevel?
    
    var userAge : Int?
    
    let typeToRead: Set = [
        HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
        HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
        HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.activitySummaryType()
    ]
    
    func startWorkout(workoutType: HKWorkoutActivityType) {}
    func requestAuthorization() {
        healthStore.requestAuthorization(toShare: nil, read: typeToRead) { success, error in
            if success {
                print("Authorization Granted")
            } else {
                print("💀 Authorization NOT Granted: \(error?.localizedDescription ?? "No error")")
            }
        }
    }
    // Fetch user's age and height
    func fetchUserData() {
        do {
            let birthDate = try healthStore.dateOfBirthComponents()
            let currentYear = Calendar.current.component(.year, from: Date())
            let age = currentYear - birthDate.year!
            userAge = age
            print("User's age: \(age)")
        } catch {
            print("Failed to fetch date of birth: \(error)")
        }
    }
    
    // MARK: - 상황제어 barco 241016
    @Published var running = false
    
    func togglePause() {
    }

    func pause() {
    }

    func resume() {
    }

    
    func endWorkout() {}
}
