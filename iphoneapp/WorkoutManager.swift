//
//  PhoneWorkoutManager.swift
//  iphoneapp
//
//  Created by mac on 10/21/24.
//


import Foundation
import HealthKit
import CoreLocation
class WorkoutManager:NSObject,ObservableObject{
    let healthStore = HKHealthStore()
    @Published var selectedWorkout : HKWorkoutActivityType?
    @Published var workoutLevel : WorkoutLevel?
    @Published var AuthoriseWarn : Bool = false
    @Published var AuthorizationFullyGranted = false
    var userAge : Int?
    var maxHeartRate : Double?
    @Published var SummaryArray : Array<SummaryRow> = []
    @Published var summaryArray : Array<SummaryRow>?
    @Published var updownValue: Int?
    @Published var existWeeks:Array<String> = []
    @Published var workoutProgressArray : Array<WorkoutProgress>=[]
    @Published var ThismaxHeartRate : Double?
    @Published var LastmaxHeartRate : Double?
    @Published var chartData: [DValue] = []
    
    
    var chooseDay : Date?
    
    let typesToShare: Set<HKSampleType> = [
        
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
        HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.workoutType(), // 반드시 포함해야 함
        HKSeriesType.workoutRoute() // 의존성 있음
    ]
    // 읽기 권한
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
           HKObjectType.workoutType(), // 반드시 포함해야 함
           HKSeriesType.workoutRoute() // 의존성 있음
       ]
       
    // MARK: - 권한 요청
    func requestAuthorization() {
        // 공유 권한(toShare)은 nil로 설정하여 무시하고 읽기 권한만 요청
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self.checkAuthorizationStatus()
                }
            } else {
                DispatchQueue.main.async {
                    self.AuthoriseWarn = true
                }
                print("💀 Authorization NOT Granted: \(error?.localizedDescription ?? "No error")")
            }
        }
    }
    
    // MARK: - 권한 상태 확인
    private func checkAuthorizationStatus() {
            // 읽기 권한만 확인
            var allPermissionsGranted = true
            var typesToRequest = Set<HKObjectType>()
            for type in self.typesToShare {
                // 읽기 권한만 로그로 출력
                let status = self.healthStore.authorizationStatus(for: type)
                switch status {
                case .sharingAuthorized:
                    print("\(type.identifier):  ✍️ ✅ Authorized") // 읽기 권한만 표시
                case .sharingDenied:
                    print("\(type.identifier): ✍️ 🛑 Denined") // 읽기 권한만 표시
                case  .notDetermined:
                    print("\(type.identifier): ✍️ 🔥 Determined")
                @unknown default:
                    print("\(type.identifier): ✍️ ❌ Unknown Status")
                    allPermissionsGranted = false
                }
            }
            for type in self.typesToRead {
                // 읽기 권한만 로그로 출력
                let status = self.healthStore.authorizationStatus(for: type)
                switch status {
                case .sharingAuthorized:
                    print("\(type.identifier): 📖 ✅ Authorized") // 읽기 권한만 표시
                case .sharingDenied:
                    print("\(type.identifier): 📖 🛑 sharingDenied") // 읽기 권한만 표시
                case  .notDetermined:
                    print("\(type.identifier):  📖 🔥 Determined")
                    typesToRequest.insert(type)
//                            allPermissionsGranted = false
                @unknown default:
                    print("\(type.identifier): 📖 ❌ Unknown Status")
                    allPermissionsGranted = false
                }
            }
            
            if !typesToRequest.isEmpty {
                self.healthStore.requestAuthorization(toShare: nil, read: typesToRequest) { success, error in
                        if success {
                            print("권한 요청 성공")
                        } else {
                            print("권한 요청 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                        }
                    }
                } else {
                    print("모든 권한이 이미 설정되어 있습니다.")
                }
            
            if allPermissionsGranted {
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                    self.AuthorizationFullyGranted = true
                    print("Authorization Fully Granted for Reading")
                    self.fetchUserData()
                }
            } else {
                self.AuthoriseWarn = true
                print("Partial Authorization Granted: Some permissions were denied for reading.")
            }
        
    }
    // Fetch user's age and height
    func fetchUserData() {
        do {
            let birthDate = try healthStore.dateOfBirthComponents()
            let currentYear = Calendar.current.component(.year, from: Date())
            let age = currentYear - birthDate.year!
            userAge = age
            maxHeartRate = 220 - Double(age)
            print("User's age: \(age)")
        } catch {
            print("Failed to fetch date of birth: \(error)")
        }
    }
    
    func getStartAndEndOfWeek() -> (start: Date, end: Date) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let now = Date()
        
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? now
        return (startOfWeek, endOfWeek)
    }
    
    
    
    func getWeekData() {
        guard let maxRate = maxHeartRate else{
            print("💀maxHeartRate : \(String(describing: maxHeartRate))")
            return}
        let workoutmanager = WorkoutManager()
        
        // 현재 주의 시작과 끝 날짜
        let (startOfThisWeek, endOfThisWeek) = workoutmanager.getStartAndEndOfWeek()
        // 지난 주의 시작과 끝 날짜
        let startOfLastWeek = Calendar.current.date(byAdding: .day, value: -7, to: startOfThisWeek)!
        let endOfLastWeek = Calendar.current.date(byAdding: .day, value: -7, to: endOfThisWeek)!
        
        // Helper function to fetch and compare data
        func fetchAndCompare(type: HKQuantityTypeIdentifier, measureUnit: HKUnit, summaryType: SummaryType) {
            workoutmanager.fetchWeeklyData(type: type, start: startOfLastWeek, end: endOfLastWeek) { lastWeekSamples in
                let lastWeekTotal = lastWeekSamples?.reduce(0) {
                    $0 + $1.quantity.doubleValue(for: measureUnit)
                } ?? 0
                
                workoutmanager.fetchWeeklyData(type: type, start: startOfThisWeek, end: endOfThisWeek) { thisWeekSamples in
                    guard let thisWeekSamples = thisWeekSamples, !thisWeekSamples.isEmpty else {
                        print("이번 주 \(summaryType.element.title) 데이터가 없습니다.")
                        return
                    }
                    
                    let thisWeekTotal = thisWeekSamples.reduce(0) {
                        $0 + $1.quantity.doubleValue(for: measureUnit)
                    }
                    
                    // 이번 주 최고 심박수 계산
                    let maxThisWeek = thisWeekSamples.max(by: {
                        $0.quantity.doubleValue(for: measureUnit) < $1.quantity.doubleValue(for: measureUnit)
                    })?.quantity.doubleValue(for: measureUnit) ?? 0
                    
                    // 이번 주 요일별 데이터 수집
                    thisWeekSamples.forEach { sample in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EE" // 요일 출력
                        let dateString = dateFormatter.string(from: sample.startDate).uppercased()
                        DispatchQueue.main.async {
                            if !self.existWeeks.contains(dateString) {
                                self.existWeeks.append(dateString)
                            }
                        }
                    }
                    
                    
                    let difference = thisWeekTotal - lastWeekTotal
                    
                    DispatchQueue.main.async {
                        let newRow = SummaryRow(
                            summaryType: summaryType,
                            stack: SummaryRowElement(Str: "이번주 누적", Updown: Int(difference), Value: thisWeekTotal),
                            best: SummaryRowElement(Str: "이번주 최고", Updown: nil, Value: maxThisWeek),
                            duration: nil
                        )
                        if let index = self.SummaryArray.firstIndex(where: { $0.summaryType == summaryType }) {
                            self.SummaryArray[index] = newRow
                        } else {
                            self.SummaryArray.append(newRow)
                        }
                        print("SummaryArray:\(self.SummaryArray)")
                        // 최고 심박수 출력 (디버깅용)
                        if summaryType == .heartRate {
                            print("이번 주 최고 심박수: \(maxThisWeek) BPM")
                        }
                    }
                }
            }
        }
        
        // Fetch and compare for walk, calorie, and distance
        fetchAndCompare(type: .heartRate, measureUnit: HKUnit(from: "count/min"), summaryType: .heartRate)
        fetchAndCompare(type: .stepCount, measureUnit: HKUnit.count(), summaryType: .walk)
        fetchAndCompare(type: .distanceWalkingRunning, measureUnit: HKUnit.meterUnit(with: .kilo), summaryType: .distance)
        fetchAndCompare(type: .activeEnergyBurned, measureUnit: HKUnit.kilocalorie(), summaryType: .calorie)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.analyzeHeartRateForThisWeek(maxHeartRate: maxRate) { distribution in
                print("심박수 구간별 시간 분배: \(distribution)")
                self.updateWorkoutProgressArray(from: distribution)
            }
        }
    }
    
    func getMaxHeartRate() -> Double? {
        // SummaryArray에서 summaryType이 .heartRate인 항목 찾기
        guard let heartRateSummary = SummaryArray.first(where: { $0.summaryType == .heartRate }) else {
            print("💀 SummaryArray에 heartRate 데이터가 없습니다.")
            return nil
        }
        
        // 최고값 반환
        return heartRateSummary.best?.Value
    }
    
    //지정일자에 데이터를 구함
    func getStartOfWeek(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)! // UTC 0 기준으로 설정 (원하는 시간대로 변경 가능)
        calendar.firstWeekday = 2
        
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return calendar.startOfDay(for: startOfWeek)
    }
    
    func getDateForWeekday(weekday: Int) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)! // UTC 0 기준으로 설정 (원하는 시간대로 변경 가능)
        let startOfWeek = getStartOfWeek(for: Date())
        return calendar.date(byAdding: .day, value: weekday, to: startOfWeek)
    }
    
    func getStartAndEndOfDay(for date: Date) -> (start: Date, end: Date) {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)! // UTC 0 기준으로 설정 (원하는 시간대로 변경 가능)

        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return (startOfDay, endOfDay)
    }
    
    func fetchWeeklyData(type: HKQuantityTypeIdentifier, start: Date, end: Date, completion: @escaping ([HKQuantitySample]?) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: type) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            if let error = error {
                print("Error fetching \(type): \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            completion(samples as? [HKQuantitySample])
        }
        
        healthStore.execute(query)
    }
    
    func getDailyComparisonData(for date: Date) {
        let calendar = Calendar.current
        guard let lastWeekSameDay = calendar.date(byAdding: .weekOfYear, value: -1, to: date) else { return }
        
        let (startOfSelectedDay, endOfSelectedDay) = getStartAndEndOfDay(for: date)
        let (startOfLastWeekSameDay, endOfLastWeekSameDay) = getStartAndEndOfDay(for: lastWeekSameDay)
        
        func fetchAndCompare(type: HKQuantityTypeIdentifier, measureUnit: HKUnit, summaryType: SummaryType) {
            fetchWeeklyData(type: type, start: startOfLastWeekSameDay, end: endOfLastWeekSameDay) { lastWeekSamples in
                // 지난주 최고 심박수 계산
                let maxLastWeek = lastWeekSamples?.max(by: {
                    $0.quantity.doubleValue(for: measureUnit) < $1.quantity.doubleValue(for: measureUnit)
                })?.quantity.doubleValue(for: measureUnit) ?? 0
                
                self.fetchWeeklyData(type: type, start: startOfSelectedDay, end: endOfSelectedDay) { thisWeekSamples in
                    // 이번 주 최고 심박수 계산
                    let maxThisDay = thisWeekSamples?.max(by: {
                        $0.quantity.doubleValue(for: measureUnit) < $1.quantity.doubleValue(for: measureUnit)
                    })?.quantity.doubleValue(for: measureUnit) ?? 0
                    
                    // 차이 계산
                    let difference = maxThisDay - maxLastWeek
                    
                    DispatchQueue.main.async {
                        if summaryType == .heartRate {
                            // 최고 심박수 차이로 updownValue 업데이트
                            self.updownValue = Int(difference)
                        }
                        
                        // 현재 날짜에서 일주일 전 날짜 계산
                        if let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: date) {
                            // 일주일 전 날짜의 월과 일 추출
                            let month = calendar.component(.month, from: oneWeekAgo)
                            let day = calendar.component(.day, from: oneWeekAgo)
                            
                            // "지난 최고" 부분을 일주일 전 날짜로 표시
                            let newRow = SummaryRow(
                                summaryType: summaryType,
                                stack: SummaryRowElement(
                                    Str: "\(calendar.component(.month, from: date))월 \(calendar.component(.day, from: date))일 최고",
                                    Updown: Int(difference),
                                    Value: maxThisDay
                                ),
                                best: SummaryRowElement(
                                    Str: "\(month)월 \(day)일 최고",
                                    Updown: nil,
                                    Value: maxLastWeek
                                ),
                                duration: nil
                            )
                            
                            if let index = self.SummaryArray.firstIndex(where: { $0.summaryType == summaryType }) {
                                self.SummaryArray[index] = newRow
                            } else {
                                self.SummaryArray.append(newRow)
                            }
                        }
                    }
                }
            }
        }
        
        
        fetchAndCompare(type: .heartRate, measureUnit: HKUnit(from: "count/min"), summaryType: .heartRate)
        fetchAndCompare(type: .stepCount, measureUnit: HKUnit.count(), summaryType: .walk)
        fetchAndCompare(type: .distanceWalkingRunning, measureUnit: HKUnit.meterUnit(with: .kilo), summaryType: .distance)
        fetchAndCompare(type: .activeEnergyBurned, measureUnit: HKUnit.kilocalorie(), summaryType: .calorie)
    }
    
    func performComparisonForSelectedWeekday(weekday: Int) {
        print("i:\(weekday)")
        guard let selectedDate = getDateForWeekday(weekday: weekday) else {
            print("Invalid weekday selected.")
            return
        }
        chooseDay = selectedDate
        getDailyComparisonData(for: selectedDate)
    }
    
    func updateWorkoutProgressArray(from distribution: [String: Double]) {
        // 구간별 ProgressLevel 매핑
        let levelMapping: [(range: String, level: ProgressLevel)] = [
            ("50% 이상", .level1),
            ("60% 이상", .level2),
            ("70% 이상", .level3),
            ("80% 이상", .level4),
            ("90% 이상", .level5)
        ]
        
        // distribution 값을 workoutProgressArray에 추가
        DispatchQueue.main.async {
            self.workoutProgressArray = levelMapping.compactMap { mapping in
                guard let percentage = distribution[mapping.range] else {
                    return nil // distribution에 값이 없으면 스킵
                }
                
                let timeFormatted = String(format: "%.1f%%", percentage) // 시간 대신 비율 표시
                
                return WorkoutProgress(
                    progressLevel: mapping.level,
                    percentage: percentage,
                    time: timeFormatted
                )
            }
        }
        
        
        // 결과 확인
        //        print("Updated workoutProgressArray: \(self.workoutProgressArray)")
    }
    
    func resetDatas(){
        SummaryArray.removeAll()
        summaryArray = nil
        updownValue = nil
        existWeeks.removeAll()
        workoutProgressArray.removeAll()
        ThismaxHeartRate = nil
        LastmaxHeartRate = nil
    }
}


