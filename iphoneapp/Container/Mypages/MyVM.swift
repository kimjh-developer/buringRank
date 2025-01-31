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
    @Published var nickName : String?
}

extension MyVM {
    
    func getThisMonthData() {
        // 이번 달의 시작과 끝 날짜
        UserAthenicationVM().loadUserInformation(completion: { info in
            if let userNickname = info?.userNickname{
                DispatchQueue.main.async{
                    self.nickName = userNickname
                }
            }
        })
        
        let (startOfMonth, endOfMonth) = getStartAndEndOfMonth()

        // Helper function to fetch monthly data and calculate max
        func fetchMonthlyData(type: HKQuantityTypeIdentifier, measureUnit: HKUnit, summaryType: SummaryType) {
            fetchData(type: type, start: startOfMonth, end: endOfMonth) { monthlySamples in
                guard let monthlySamples = monthlySamples, !monthlySamples.isEmpty else {
                    print("이번 달 \(summaryType.element.title) 데이터가 없습니다.")
                    return
                }

                let monthlyTotal = monthlySamples.reduce(0) {
                    $0 + $1.quantity.doubleValue(for: measureUnit)
                }
                
                let maxMonthly = monthlySamples.max(by: {
                    $0.quantity.doubleValue(for: measureUnit) < $1.quantity.doubleValue(for: measureUnit)
                })?.quantity.doubleValue(for: measureUnit) ?? 0

                DispatchQueue.main.async {
                    let newRow = SummaryRow(
                        summaryType: summaryType,
                        stack: SummaryRowElement(Str: "이번달 누적", Updown: nil, Value: monthlyTotal),
                        best: SummaryRowElement(Str: "이번달 최고", Updown: nil, Value: maxMonthly),
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

        // 이번 달 운동 시간 계산
        func getMonthlyWorkoutDuration() {
            fetchMonthlyWorkoutDuration(start: startOfMonth, end: endOfMonth) { totalWorkoutDuration in
                DispatchQueue.main.async {
                    let hours = Int(totalWorkoutDuration) / 60
                    let minutes = Int(totalWorkoutDuration) % 60
                    let seconds = Int((totalWorkoutDuration - Double(Int(totalWorkoutDuration))) * 60)

                    let formattedTime = String(format: "%02d : %02d : %02d", hours, minutes, seconds)

                   let newRow = SummaryRow(
                        summaryType: .workoutDuration,
                        stack: SummaryRowElement(Str: "이번달 운동 시간", Updown: nil, Value: totalWorkoutDuration),
                        best: SummaryRowElement(Str: "이번달 운동 시간", Updown: nil, Value: totalWorkoutDuration),
                        duration: nil
                    )
                    if let index = self.SummaryArray.firstIndex(where: { $0.summaryType == .workoutDuration }) {
                        self.SummaryArray[index] = newRow
                    } else {
                        self.SummaryArray.append(newRow)
                    }
                    self.workoutTime = formattedTime
                    print("이번 달 총 운동 시간: \(formattedTime)")
                }
            }
        }

        fetchMonthlyData(type: .heartRate, measureUnit: HKUnit(from: "count/min"), summaryType: .heartRate)
        fetchMonthlyData(type: .stepCount, measureUnit: HKUnit.count(), summaryType: .walk)
        fetchMonthlyData(type: .distanceWalkingRunning, measureUnit: HKUnit.meterUnit(with: .kilo), summaryType: .distance)
        fetchMonthlyData(type: .activeEnergyBurned, measureUnit: HKUnit.kilocalorie(), summaryType: .calorie)

        getMonthlyWorkoutDuration()
    }
    
    func fetchMonthlyWorkoutDuration(start: Date, end: Date, completion: @escaping (Double) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let workoutType = HKObjectType.workoutType()

        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            if let error = error {
                print("Error fetching workout duration: \(error.localizedDescription)")
                completion(0)
                return
            }

            let totalDuration = (samples as? [HKWorkout])?.reduce(0) {
                $0 + $1.duration / 60
            } ?? 0

            completion(totalDuration)
        }

        healthStore.execute(query)
    }

    func fetchData(type: HKQuantityTypeIdentifier, start: Date, end: Date, completion: @escaping ([HKQuantitySample]?) -> Void) {
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
    
    func getStartAndEndOfMonth() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the first day of the month
        let components = calendar.dateComponents([.year, .month], from: now)
        let startOfMonth = calendar.date(from: components)!
        
        // Get the first day of the next month
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        // Calculate the end of the current month (which is the last moment of the day before the first day of the next month)
        let endOfMonth = calendar.date(byAdding: .second, value: -1, to: nextMonth)!
        
        return (startOfMonth, endOfMonth)
    }
}


class RandomIDS{//공백없이 5자
    var element = ["푸링푸링", "쪼꼬미미", "뽀짝뽀짝", "하트뿅뿅", "반짝별이", "몽글몽글", "솜솜이이", "하늘토끼", "핑크별이", "구름토끼", "초코푸딩", "보라토끼", "별빛달이", "하양구름", "코코몽몽", "멍멍냥냥", "달빛요정", "쥬글쥬글", "라떼토끼", "삐약삐약", "새싹요정", "몽글푸름", "미소천사", "꽃송이이", "노랑별이", "달구름이", "푸딩토끼", "솜사탕이", "파랑요정", "구름푸딩", "보랏빛이", "달달미미", "쪼글쪼글", "빵빵토끼", "핑크푸름", "초록요정", "눈송이이", "바닐라몽", "솜뭉치이", "바다토끼", "사랑별이", "토끼하늘", "행복푸름", "새싹구름", "노랑하늘", "푸른별이", "보라구름", "코코달빛", "달빛토끼", "몽글별이", "멍멍하늘", "꽃별요정", "달토끼이", "쪼꼬토끼", "바나나별", "달구름토", "별빛구름", "바람토끼", "반짝푸름", "하트요정", "초코하늘", "빵토끼이", "달빛솜솜", "구름별이", "별빛푸름", "노랑꽃이", "푸른하트", "보라별이", "토끼푸름", "솜사탕별", "파랑꽃이", "구름달이", "눈꽃요정", "바다별이", "초록하늘", "사랑꽃이", "토끼별이", "행복구름", "새싹별이", "노랑푸름", "보라토끼", "바나나몽", "쪼꼬푸딩", "초코별이", "눈송이별", "구름솜솜", "행복별이", "달달요정", "쪼글푸름", "초록달빛", "바다하트", "솜뭉치별", "하늘꽃이"]
    func generateRandomID() -> String {
           return element.randomElement() ?? "아이디없음"
       }
}

//확성기 기능 - 호스트가 팀원들에게 ~~어디로 오세요 라고 알림을 보내는 기능.푸시기능
