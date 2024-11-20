//
//  WorkoutManager.swift
//  iphoneapp
//
//  Created by mac on 10/19/24.
//

import Foundation
import HealthKit
import AVFoundation // AVFoundation 임포트 필요
import CoreLocation
class WorkoutManager:NSObject,ObservableObject{
    var healthStore = HKHealthStore()
    @Published var selectedWorkout : HKWorkoutActivityType?
    @Published var workoutLevel : WorkoutLevel?
    @Published var showingSummaryView : Bool = false{
        didSet{
            if showingSummaryView == false{
                resetWorkoutSession()
            }
        }
    }
    @Published var workout : HKWorkout?
    var session : HKWorkoutSession?
    var builder : HKLiveWorkoutBuilder?
    var userAge : Int?
    var baselineHeartRate : Double?
    
    
    //realValues
    @Published var heartRate : Double = 0
    @Published var everageHeartRate : Double = 0
    @Published var activityEnergy : Double = 0
    @Published var distance : Double = 0
    @Published var stepCount : Double = 0
    @Published var activeEnergyBurned : Double = 0
    @Published var distanceWalkingRunning : Double = 0
    @Published var oxygenSaturation : Double = 0
    @Published var flightsClimbed : Double = 0
    
    @Published var speed : Double?
    
    
    @Published var cadence: Double = 0  // 현재 케이던스를 저장할 변수
    private var cadenceTimer: Timer?  // 케이던스 업데이트를 위한 타이머
    private var lastUpdateTime: Date?  // 마지막 업데이트 시간 저장
    private var isPaused: Bool = false  // 케이던스 일시 정지 여부
    
    @Published var selectDay : Int?
    
    private var locationManager: CLLocationManager?

    @Published var routeLocations: [CLLocation] = []
    
    
    let typesToShare: Set = [
        
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
        HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!,
        HKQuantityType.workoutType(),
        HKSeriesType.workoutRoute()
    ]
    
    // The quantity types to read from the health store.
    let typesToRead: Set = [
        
        HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
        HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
        HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.activitySummaryType(),
        HKWorkoutType.workoutType(), // Workout 읽기 권한 추가
        HKSeriesType.workoutRoute()
    ]
    
    func startWorkout(workoutType: HKWorkoutActivityType) {
        // 기존 세션이 있는 경우 초기화하여 중복 방지
        if session != nil || builder != nil {
            print("🔄 Existing session or builder found. Resetting before starting a new session.")
            resetWorkoutSession()
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        if workoutType == .functionalStrengthTraining || workoutType == .mindAndBody{
            configuration.locationType =  .indoor
        }else{
            configuration.locationType =  .outdoor
        }
        
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            session?.delegate = self  // delegate 설정으로 상태 변화를 감지할 수 있도록 함
            builder?.delegate = self
            
            // DataSource 설정
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            // 세션 시작
            let startDate = Date()
            session?.startActivity(with: startDate)
            startLocationUpdates()
//            self.announceWorkoutStart(workoutType: workoutType)
            self.builder?.beginCollection(withStart: startDate) { (success, error) in
                if let error = error {
                    print("💀 Failed to start data collection: \(error.localizedDescription)")
                    self.resetWorkoutSession()
                    return
                }
                print("✅ Workout session started and data collection has begun.")
            }
            
            
        } catch {
            // 예외 처리: 세션 시작 중 문제가 발생한 경우
            print("💀 Failed to start workout session: \(error.localizedDescription)")
            resetWorkoutSession()
        }
    }
    
    func resetWorkoutSession() {
        DispatchQueue.main.async {
            self.session?.end()  // 세션을 종료하여 충돌 방지
            self.session = nil
            self.builder = nil
            self.selectedWorkout = nil
            self.workoutLevel = nil
            self.workout = nil
        print("✅ Workout session reset.")
        }
    }
    