//심박수 구분 주로 표시
extension WorkoutManager {
    func calculateHeartRateDistribution(for samples: [HKQuantitySample], maxHeartRate: Double) -> [String: Double] {
        var timeInZones: [String: Double] = [
            "50% 이상": 0,
            "60% 이상": 0,
            "70% 이상": 0,
            "80% 이상": 0,
            "90% 이상": 0
        ]
        
        let heartRateZones: [(threshold: Double, label: String)] = [
            (maxHeartRate * 0.9, "90% 이상"),
            (maxHeartRate * 0.8, "80% 이상"),
            (maxHeartRate * 0.7, "70% 이상"),
            (maxHeartRate * 0.6, "60% 이상"),
            (maxHeartRate * 0.5, "50% 이상")
        ]
        
        for sample in samples {
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            
            for zone in heartRateZones {
                if heartRate >= zone.threshold {
                    timeInZones[zone.label]! += 1
                    break
                }
            }
        }
        
        let totalSamples = samples.count
        guard totalSamples > 0 else {
            return timeInZones.mapValues { _ in 0 }
        }
        
        var distribution: [String: Double] = [:]
        for (zone, count) in timeInZones {
            distribution[zone] = (count / Double(totalSamples)) * 100
        }
        
        return distribution
    }
    
    func analyzeHeartRateForThisWeek(maxHeartRate: Double, completion: @escaping ([String: Double]) -> Void) {
        let (startOfThisWeek, endOfThisWeek) = getStartAndEndOfWeek()
        
        fetchWeeklyData(type: .heartRate, start: startOfThisWeek, end: endOfThisWeek) { samples in
            guard let samples = samples, !samples.isEmpty else {
                print("심박수 데이터가 없습니다.start:\(startOfThisWeek),end:\(endOfThisWeek)")
                completion(["데이터 없음": 0])
                return
            }
            for sample in samples {
                _ = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                let startDate = sample.startDate
                let endDate = sample.endDate
                _ = endDate.timeIntervalSince(startDate)
            }
            
            
            
            
            let distribution = self.calculateHeartRateDistribution(for: samples, maxHeartRate: maxHeartRate)
            DispatchQueue.main.async {
                completion(distribution)
            }
        }
    }
}

