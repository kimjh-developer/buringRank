//
//  RecordVM.swift
//  iphoneapp
//
//  Created by mac on 10/22/24.
//

import Foundation
import SwiftUI
class RecordVM : ObservableObject{
    @Published var workoutDay : [Int] = [0,2,3]
    @Published var selectDay : Int?
    @Published var hearRate : Int?
    @Published var updownValue : Int?
    @Published var isFreeMember : Bool = true
    @Published var workoutProgressArray : Array<WorkoutProgress>=[
        WorkoutProgress(progressLevel : .level1, percentage: 10, time: "12:22:11"),
        WorkoutProgress(progressLevel : .level2, percentage: 15, time: "11:62:15"),
        WorkoutProgress(progressLevel : .level3, percentage: 20, time: "05:52:14"),
        WorkoutProgress(progressLevel : .level4, percentage: 18, time: "09:42:17"),
        WorkoutProgress(progressLevel : .level5, percentage: 42, time: "15:22:15"),
    ]
    
    @Published var SummaryArray : Array<SummaryRow> = [
        SummaryRow(summaryCommon:.calorie, stackStr: "이번주 누적",  stackValue: 1234.addComma(), bestStr: "이번주 최고", bestUpdown: 100, bestValue: 735.addComma()),
        SummaryRow(summaryCommon:.walk, stackStr: "이번주 누적",  stackValue: 30000.addComma(),  bestStr: "이번주 최고", bestUpdown: -100, bestValue: 735.addComma()),
        SummaryRow(summaryCommon:.distance, stackStr: "이번주 누적",  stackValue: 32.addComma(),  bestStr: "이번주 최고", bestUpdown: 95, bestValue: 735.addComma()),
        SummaryRow(summaryCommon:.face, stackStr: "이번주 누적",  stackValue: 153.addComma(),  bestStr: "이번주 최고", bestUpdown: -60, bestValue: 140.addComma()),
]
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

struct SummaryRow:Hashable {
    var summaryCommon : SummaryCommon
    var stackStr : String
    var stackUpdown : Int?
    var stackValue : String?
    var bestStr : String?
    var bestUpdown : Int?
    var bestValue : String?
}

enum SummaryCommon{
    case calorie,walk,distance,face
    var element : SummaryElement{
        switch self {
        case .calorie:
            return SummaryElement(title: "소모 칼로리", measure: "KCAL")
        case .walk:
            return SummaryElement(title: "걸음수", measure: "걸음")
        case .distance:
            return SummaryElement(title: "이동거리", measure: "km")
        case .face:
            return SummaryElement(title: "페이스")
        }
    }
}
struct SummaryElement {
    var title : String
    var measure : String?
}
