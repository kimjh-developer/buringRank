//
//  RecordDetailVM.swift
//  iphoneapp
//
//  Created by mac on 10/24/24.
//

import Foundation
class RecordDetailVM:ObservableObject{
    let calculateRecord = CalculateRecord()
    let calculateDate = CalculateDate()
    @Published var selectDateType : DateType = .PERIOD
    @Published var selectSummaryType : SummaryType = .distance
    @Published var isFreeMember : Bool = false
    @Published var summaryArray : Array<SummaryRow>?
    
    @Published var chooseDate : [Date] = [Date()]
    @Published var datePopupActivate : Bool = true
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    @Published var workoutProgressArray : Array<WorkoutProgress>=[
        WorkoutProgress(progressLevel : .level1, percentage: 10, time: "12:22:11"),
        WorkoutProgress(progressLevel : .level2, percentage: 15, time: "11:62:15"),
        WorkoutProgress(progressLevel : .level3, percentage: 20, time: "05:52:14"),
        WorkoutProgress(progressLevel : .level4, percentage: 18, time: "09:42:17"),
        WorkoutProgress(progressLevel : .level5, percentage: 42, time: "15:22:15"),
    ]
    
    @Published var data: [DValue] = []
    
    @Published var choosedDatas : Array<Date>?
    @Published var warnMSG : String?
    @Published var warnActivate : Bool = false
    
    init(){
        changeSummaryArray()
        makeDateArray()
    }
    
    static func dateFromString(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC로 설정
        formatter.locale = Locale.current
        return formatter.date(from: dateString) ?? Date()
    }
    
    func changeSummaryArray(){
        summaryArray = calculateRecord.presumeRow(dtype: selectDateType, summaryType: selectSummaryType)
        addData()
    }
    
    private final func addData() {
        guard var summaryArray = summaryArray else { return } // 옵셔널 처리
        for index in summaryArray.indices {
                if var stackRow = summaryArray[index].stack {
                    calculateRecord.setSummaryValues(
                        row: &stackRow,
                        value: 150,
                        updown: 10
                    )
                    summaryArray[index].stack = stackRow // 수정된 값 재할당
                }
                
                if var bestRow = summaryArray[index].best {
                    calculateRecord.setSummaryValues(
                        row: &bestRow,
                        value: 220,
                        updown: 150
                    )
                    summaryArray[index].best = bestRow // 수정된 값 재할당
                }
            }
        self.summaryArray = summaryArray // 수정된 배열을 다시 할당
    }
    
    private final func makeDateArray(){
        switch selectDateType {
        case .WEEK:
            data = calculateDate.weekDates(from: chooseDate.first ?? Date())
        case .MONTH:
            data = calculateDate.weekDates(from: chooseDate.first ?? Date())
        case .YEAR:
            data = calculateDate.weekDates(from: chooseDate.first ?? Date())
        case .PERIOD:
            data = calculateDate.weekDates(from: chooseDate.first ?? Date())
        }
    }
}