// MARK: - 상세보기화면 barco 20241113
struct MetricSummary {
    var heartRate: MetricDetail = MetricDetail()
    var activeEnergyBurned: MetricDetail = MetricDetail()
    var stepCount: MetricDetail = MetricDetail()
    var distanceWalkingRunning: MetricDetail = MetricDetail()
    var walkingSpeed: MetricDetail = MetricDetail()
    
    var heartRateZones: [HeartRateZone: Double] = [:] // 심박수 구간 비율 추가
    
    mutating func updateSummary(for type: HKQuantityTypeIdentifier, total: Double, average: Double, max: Double) {
        let metric = MetricDetail(total: total, average: average, max: max)
        print("type:\(type)")
        switch type {
        case .heartRate:
            heartRate = metric
        case .activeEnergyBurned:
            activeEnergyBurned = metric
        case .stepCount:
            stepCount = metric
        case .distanceWalkingRunning:
            distanceWalkingRunning = metric
        case .walkingSpeed:
            walkingSpeed = metric
        default:
            break
        }
    }
    
    mutating func updateHeartRateZones(with samples: [HKQuantitySample], maxHeartRate: Double) {
        var zoneCounts: [HeartRateZone: Int] = [
            .below50: 0,
            .below60: 0,
            .below70: 0,
            .below80: 0,
            .above90: 0
        ]
        
        for sample in samples {
            let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            let percentage = (value / maxHeartRate) * 100
            
            switch percentage {
            case ..<50:
                zoneCounts[.below50]! += 1
            case 50..<60:
                zoneCounts[.below60]! += 1
            case 60..<70:
                zoneCounts[.below70]! += 1
            case 70..<80:
                zoneCounts[.below80]! += 1
            case 90...:
                zoneCounts[.above90]! += 1
            default:
                break
            }
        }
        
        let totalSamples = samples.count
        guard totalSamples > 0 else {
            heartRateZones = zoneCounts.mapValues { _ in 0 }
            return
        }
        
        heartRateZones = zoneCounts.mapValues { (Double($0) / Double(totalSamples)) * 100 }
    }
}

