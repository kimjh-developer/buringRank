//
//  calculateDate.swift
//  iphoneapp
//
//  Created by mac on 10/29/24.
//

import Foundation

class CalculateDate{
    
    final func weekDates(from date: Date) -> [DValue] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 월요일을 주의 시작일로 설정

        // 주의 시작일 (월요일) 계산
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!

        // 월요일부터 일요일까지 날짜와 랜덤 value 값 배열 생성
        return (0..<7).compactMap { dayOffset in
            guard let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                return nil
            }
            let randomValue = Double.random(in: 0...100) // 0부터 100 사이의 랜덤 값 생성
            return DValue(date: currentDate, value: randomValue)
        }
    }

    
    final func datesInMonth(year: Int, month: Int) -> [DValue] {
        var calendar = Calendar.current
        calendar.timeZone = .current // 로컬 시간대 설정

        // 해당 월의 시작일 계산
        let components = DateComponents(year: year, month: month)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }

        // 월의 모든 날짜와 랜덤 value 값을 가진 배열 생성
        return range.compactMap { day -> DValue? in
            var dateComponents = components
            dateComponents.day = day
            guard let date = calendar.date(from: dateComponents) else { return nil }
            
            let randomValue = Double.random(in: 0...100) // 0부터 100 사이의 랜덤 값 생성
            return DValue(date: date, value: randomValue)
        }
    }
    
    /// 주어진 시작 날짜와 종료 날짜 사이의 모든 날짜를 반환
    func customDates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }

        return dates
    }
}
