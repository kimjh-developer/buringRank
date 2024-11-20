//
//  CalculateRecord.swift
//  iphoneapp
//
//  Created by mac on 10/24/24.
//

import Foundation

class CalculateRecord {
    final func presumeRow(dtype: TimePeriod, summaryType: SummaryType) -> [SummaryRow] {
        var rows: [SummaryRow] = []
        let titleMeasure = getTitleMeasure(for: dtype)
        let tails = getTails(for: summaryType)
        
        for tail in tails {
            let summaryRow = SummaryRow(
                summaryType: guessSummaryRow(item: summaryType),
                stack: SummaryRowElement(Str: "\(titleMeasure.this) \(tail)"),//\(summaryType.name)
                best: SummaryRowElement(Str: "\(titleMeasure.past) \(tail)"),
                duration: nil
            )
            rows.append(summaryRow)
        }
        return rows
    }
    
    private func guessSummaryRow(item:SummaryType)->SummaryType?{
        switch item {
        case .heartRate,.workoutDuration:
            return nil
        case .calorie:
            return .calorie
        case .walk:
            return .walk
        case .distance:
            return .distance
        case .face:
            return .face
        }
    }
    
    private func getTitleMeasure(for dtype: TimePeriod) -> TitleMeasure {
        switch dtype {
        case .weekly:
            return TitleMeasure(this: "이번 주 ", past: "지난 주 ")
        case .monthly:
            return TitleMeasure(this: "이번 달 ", past: "지난 달 ")
        case .yearly:
            return TitleMeasure(this: "올해 ", past: "작년 ")
        case .custom:
            return TitleMeasure(this: "기간 내 ", past: "")
        }
    }
    
    private func getTails(for summaryType: SummaryType) -> [String] {
        switch summaryType {
        case .heartRate:
            return ["최고"]
        case .face:
            return ["일평균", "최고"]
        default:
            return ["일평균", "일최고", "누적"]
        }
    }
    
    
    // SummaryRow의 value와 updown 값을 설정하는 함수
    func setSummaryValues(
        row: inout SummaryRowElement,
        value: Double?,
        updown: Int?
    ) {
        row.Value = value
        row.Updown = updown
    }
    
}

struct TitleMeasure {
    var this : String
    var past : String
}