enum TimePeriod:Equatable,Hashable {
    case weekly
    case monthly
    case yearly
    case custom(startDate: Date?, endDate: Date?)
    var measure : String{
        switch self {
        case .weekly:
            return "주"
        case .monthly:
            return "월"
        case .yearly:
            return "년"
        case .custom:
            return "기간"
        }
    }
    // 날짜 형식에 맞는 텍스트 반환
    func formattedDateText(for date: Date = Date()) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        switch self {
        case .monthly:
            formatter.dateFormat = "yyyy년 M월"
            return formatter.string(from: date)
            
        case .yearly:
            formatter.dateFormat = "yyyy년"
            return formatter.string(from: date)
        default :
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            
            formatter.dateFormat = "yyyy년 M월 d일"
            return "\(formatter.string(from: startOfWeek)) ~ \(formatter.string(from: endOfWeek))"
        }
    }
    
    func getDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .weekly:
            return WorkoutManager().getStartAndEndOfWeek()
        case .monthly:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? now
            return (start, end)
        case .yearly:
            let start = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let end = calendar.date(byAdding: .year, value: 1, to: start) ?? now
            return (start, end)
        case .custom(let startDate, let endDate):
            return (startDate ?? now, endDate ?? now)
        }
    }
    
    func getLastPeriodDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        
        switch self {
        case .weekly:
            let start = calendar.date(byAdding: .weekOfYear, value: -1, to: getDateRange().start)!
            let end = calendar.date(byAdding: .weekOfYear, value: -1, to: getDateRange().end)!
            return (start, end)
        case .monthly:
            let start = calendar.date(byAdding: .month, value: -1, to: getDateRange().start)!
            let end = calendar.date(byAdding: .month, value: -1, to: getDateRange().end)!
            return (start, end)
        case .yearly:
            let start = calendar.date(byAdding: .year, value: -1, to: getDateRange().start)!
            let end = calendar.date(byAdding: .year, value: -1, to: getDateRange().end)!
            return (start, end)
        case .custom:
            fatalError("Custom range does not support last period comparison")
        }
    }
}
extension TimePeriod: CaseIterable {
    static var allCases: [TimePeriod] {
        return [.weekly, .monthly, .yearly,.custom(startDate: nil, endDate: nil)]
    }
}
extension TimePeriod {
    func isSameCase(as other: TimePeriod) -> Bool {
        switch (self, other) {
        case (.weekly, .weekly), (.monthly, .monthly), (.yearly, .yearly):
            return true
        case (.custom, .custom):
            return true // 내부 값 무시
        default:
            return false
        }
    }
}



