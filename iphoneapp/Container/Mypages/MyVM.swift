//
//  MyVM.swift
//  iphoneapp
//
//  Created by mac on 11/6/24.
//
import Foundation
import HealthKit

class MyVM: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var SummaryArray: Array<SummaryRow> = []
    @Published var existWeeks: Array<String> = []
    @Published var workoutTime : String?
}

extension MyVM {
    func getTodayData() {
        // 오늘의 시작과 끝 날짜
        let (startOfToday, endOfToday) = getStartAndEndOfDay()

        // Helper function to fetch today's data
        func fetchTodayData(type: HKQuantityTypeIdentifier, measureUnit: HKUnit, summaryType: SummaryType) {
            fetchDailyData(type: type, start: startOfToday, end: endOfToday) { todaySamples in
                guard let todaySamples = todaySamples, !todaySamples.isEmpty else {
                    print("오늘 \(summaryType.element.title) 데이터가 없습니다.")
                    return
                }

                let todayTotal = todaySamples.reduce(0) {
                    $0 + $1.quantity.doubleValue(for: measureUnit)
                }

                let maxToday = todaySamples.max(by: {
                    $0.quantity.doubleValue(for: measureUnit) < $1.quantity.doubleValue(for: measureUnit)
                })?.quantity.doubleValue(for: measureUnit) ?? 0

                DispatchQueue.main.async {
                    let newRow = SummaryRow(
                        summaryType: summaryType,
                        stack: SummaryRowElement(Str: "오늘 누적", Updown: nil, Value: todayTotal),
                        best: SummaryRowElement(Str: "오늘 최고", Updown: nil, Value: maxToday),
                        duration: nil
                    )
                    if let index = self.SummaryArray.firstIndex(where: { $0.summaryType == summaryType }) {
                        self.SummaryArray[index] = newRow
                    } else {
                        self.SummaryArray.append(newRow)
                    }
                }
            }
            getTodayWorkoutDuration()
        }

        // 오늘의 운동 시간 계산
        func getTodayWorkoutDuration() {
            fetchTodayWorkoutDuration(start: startOfToday, end: endOfToday) { totalWorkoutDuration in
                DispatchQueue.main.async {
                    let hours = Int(totalWorkoutDuration) / 60
                    let minutes = Int(totalWorkoutDuration) % 60
                    let seconds = Int((totalWorkoutDuration - Double(Int(totalWorkoutDuration))) * 60)

                    let formattedTime = String(format: "%02d : %02d : %02d", hours, minutes, seconds)

                    let newRow = SummaryRow(
                        summaryType: .workoutDuration,
                        stack: SummaryRowElement(Str: "오늘 운동 시간", Updown: nil, Value: totalWorkoutDuration),
                        best: SummaryRowElement(Str: "오늘 운동 시간", Updown: nil, Value: totalWorkoutDuration),
                        duration: nil
                    )
                    if let index = self.SummaryArray.firstIndex(where: { $0.summaryType == .workoutDuration }) {
                        self.SummaryArray[index] = newRow
                    } else {
                        self.SummaryArray.append(newRow)
                    }
                    self.workoutTime = formattedTime
                    print("오늘 총 운동 시간: \(formattedTime)")
                }
            }
        }


        // 기존 데이터 유지
        fetchTodayData(type: .heartRate, measureUnit: HKUnit(from: "count/min"), summaryType: .heartRate)
        fetchTodayData(type: .stepCount, measureUnit: HKUnit.count(), summaryType: .walk)
        fetchTodayData(type: .distanceWalkingRunning, measureUnit: HKUnit.meterUnit(with: .kilo), summaryType: .distance)
        fetchTodayData(type: .activeEnergyBurned, measureUnit: HKUnit.kilocalorie(), summaryType: .calorie)

        
    }

    func fetchTodayWorkoutDuration(start: Date, end: Date, completion: @escaping (Double) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let workoutType = HKObjectType.workoutType()

        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            if let error = error {
                print("Error fetching workout duration: \(error.localizedDescription)")
                completion(0)
                return
            }

            let totalDuration = (samples as? [HKWorkout])?.reduce(0) {
                $0 + $1.duration / 60 // 분 단위 변환
            } ?? 0

            completion(totalDuration)
        }

        healthStore.execute(query)
    }

    func fetchDailyData(type: HKQuantityTypeIdentifier, start: Date, end: Date, completion: @escaping ([HKQuantitySample]?) -> Void) {
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

    func getStartAndEndOfDay() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
        return (startOfDay, endOfDay)
    }
}