    func updateForStatistics(_ statistics : HKStatistics?){
        guard let statistics = statistics else { return }
        
        DispatchQueue.main.async{
            print("statistics:\(statistics.quantityType.description)")
            switch statistics.quantityType{
            case HKQuantityType.quantityType(forIdentifier: .heartRate) :
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.everageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) :
                let unit = HKUnit.meterUnit(with: .kilo)
                self.distanceWalkingRunning = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .stepCount):
                self.stepCount = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .runningSpeed),HKQuantityType.quantityType(forIdentifier: .walkingSpeed):
                let speedUnit = HKUnit.meter().unitDivided(by: HKUnit.second())
                self.speed = statistics.mostRecentQuantity()?.doubleValue(for: speedUnit)
            default:return
                
            }
        }
    }
    
    func requestAuthorization() {
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                print("Authorization Granted")
                self.fetchUserData()
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
            baselineHeartRate = Double(220 - age)
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
        session?.end()
    }
    
    // 새로운 함수 추가: 음성 안내를 위해
    func announceWorkoutStart(workoutType: HKWorkoutActivityType) {
        let synthesizer = AVSpeechSynthesizer()
        let speechUtterance = AVSpeechUtterance(string: "버닝랭크를 시작합니다")
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ko-KR") // 한국어 음성 설정
        synthesizer.speak(speechUtterance)
    }
    
}
extension WorkoutManager : HKWorkoutSessionDelegate{
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("💀 Workout session failed with error: \(error.localizedDescription)")
        resetWorkoutSession()
    }
    
    
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        
        print("✅ Workout state changed from \(fromState.rawValue) to \(toState.rawValue)")
        
        DispatchQueue.main.async {
            self.running = (toState == .running)
        }
        
        switch toState {
        case .notStarted:
            print("🚫 Workout session is not started.")
            // 추가 초기화 또는 상태 전환 로직 필요 시 작성
        case .running:
            print("✅ Workout session is now running.")
            
            // 워크아웃이 시작됨 - 관련 데이터 업데이트 및 트래킹 시작
        case .paused:
            print("⏸ Workout session is paused.")
            
            // 워크아웃이 일시정지됨 - 필요한 데이터 중지
        case .ended:
            DispatchQueue.main.async {
                self.showingSummaryView = true
                print("🏁 Workout session ended.-showingSummaryView")
            }
            // 워크아웃이 종료됨 - 데이터 수집 종료 및 정리
            handleWorkoutEnd(date: date)
        case .prepared:
            print("🏁 prepare session ended.")
        case .stopped:
            print("🛑 prepare session stopped.")
        @unknown default:
            print("💀 Unknown state encountered: \(toState.rawValue)")
        }
    }
    
    private func handleWorkoutEnd(date: Date) {
        builder?.endCollection(withEnd: date) { success, error in
            if let error = error {
                print("💀 Error ending workout collection: \(error.localizedDescription)")
                return
            }
            self.builder?.finishWorkout { workout, error in
                if let error = error {
                    print("💀 Error finishing workout: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async{
                    self.workout = workout
                    print("✅ Workout finished successfully.")
                    self.saveWorkoutRoute(workout: workout) // 경로 저장
                }
                self.stopLocationUpdates() // 위치 추적 중지
                // 필요시 추가적으로 세션 초기화
//                self.resetWorkoutSession()
            }
        }
    }
    
    private func saveWorkoutRoute(workout: HKWorkout?) {
        guard let workout = workout else { return }

        let routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
        routeBuilder.insertRouteData(routeLocations) { success, error in
            if let error = error {
                print("💀 Failed to save route: \(error.localizedDescription)")
            } else {
                print("📍 Route data saved successfully.")
            }
        }

        routeBuilder.finishRoute(with: workout, metadata: nil) { route, error in
            if let error = error {
                print("💀 Error finishing route: \(error.localizedDescription)")
            } else {
                print("📍 Workout route saved: \(String(describing: route))")
            }
        }
    }
}

extension WorkoutManager : HKLiveWorkoutBuilderDelegate{
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {return}
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            updateForStatistics(statistics)
        }
    }
}

extension WorkoutManager : CLLocationManagerDelegate{
    func requestLocationAuthorization() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 10 // 최소 거리 필터
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
            locationManager?.startUpdatingLocation()
        }

        func stopLocationUpdates() {
            locationManager?.stopUpdatingLocation()
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            routeLocations.append(contentsOf: locations)
            print("📍 Locations updated: \(locations.count) new points")
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("💀 Location update failed: \(error.localizedDescription)")
        }
}