enum HeartRateZone: String {
    case below50 = "50% 이하"
    case below60 = "60% 이하"
    case below70 = "70% 이하"
    case below80 = "80% 이하"
    case above90 = "90% 이상"
}

extension WorkoutManager {
    /// 특정 기간(TimePeriod) 동안의 심박수 구간 분석
    func analyzeHeartRateZonesForTimePeriod(for timePeriod: TimePeriod, completion: @escaping () -> Void) {
        self.resetDatas()
        
        guard let maxRate = maxHeartRate else {
            print("💀 maxHeartRate가 설정되지 않았습니다.")
            completion()
            return
        }
        
        guard let dateRange = getDateRange(for: timePeriod) else { return }
        
        fetchWeeklyData(type: .heartRate, start: dateRange.start, end: dateRange.end) { samples in
            guard let samples = samples, !samples.isEmpty else {
                print("심박수 데이터가 없습니다.start : \(dateRange.start),end : \(dateRange.end)")
                self.updateWorkoutProgressArray(from: [:]) // 데이터가 없으면 빈 값으로 업데이트
                completion()
                return
            }
            
            // 데이터 그룹화 기준 결정 (1개월 이상일 경우 월 단위 그룹화)
            let calendar = Calendar.current
            let groupingUnit: Calendar.Component = {
                if case .yearly = timePeriod {
                    return .month
                } else if case .custom(let startDate?, let endDate?) = timePeriod,
                          calendar.dateComponents([.month], from: startDate, to: endDate).month ?? 0 >= 1 {
                    return .month
                } else {
                    return .day
                }
            }()
            
            // 그룹화된 샘플 데이터
            let groupedSamples = Dictionary(grouping: samples) { sample in
                switch groupingUnit {
                case .month:
                    // 월 단위 그룹화: year, month를 사용하여 날짜 생성
                    let components = calendar.dateComponents([.year, .month], from: sample.startDate)
                    return calendar.date(from: components) ?? sample.startDate // 날짜가 없으면 기본적으로 시작 날짜 반환
                case .day:
                    // 일 단위 그룹화
                    return calendar.startOfDay(for: sample.startDate)
                default:
                    // 기본: 시작 날짜 반환
                    return sample.startDate
                }
            }
            
            
            // 각 그룹의 최고 심박수 계산
            let maxHeartRatesByDate: [DValue] = groupedSamples.compactMap { (date, samples) in
                guard let maxSample = samples.max(by: { $0.quantity.doubleValue(for: .count().unitDivided(by: .minute())) < $1.quantity.doubleValue(for: .count().unitDivided(by: .minute())) }) else {
                    return nil
                }
                
                return DValue(date: date, value: maxSample.quantity.doubleValue(for: .count().unitDivided(by: .minute())))
            }
            
            DispatchQueue.main.async {
                self.chartData = maxHeartRatesByDate
                print("Updated chartData: \(self.chartData)")
            }
            
            completion()
        }
    }
    
    
    /// 심박수 구간별 분포 계산
    func calculateHeartRateDistributionDetail(for samples: [HKQuantitySample], maxHeartRate: Double) -> [String: Double] {
        var timeInZones: [String: Double] = [
            "50% 이상": 0,
            "60% 이상": 0,
            "70% 이상": 0,
            "80% 이상": 0,
            "90% 이상": 0
        ]
        
        let heartRateZones: [(threshold: Double, label: String)] = [
            (maxHeartRate * 0.9, "90% 이상"),
            (maxHeartRate * 0.8, "80% 이상"),
            (maxHeartRate * 0.7, "70% 이상"),
            (maxHeartRate * 0.6, "60% 이상"),
            (maxHeartRate * 0.5, "50% 이상")
        ]
        
        for sample in samples {
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            
            for zone in heartRateZones {
                if heartRate >= zone.threshold {
                    timeInZones[zone.label]! += 1
                    break
                }
            }
        }
        
        let totalSamples = samples.count
        guard totalSamples > 0 else {
            return timeInZones.mapValues { _ in 0 }
        }
        
        var distribution: [String: Double] = [:]
        for (zone, count) in timeInZones {
            distribution[zone] = (count / Double(totalSamples)) * 100
        }
        
        return distribution
    }
    
