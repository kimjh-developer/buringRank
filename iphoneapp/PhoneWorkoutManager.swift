//
//  PhoneWorkoutManager.swift
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
    @Published var AuthoriseWarn : Bool = false
    @Published var AuthorizationFullyGranted = false
    var userAge : Int?
    @Published var SummaryArray : Array<SummaryRow> = []
    
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
        HKObjectType.activitySummaryType()
    ]

    func startWorkout(workoutType: HKWorkoutActivityType) {}
    func requestAuthorization() {
        // 공유 권한(toShare)은 nil로 설정하여 무시하고 읽기 권한만 요청
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                DispatchQueue.main.async {
                    // 읽기 권한만 확인
                    var allPermissionsGranted = true
                    
                    for type in self.typesToRead {
                        // 읽기 권한만 로그로 출력
                        let status = self.healthStore.authorizationStatus(for: type)
                        
                        switch status {
                        case .sharingAuthorized,.sharingDenied:
                            print("\(type.identifier): Reading Authorized") // 읽기 권한만 표시
                        case  .notDetermined:
                            print("\(type.identifier): Reading Denied or Not Determined")
                            allPermissionsGranted = false
                        @unknown default:
                            print("\(type.identifier): Unknown Status")
                            allPermissionsGranted = false
                        }
                    }
                    
                    if allPermissionsGranted {
                        DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                            self.AuthorizationFullyGranted = true
                            print("Authorization Fully Granted for Reading")
                        }
                    } else {
                        self.AuthoriseWarn = true
                        print("Partial Authorization Granted: Some permissions were denied for reading.")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.AuthoriseWarn = true
                }
                print("💀 Authorization NOT Granted: \(error?.localizedDescription ?? "No error")")
            }
        }
    }

    func getStartAndEndOfWeek() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? now
        return (startOfWeek, endOfWeek)
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

    func getWeekData() {
        let workoutmanager = WorkoutManager()
        
        // 현재 주의 시작과 끝 날짜
        let (startOfThisWeek, endOfThisWeek) = workoutmanager.getStartAndEndOfWeek()
        // 지난 주의 시작과 끝 날짜
        let startOfLastWeek = Calendar.current.date(byAdding: .day, value: -7, to: startOfThisWeek)!
        let endOfLastWeek = Calendar.current.date(byAdding: .day, value: -7, to: endOfThisWeek)!
        
        // Helper function to fetch and compare data
        func fetchAndCompare(type: HKQuantityTypeIdentifier, measureUnit: HKUnit, summaryType: SummaryCommon) {
            workoutmanager.fetchWeeklyData(type: type, start: startOfLastWeek, end: endOfLastWeek) { lastWeekSamples in
                let lastWeekTotal = lastWeekSamples?.reduce(0) {
                    $0 + $1.quantity.doubleValue(for: measureUnit)
                } ?? 0
                
                workoutmanager.fetchWeeklyData(type: type, start: startOfThisWeek, end: endOfThisWeek) { thisWeekSamples in
                    let thisWeekTotal = thisWeekSamples?.reduce(0) {
                        $0 + $1.quantity.doubleValue(for: measureUnit)
                    } ?? 0
                    
                    let difference = thisWeekTotal - lastWeekTotal
                    
                    let maxThisWeek = thisWeekSamples?.max(by: {
                        $0.quantity.doubleValue(for: measureUnit) < $1.quantity.doubleValue(for: measureUnit)
                    })?.quantity.doubleValue(for: measureUnit) ?? 0
                    
                    DispatchQueue.main.async {
                        let newRow = SummaryRow(
                            summaryCommon: summaryType,
                            stack: SummaryRowElement(Str: "이번주 누적", Updown: Int(difference), Value: thisWeekTotal),
                            best: SummaryRowElement(Str: "이번주 최고", Updown: nil, Value: maxThisWeek)
                        )
                        if let index = self.SummaryArray.firstIndex(where: { $0.summaryCommon == summaryType }) {
                            self.SummaryArray[index] = newRow
                        } else {
                            self.SummaryArray.append(newRow)
                        }
                    }
                }
            }
        }
        
        // Fetch and compare for walk, calorie, and distance
        fetchAndCompare(type: .stepCount, measureUnit: HKUnit.count(), summaryType: .walk)
        fetchAndCompare(type: .distanceWalkingRunning, measureUnit: HKUnit.meterUnit(with: .kilo), summaryType: .distance)
        fetchAndCompare(type: .activeEnergyBurned, measureUnit: HKUnit.kilocalorie(), summaryType: .calorie)
    }
    
    
    
    

    
    
    
    //지정일자에 데이터를 구함
    func getStartOfWeek(for date: Date) -> Date {
            let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start.dayAfter(2) ?? date
            
            return calendar.startOfDay(for: startOfWeek)
        }

        func getDateForWeekday(weekday: Int) -> Date? {
            let calendar = Calendar.current
            let startOfWeek = getStartOfWeek(for: Date())
            return calendar.date(byAdding: .day, value: weekday, to: startOfWeek)
        }

        func getStartAndEndOfDay(for date: Date) -> (start: Date, end: Date) {
            let calendar = Calendar.current
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
            print("date:\(date)")
            let calendar = Calendar.current
            guard let lastWeekSameDay = calendar.date(byAdding: .weekOfYear, value: -1, to: date) else { return }
            
            let (startOfSelectedDay, endOfSelectedDay) = getStartAndEndOfDay(for: date)
            let (startOfLastWeekSameDay, endOfLastWeekSameDay) = getStartAndEndOfDay(for: lastWeekSameDay)
            
            func fetchAndCompare(type: HKQuantityTypeIdentifier, measureUnit: HKUnit, summaryType: SummaryCommon) {
                fetchWeeklyData(type: type, start: startOfLastWeekSameDay, end: endOfLastWeekSameDay) { lastWeekSamples in
                    let lastWeekTotal = lastWeekSamples?.reduce(0) {
                        $0 + $1.quantity.doubleValue(for: measureUnit)
                    } ?? 0
                    
                    self.fetchWeeklyData(type: type, start: startOfSelectedDay, end: endOfSelectedDay) { thisWeekSamples in
                        let thisWeekTotal = thisWeekSamples?.reduce(0) {
                            $0 + $1.quantity.doubleValue(for: measureUnit)
                        } ?? 0
                        
                        let difference = thisWeekTotal - lastWeekTotal
                        
                        let maxThisDay = thisWeekSamples?.max(by: {
                            $0.quantity.doubleValue(for: measureUnit) < $1.quantity.doubleValue(for: measureUnit)
                        })?.quantity.doubleValue(for: measureUnit) ?? 0
                        
                        DispatchQueue.main.async {
                            let newRow = SummaryRow(
                                summaryCommon: summaryType,
                                stack: SummaryRowElement(Str: "\(calendar.component(.month, from: date))월 \(calendar.component(.day, from: date))일 누적", Updown: Int(difference), Value: thisWeekTotal),
                                best: SummaryRowElement(Str: "\(calendar.component(.month, from: date))월 \(calendar.component(.day, from: date))일 최고", Updown: nil, Value: maxThisDay)
                            )
                            if let index = self.SummaryArray.firstIndex(where: { $0.summaryCommon == summaryType }) {
                                self.SummaryArray[index] = newRow
                            } else {
                                self.SummaryArray.append(newRow)
                            }
                        }
                    }
                }
            }
            
            fetchAndCompare(type: .stepCount, measureUnit: HKUnit.count(), summaryType: .walk)
            fetchAndCompare(type: .distanceWalkingRunning, measureUnit: HKUnit.meterUnit(with: .kilo), summaryType: .distance)
            fetchAndCompare(type: .activeEnergyBurned, measureUnit: HKUnit.kilocalorie(), summaryType: .calorie)
        }

        func performComparisonForSelectedWeekday(weekday: Int) {
            guard let selectedDate = getDateForWeekday(weekday: weekday) else {
                print("Invalid weekday selected.")
                return
            }

            getDailyComparisonData(for: selectedDate)
        }
    


}
