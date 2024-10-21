//
//  WorkoutManager.swift
//  iphoneapp
//
//  Created by mac on 10/19/24.
//

import Foundation
import HealthKit

class WorkoutManager:NSObject,ObservableObject{
    let healthStore = HKHealthStore()
    @Published var selectedWorkout : HKWorkoutActivityType?
    @Published var workoutLevel : WorkoutLevel?
    @Published var showingSummaryView : Bool = false{
        didSet{
            if showingSummaryView == false{
                selectedWorkout = nil
            }
        }
    }
    var session : HKWorkoutSession?
    var builder : HKLiveWorkoutBuilder?
    var userAge : Int?
    
    let typeToShare: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
        HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
    ]
    
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
    
    func startWorkout(workoutType: HKWorkoutActivityType) {
        // 세션이 이미 실행 중인 경우 종료
        if session?.state == .running || session?.state == .paused {
            print("💀 Workout is already running or paused. Ending session...")
            endWorkout()
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = workoutType == .functionalStrengthTraining || workoutType == .mindAndBody ? .indoor : .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            session?.delegate = self

            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

            let startDate = Date()
            session?.startActivity(with: startDate)
            builder?.beginCollection(withStart: startDate) { success, error in
                if success {
                    print("✅ Collection started")
                } else {
                    print("💀 Failed to start collection: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } catch {
            print("💀 Failed to create workout session: \(error.localizedDescription)")
        }
    }
    func requestAuthorization() {
        healthStore.requestAuthorization(toShare: typeToShare, read: typeToRead) { success, error in
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
        guard let session = session else { return }
        
        switch session.state {
        case .running:
            pause()  // 워크아웃이 실행 중이면 일시정지
        case .paused:
            resume()  // 워크아웃이 일시정지 중이면 재개
        default:
            print("💀 Unable to pause or resume in current state: \(session.state.rawValue)")
        }
    }

    func pause() {
        guard let session = session, session.state == .running else {
            print("💀 Cannot pause. Current state: \(session?.state.rawValue ?? -1)")
            return
        }
        session.pause()
    }

    func resume() {
        guard let session = session, session.state == .paused else {
            print("💀 Cannot resume. Current state: \(session?.state.rawValue ?? -1)")
            return
        }
        session.resume()
    }

    
    func endWorkout() {
        guard session?.state != .ended else {
            print("💀 Workout session is already ended.")
            return
        }
        session?.end()

        builder?.endCollection(withEnd: Date()) { success, error in
            if let error = error {
                print("💀 Failed to end collection: \(error.localizedDescription)")
            } else {
                self.builder?.finishWorkout { workout, error in
                    if let error = error {
                        print("💀 Failed to finish workout: \(error.localizedDescription)")
                    } else {
                        print("✅ Workout finished successfully.")
                    }
                }
            }
        }
        session = nil
        builder = nil
        showingSummaryView = true
    }
}

extension WorkoutManager : HKWorkoutSessionDelegate{
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
            print("💀 Workout session failed with error: \(error.localizedDescription)")
            resetWorkoutSession()
        }
        
        func resetWorkoutSession() {
            session = nil
            builder = nil
            print("✅ Workout session reset.")
        }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        print("✅ Workout state changed from \(fromState.rawValue) to \(toState.rawValue)")
        
        DispatchQueue.main.async {
            self.running = (toState == .running)
        }
        
        if toState == .ended && fromState != .ended {
            builder?.endCollection(withEnd: date) { success, error in
                if let error = error {
                    print("💀 error \(#line): \(error.localizedDescription)")
                    return
                }
                self.builder?.finishWorkout { workout, error in
                    if let error = error {
                        print("💀 error \(#line): \(error.localizedDescription)")
                        return
                    }
                    print("✅ workoutDone")
                }
            }
        } else {
            print("🚫 Cannot finish workout. Session is not ended or already processed.")
        }
    }
}

/*

 class WorkoutManager:NSObject,ObservableObject{
     @Published var selectedWorkout : HKWorkoutActivityType?
     @Published var workoutLevel : WorkoutLevel?
     @Published var showingSummaryView : Bool = false{
         didSet{
             if showingSummaryView == false{
                 selectedWorkout = nil
             }
         }
     }
     
     let healthStore = HKHealthStore()
     var session : HKWorkoutSession?
     var builder : HKLiveWorkoutBuilder?
     var userAge : Int?
     
     
     
     func startWorkout(workoutType: HKWorkoutActivityType) {
         // 세션이 이미 실행 중인 경우 종료
         if session?.state == .running || session?.state == .paused {
             print("💀 Workout is already running or paused. Ending session...")
             endWorkout()
         }
         
         let configuration = HKWorkoutConfiguration()
         configuration.activityType = workoutType
         configuration.locationType = workoutType == .functionalStrengthTraining || workoutType == .mindAndBody ? .indoor : .outdoor

         do {
             session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
             session?.delegate = self

             builder = session?.associatedWorkoutBuilder()
             builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

             let startDate = Date()
             session?.startActivity(with: startDate)
             builder?.beginCollection(withStart: startDate) { success, error in
                 if success {
                     print("✅ Collection started")
                 } else {
                     print("💀 Failed to start collection: \(error?.localizedDescription ?? "Unknown error")")
                 }
             }
         } catch {
             print("💀 Failed to create workout session: \(error.localizedDescription)")
         }
     }


     
     let typeToShare: Set = [
         HKQuantityType.quantityType(forIdentifier: .heartRate)!,
         HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
         HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
         HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
         HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
     ]
     
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
     func requestAuthorization() {
         healthStore.requestAuthorization(toShare: typeToShare, read: typeToRead) { success, error in
             if success {
                 print("Authorization Granted")
             } else {
                 print("💀 Authorization NOT Granted: \(error?.localizedDescription ?? "No error")")
             }
         }
     }
     func checkAuthorizationStatusAndRequest() {
         
         healthStore.getRequestStatusForAuthorization(toShare: typeToShare, read: typeToRead) { status, error in
             switch status {
             case .unnecessary:
                 print("Already authorized.")
             case .shouldRequest:
                 print("Requesting authorization...")
                 self.requestAuthorization()
             case .unknown:
                 print("Authorization status unknown: \(error?.localizedDescription ?? "No error")")
             @unknown default:
                 print("Unexpected status.")
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
         guard let session = session else { return }
         
         switch session.state {
         case .running:
             pause()  // 워크아웃이 실행 중이면 일시정지
         case .paused:
             resume()  // 워크아웃이 일시정지 중이면 재개
         default:
             print("💀 Unable to pause or resume in current state: \(session.state.rawValue)")
         }
     }

     func pause() {
         guard let session = session, session.state == .running else {
             print("💀 Cannot pause. Current state: \(session?.state.rawValue ?? -1)")
             return
         }
         session.pause()
     }

     func resume() {
         guard let session = session, session.state == .paused else {
             print("💀 Cannot resume. Current state: \(session?.state.rawValue ?? -1)")
             return
         }
         session.resume()
     }

     
     func endWorkout() {
         guard session?.state != .ended else {
             print("💀 Workout session is already ended.")
             return
         }
         session?.end()

         builder?.endCollection(withEnd: Date()) { success, error in
             if let error = error {
                 print("💀 Failed to end collection: \(error.localizedDescription)")
             } else {
                 self.builder?.finishWorkout { workout, error in
                     if let error = error {
                         print("💀 Failed to finish workout: \(error.localizedDescription)")
                     } else {
                         print("✅ Workout finished successfully.")
                     }
                 }
             }
         }
         session = nil
         builder = nil
         showingSummaryView = true
     }


 }

 extension WorkoutManager : HKWorkoutSessionDelegate{
     func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
             print("💀 Workout session failed with error: \(error.localizedDescription)")
             resetWorkoutSession()
         }
         
         func resetWorkoutSession() {
             session = nil
             builder = nil
             print("✅ Workout session reset.")
         }
     
     func workoutSession(_ workoutSession: HKWorkoutSession,
                         didChangeTo toState: HKWorkoutSessionState,
                         from fromState: HKWorkoutSessionState,
                         date: Date) {
         print("✅ Workout state changed from \(fromState.rawValue) to \(toState.rawValue)")
         
         DispatchQueue.main.async {
             self.running = (toState == .running)
         }
         
         if toState == .ended && fromState != .ended {
             builder?.endCollection(withEnd: date) { success, error in
                 if let error = error {
                     print("💀 error \(#line): \(error.localizedDescription)")
                     return
                 }
                 self.builder?.finishWorkout { workout, error in
                     if let error = error {
                         print("💀 error \(#line): \(error.localizedDescription)")
                         return
                     }
                     print("✅ workoutDone")
                 }
             }
         } else {
             print("🚫 Cannot finish workout. Session is not ended or already processed.")
         }
     }
 }

 */