    func getDateRange(for timePeriod: TimePeriod) -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date()
        
        switch timePeriod {
        case .weekly:
            return getStartAndEndOfWeek()
        case .monthly:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? now
            return (start, end)
        case .yearly:
            let start = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let end = calendar.date(byAdding: .year, value: 1, to: start) ?? now
            return (start, end)
        case .custom(let startDate, let endDate):
            let startDate = timePeriod.getDateRange().start
            let endDate = timePeriod.getDateRange().end
            //                print("💀 Invalid custom date range: startDate or endDate is nil.")
            //                return nil
            //            }
            return (startDate, endDate)
        }
    }
    
}
struct MetricDetail {
    var total: Double = 0.0
    var average: Double = 0.0
    var max: Double = 0.0
}

extension WorkoutManager {
    /// SummaryType과 TimePeriod에 따라 데이터를 업데이트
    func updateSummary(for summaryType: SummaryType, timePeriod: TimePeriod, completion: @escaping () -> Void) {
        guard let dateRange = getDateRange(for: timePeriod) else {return}
        
        switch summaryType {
        case .calorie:
            fetchWeeklyData(type: .activeEnergyBurned, start: dateRange.start, end: dateRange.end) { samples in
                self.processSamples(samples, for: summaryType, unit: HKUnit.kilocalorie(),timePeriod: timePeriod, completion: completion)
            }
        case .walk:
            fetchWeeklyData(type: .stepCount, start: dateRange.start, end: dateRange.end) { samples in
                self.processSamples(samples, for: summaryType, unit: HKUnit.count(), timePeriod: timePeriod, completion: completion)
            }
        case .distance:
            fetchWeeklyData(type: .distanceWalkingRunning, start: dateRange.start, end: dateRange.end) { samples in
                self.processSamples(samples, for: summaryType, unit: HKUnit.meterUnit(with: .kilo), timePeriod: timePeriod, completion: completion)
            }
        case .heartRate: // 심박수 데이터 처리 추가
            fetchWeeklyData(type: .heartRate, start: dateRange.start, end: dateRange.end) { samples in
                self.processSamples(samples, for: summaryType, unit: HKUnit(from: "count/min"), timePeriod: timePeriod, completion: completion)
            }
        case .pace:
            // Face 관련 데이터는 특별한 처리가 필요하거나 가정된 데이터
            fetchWeeklyData(type: .heartRate, start: dateRange.start, end: dateRange.end) { samples in
                self.processSamples(samples, for: summaryType, unit: HKUnit(from: "count/min"), timePeriod: timePeriod, completion: completion)
            }
        case .workoutDuration:
            return
        }
    }
    
