//
//  RecordVM.swift
//  iphoneapp
//
//  Created by mac on 10/22/24.
//

import Foundation
import SwiftUI
import HealthKit
class RecordVM : ObservableObject{
    @Published var workoutDay : [Int] = [0,2,3]
    @Published var selectDay : Int?
    @Published var hearRate : Int?
    @Published var updownValue : Int?
    @Published var isFreeMember : Bool = false
    @Published var moveToMap : Bool = false
    @Published var workoutProgressArray : Array<WorkoutProgress>=[
        WorkoutProgress(progressLevel : .level1, percentage: 10, time: "12:22:11"),
        WorkoutProgress(progressLevel : .level2, percentage: 15, time: "11:62:15"),
        WorkoutProgress(progressLevel : .level3, percentage: 20, time: "05:52:14"),
        WorkoutProgress(progressLevel : .level4, percentage: 18, time: "09:42:17"),
        WorkoutProgress(progressLevel : .level5, percentage: 42, time: "15:22:15"),
    ]
    
    @Published var SummaryArray : Array<SummaryRow> = [
        SummaryRow(summaryType:.calorie,
                   stack: SummaryRowElement(Str: "이번주 누적", Updown: 1234, Value: 5545),
                   best: SummaryRowElement(Str: "이번주 최고", Updown: 1234, Value: 6542),
                   duration: nil),
        SummaryRow(summaryType:.distance,
                   stack: SummaryRowElement(Str: "이번주 누적", Updown: 1234, Value: 5545),
                   best: SummaryRowElement(Str: "이번주 최고", Updown: 1234, Value: 6542),
                   duration: nil),
        
    ]
    
    func getWeekData() {
            let workoutManager = WorkoutManager()

            // 이번 주와 저번 주 날짜 계산
            let (startOfThisWeek, endOfThisWeek) = workoutManager.getStartAndEndOfWeek()
            let startOfLastWeek = Calendar.current.date(byAdding: .day, value: -7, to: startOfThisWeek)!
            let endOfLastWeek = Calendar.current.date(byAdding: .day, value: -7, to: endOfThisWeek)!
            
            func fetchAndCompare(type: HKQuantityTypeIdentifier, measureUnit: HKUnit, summaryType: SummaryType) {
                workoutManager.fetchWeeklyData(type: type, start: startOfLastWeek, end: endOfLastWeek) { lastWeekSamples in
                    let lastWeekTotal = lastWeekSamples?.reduce(0) {
                        $0 + $1.quantity.doubleValue(for: measureUnit)
                    } ?? 0
                    
                    workoutManager.fetchWeeklyData(type: type, start: startOfThisWeek, end: endOfThisWeek) { thisWeekSamples in
                        let thisWeekTotal = thisWeekSamples?.reduce(0) {
                            $0 + $1.quantity.doubleValue(for: measureUnit)
                        } ?? 0
                        
                        let difference = thisWeekTotal - lastWeekTotal
                        
                        let maxThisWeek = thisWeekSamples?.max(by: {
                            $0.quantity.doubleValue(for: measureUnit) < $1.quantity.doubleValue(for: measureUnit)
                        })?.quantity.doubleValue(for: measureUnit) ?? 0

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
                        }
                    }
                }
            }

            // 걸음 수, 칼로리, 거리 비교
            fetchAndCompare(type: .stepCount, measureUnit: HKUnit.count(), summaryType: .walk)
            fetchAndCompare(type: .activeEnergyBurned, measureUnit: HKUnit.kilocalorie(), summaryType: .calorie)
            fetchAndCompare(type: .distanceWalkingRunning, measureUnit: HKUnit.meterUnit(with: .kilo), summaryType: .distance)
        }
    
    func getWeekdayFromDateString(_ dateString: String) -> Int {
             let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "EEE\nM/d" // 요일 표시 형식에 따라 변경
              dateFormatter.locale = Locale(identifier: "ko_KR")
           
           if let date = dateFormatter.date(from: dateString){
               let calendar = Calendar.current
               let weekDay = calendar.component(.weekday, from: date) - 1
               
               return weekDay
           }
            
           let todayDateFormatter = DateFormatter()
           todayDateFormatter.dateFormat = "M/d"
            todayDateFormatter.locale = Locale(identifier: "ko_KR")
           
           if let date = todayDateFormatter.date(from: dateString){
               let calendar = Calendar.current
                let weekDay = calendar.component(.weekday, from: date) - 1
               
                return weekDay
           }
           
           
             return 0 // 날짜 형식이 맞지 않을 경우 처리
       }

}

struct WorkoutProgress:Hashable {
    var progressLevel : ProgressLevel
    var percentage : Double
    var time : String
}

enum ProgressLevel{
    case level1,level2,level3,level4,level5
    var name:String{
        switch self {
        case .level1:
            return "중지"
        case .level2:
            return "미달"
        case .level3:
            return "적정"
        case .level4:
            return "초과"
        case .level5:
            return "위험"
        }
    }
    var color : Color{
        switch self {
        case .level1:
            return Color.progressPause
        case .level2:
            return Color.progressLow
        case .level3:
            return Color.progressMid
        case .level4:
            return Color.progressOver
        case .level5:
            return Color.progressDanger
        }
    }
}

struct SummaryRow:Equatable,Hashable {
    var summaryType : SummaryType?
    var stack : SummaryRowElement?
    var best : SummaryRowElement?
    let duration: SummaryRowElement? // 운동 시간 추가
}
struct SummaryRowElement :Equatable,Hashable {
    var Str : String?
    var Updown : Int?
    var Value : Double?
}
enum SummaryType:CaseIterable{
    case heartRate,calorie,walk,distance,pace,workoutDuration
    var element : SummaryElement{
        switch self {
        case .heartRate:
            return SummaryElement(title: "심박수", measure: "BPM")
        case .calorie:
            return SummaryElement(title: "칼로리", measure: "KCAL")
        case .walk:
            return SummaryElement(title: "걸음수", measure: "걸음")
        case .distance:
            return SummaryElement(title: "이동거리", measure: "km")
        case .pace:
            return SummaryElement(title: "페이스", measure: "km/min")
        case .workoutDuration:
            return SummaryElement(title: "운동 시간") // 운동 시간 설명 추가
        }
    }
    /// 각 SummaryType에 해당하는 HealthKit QuantityType 반환
       func toQuantityType() -> HKQuantityTypeIdentifier? {
           switch self {
           case .heartRate:
               return .heartRate
           case .calorie:
               return .activeEnergyBurned
           case .walk:
               return .stepCount
           case .distance:
               return .distanceWalkingRunning
           case .pace,.workoutDuration:
               return nil // Face 데이터는 별도의 처리가 필요하거나 미지원
           }
       }
}
struct SummaryElement {
    var title : String
    var measure : String?
}
