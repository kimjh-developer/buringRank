//
//  DateExt.swift
//  iphoneapp
//
//  Created by mac on 10/23/24.
//

import Foundation

// 날짜 형식 정의: "MM월 dd일"
extension DateFormatter {
    static var koreanMonthDay : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d" // 한글 형식으로 월/일 표시
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC로 설정
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
}


import Foundation

extension Date {
    // 다음 날을 구하는 메서드
    func nextDate() -> Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }

    // 주어진 특정 날짜를 추가하여 계산하는 메서드
    func dayAfter(_ days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: self)
    }
    
    func toString(format: String = "yyyy년 MM월 dd일") -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어 형식을 위한 로케일 설정
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: self)
        }
}