    /// 데이터를 처리하고 summaryArray에 추가
    private func processSamples(_ samples: [HKQuantitySample]?, for type: SummaryType, unit: HKUnit, timePeriod: TimePeriod, completion: @escaping () -> Void) {
        guard let samples = samples, !samples.isEmpty else {
            DispatchQueue.main.async {
                self.summaryArray = [SummaryRow(
                    summaryType: type,
                    stack: SummaryRowElement(Str: "\(type.element.title) 데이터 없음", Updown: nil, Value: nil),
                    best: SummaryRowElement(Str: "최고값 없음", Updown: nil, Value: nil),
                    duration: nil
                )]
                completion()
            }
            return
        }
        
        if type == .pace {
            checkYear(for: timePeriod) { samples in
                let pace = self.calculatePace(from: samples) // 평균 페이스 계산
                
                // 최고 페이스 계산 (최소 시간/거리 비율, 즉 최고 속도에 해당하는 페이스)
                let bestPace = samples
                    .map { sample in
                        let distance = sample.quantity.doubleValue(for: .meterUnit(with: .kilo))
                        let duration = sample.endDate.timeIntervalSince(sample.startDate) / 60.0 // 분 단위로 변환
                        return duration / distance // 분/km
                    }
                    .min() ?? 0.0 // 최솟값, 기본값은 0.0
                
                DispatchQueue.main.async {
                    self.summaryArray = [
                        SummaryRow(
                            summaryType: .pace,
                            stack: SummaryRowElement(Str: "이번 \(timePeriod.measure) 평균 페이스", Updown: nil, Value: pace),
                            best: SummaryRowElement(Str: "페이스 최고 기록", Updown: nil, Value: bestPace),
                            duration: nil
                        )
                    ]
                    print("PaceSummaryArray: \(self.summaryArray)")
                    completion()
                }
            }
            
            return
        }
        
        
        
        // 기존 로직 유지
        let totalValue = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: unit) }
        let days = Double(Calendar.current.dateComponents([.day], from: timePeriod.getDateRange().start, to: timePeriod.getDateRange().end).day! + 1)
        let dailyAverage = totalValue / days
        let maxValue = samples.max(by: { $0.quantity.doubleValue(for: unit) < $1.quantity.doubleValue(for: unit) })?.quantity.doubleValue(for: unit) ?? 0
        
        if case .custom = timePeriod {
            // Custom 시간 처리
            DispatchQueue.main.async {
                self.summaryArray = [
                    SummaryRow(
                        summaryType: type,
                        stack: SummaryRowElement(Str: "이번 \(timePeriod.measure) 일평균", Updown: nil, Value: dailyAverage),
                        best: SummaryRowElement(Str: "", Updown: nil, Value: nil),
                        duration: nil
                    ),
                    SummaryRow(
                        summaryType: type,
                        stack: SummaryRowElement(Str: "이번 \(timePeriod.measure) 최고", Updown: nil, Value: maxValue),
                        best: SummaryRowElement(Str: "", Updown: nil, Value: nil),
                        duration: nil
                    ),
                    SummaryRow(
                        summaryType: type,
                        stack: SummaryRowElement(Str: "이번 \(timePeriod.measure) 누적", Updown: nil, Value: totalValue),
                        best: SummaryRowElement(Str: "", Updown: nil, Value: nil),
                        duration: nil
                    )
                ]
                completion()
            }
            return
        } else {
            // 지난 기간 데이터 가져오기
            let lastPeriodRange = timePeriod.getLastPeriodDateRange()
            if let quantityType = type.toQuantityType() {
                fetchWeeklyData(type: quantityType, start: lastPeriodRange.start, end: lastPeriodRange.end) { lastPeriodSamples in
                    let lastTotalValue = lastPeriodSamples?.reduce(0.0) { $0 + $1.quantity.doubleValue(for: unit) } ?? 0
                    let lastDays = Double(Calendar.current.dateComponents([.day], from: lastPeriodRange.start, to: lastPeriodRange.end).day! + 1)
                    let lastDailyAverage = lastTotalValue / lastDays
                    let lastMaxValue = lastPeriodSamples?.max(by: { $0.quantity.doubleValue(for: unit) < $1.quantity.doubleValue(for: unit) })?.quantity.doubleValue(for: unit) ?? 0
                    
                    DispatchQueue.main.async {
                        self.summaryArray = [
                            SummaryRow(
                                summaryType: type,
                                stack: SummaryRowElement(Str: "이번 \(timePeriod.measure) 일평균", Updown: nil, Value: dailyAverage),
                                best: SummaryRowElement(Str: "지난 \(timePeriod.measure) 일평균", Updown: nil, Value: lastDailyAverage),
                                duration: nil
                            ),
                            SummaryRow(
                                summaryType: type,
                                stack: SummaryRowElement(Str: "이번 \(timePeriod.measure) 최고", Updown: nil, Value: maxValue),
                                best: SummaryRowElement(Str: "지난 \(timePeriod.measure) 최고", Updown: nil, Value: lastMaxValue),
                                duration: nil
                            ),
                            SummaryRow(
                                summaryType: type,
                                stack: SummaryRowElement(Str: "이번 \(timePeriod.measure) 누적", Updown: nil, Value: totalValue),
                                best: SummaryRowElement(Str: "지난 \(timePeriod.measure) 누적", Updown: nil, Value: lastTotalValue),
                                duration: nil
                            )
                        ]
                        completion()
                    }
                }
            }
        }
    }
    
    // 페이스 계산을 위한 메서드 추가
    private func calculatePace(from samples: [HKQuantitySample]) -> Double {
        var totalDistance: Double = 0.0
        var totalTime: TimeInterval = 0.0
        
        for sample in samples {
            // 거리 데이터인지 확인
            if sample.quantityType == HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
                let distance = sample.quantity.doubleValue(for: .meterUnit(with: .kilo)) // km 단위로 거리 가져오기
                let duration = sample.endDate.timeIntervalSince(sample.startDate) // 초 단위로 시간 계산
                
                totalDistance += distance
                totalTime += duration
                print("totalDistance:\(totalDistance)")
            } else {
                print("Unsupported quantity type: \(sample.quantityType.identifier)")
            }
        }
        
        // 페이스 계산: 총 시간(분) / 총 거리(킬로미터)
        return totalDistance > 0 ? (totalTime / 60.0) / totalDistance : 0.0
    }
    
    func checkYear(for timePeriod: TimePeriod, completion: @escaping ([HKQuantitySample]) -> Void) {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let dateRange = timePeriod.getDateRange()
        
        let predicate = HKQuery.predicateForSamples(withStart: dateRange.start, end: dateRange.end, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            if let error = error {
                print("Error fetching distance data: \(error.localizedDescription)")
                completion([]) // 빈 배열 반환
                return
            }
            
            guard let samples = results as? [HKQuantitySample], !samples.isEmpty else {
                print("No distance data found")
                completion([]) // 빈 배열 반환
                return
            }
            
            print("Found \(samples.count) distance samples")
            completion(samples) // 쿼리 결과 전달
        }
        
        healthStore.execute(query)
    }
}

