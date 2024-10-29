//
//  CalculateRecord.swift
//  iphoneapp
//
//  Created by mac on 10/24/24.
//

import Foundation

class CalculateRecord {
    final func presumeRow(dtype: DateType, summaryType: SummaryType) -> [SummaryRow] {
        var rows: [SummaryRow] = []
        let titleMeasure = getTitleMeasure(for: dtype)
        let tails = getTails(for: summaryType)
        
        for tail in tails {
            let summaryRow = SummaryRow(
                summaryCommon: guessSummaryRow(item: summaryType),
                stack: SummaryRowElement(Str: "\(titleMeasure.this) \(tail)"),//\(summaryType.name)
                best: SummaryRowElement(Str: "\(titleMeasure.past) \(tail)")//\(summaryType.name)
            )
            rows.append(summaryRow)
        }
        return rows
    }
    
    private func guessSummaryRow(item:SummaryType)->SummaryCommon?{
        switch item {
        case .heatRate:
            return nil
        case .calories:
            return .calorie
        case .walkCount:
            return .walk
        case .distance:
            return .distance
        case .face:
            return .face
        }
    }
    
    private func getTitleMeasure(for dtype: DateType) -> TitleMeasure {
        switch dtype {
        case .WEEK:
            return TitleMeasure(this: "이번 주 ", past: "지난 주 ")
        case .MONTH:
            return TitleMeasure(this: "이번 달 ", past: "지난 달 ")
        case .YEAR:
            return TitleMeasure(this: "올해 ", past: "작년 ")
        case .PERIOD:
            return TitleMeasure(this: "기간 내 ", past: "")
        }
    }
    
    private func getTails(for summaryType: SummaryType) -> [String] {
        switch summaryType {
        case .heatRate:
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
