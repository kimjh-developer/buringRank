//
//  RecordDetailDVO.swift
//  iphoneapp
//
//  Created by mac on 10/29/24.
//

import Foundation

//enum DateType:String,CaseIterable{
//    case WEEK,MONTH,YEAR,PERIOD
//    var name:String{
//        self.rawValue
//    }
//    var measure : String{
//        switch self {
//        case .WEEK:
//            return "주"
//        case .MONTH:
//            return "월"
//        case .YEAR:
//            return "년"
//        case .PERIOD:
//            return ""
//        }
//    }
//    // 날짜 형식에 맞는 텍스트 반환
//       func formattedDateText(for date: Date = Date()) -> String {
//           let calendar = Calendar.current
//           let formatter = DateFormatter()
//           formatter.locale = Locale(identifier: "ko_KR")
//
//           switch self {
//           case .MONTH:
//               formatter.dateFormat = "yyyy년 M월"
//               return formatter.string(from: date)
//
//           case .YEAR:
//               formatter.dateFormat = "yyyy년"
//               return formatter.string(from: date)
//           default :
//               let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
//               let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
//
//               formatter.dateFormat = "yyyy년 M월 d일"
//               return "\(formatter.string(from: startOfWeek)) ~ \(formatter.string(from: endOfWeek))"
//           }
//       }
//}



struct DValue{
    var date: Date
    var value: Double
}