extension WorkoutManager {
    /// 선택된 기간에 따라 현재 최고 심박수와 지난 최고 심박수를 업데이트
    func updateMaxHeartRates(for timePeriod: TimePeriod, completion: @escaping () -> Void) {
        guard let dateRange = getDateRange(for: timePeriod) else {return}
        
        // 현재 기간의 최고 심박수 가져오기
        fetchWeeklyData(type: .heartRate, start: dateRange.start, end: dateRange.end) { thisPeriodSamples in
            let thisMax = thisPeriodSamples?.max(by: {
                $0.quantity.doubleValue(for: HKUnit(from: "count/min")) < $1.quantity.doubleValue(for: HKUnit(from: "count/min"))
            })?.quantity.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            
            
            
            
            // custom 기간에서는 지난 최고 심박수 구하지 않음
            if case .custom = timePeriod {
                DispatchQueue.main.async {
                    self.LastmaxHeartRate = nil
                    completion()
                    return
                }
            }else{
                DispatchQueue.main.async {
                    self.ThismaxHeartRate = thisMax
                }
                // 지난 기간의 최고 심박수 가져오기
                guard let lastDateRange = self.getLastPeriodDateRange(for: timePeriod) else {return}
                self.fetchWeeklyData(type: .heartRate, start: lastDateRange.start, end: lastDateRange.end) { lastPeriodSamples in
                    let lastMax = lastPeriodSamples?.max(by: {
                        $0.quantity.doubleValue(for: HKUnit(from: "count/min")) < $1.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    })?.quantity.doubleValue(for: HKUnit(from: "count/min")) ?? 0
                    
                    DispatchQueue.main.async {
                        self.LastmaxHeartRate = lastMax
                        completion()
                    }
                }
            }
            
            
            
        }
    }
    
    /// 지난 기간의 시작 및 종료 날짜를 계산
    private func getLastPeriodDateRange(for timePeriod: TimePeriod) -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        
        switch timePeriod {
        case .weekly:
            guard let currentRange = getDateRange(for: .weekly) else {
                print("💀 Cannot get current weekly date range.")
                return nil
            }
            let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentRange.start)!
            let endOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentRange.end)!
            return (start: startOfLastWeek, end: endOfLastWeek)
            
        case .monthly:
            guard let currentRange = getDateRange(for: .monthly) else {
                print("💀 Cannot get current monthly date range.")
                return nil
            }
            let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: currentRange.start)!
            let endOfLastMonth = calendar.date(byAdding: .month, value: -1, to: currentRange.end)!
            return (start: startOfLastMonth, end: endOfLastMonth)
            
        case .yearly:
            guard let currentRange = getDateRange(for: .yearly) else {
                print("💀 Cannot get current yearly date range.")
                return nil
            }
            let startOfLastYear = calendar.date(byAdding: .year, value: -1, to: currentRange.start)!
            let endOfLastYear = calendar.date(byAdding: .year, value: -1, to: currentRange.end)!
            return (start: startOfLastYear, end: endOfLastYear)
            
        case .custom:
            preconditionFailure("Custom period does not support last max heart rate.")
        }
    }
    
}





