//
//  StringExt.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/9/24.
//

import Foundation
import SwiftUI

enum StringType{
    case klight,kmedium,kbold,player
    var name : String{
        switch self {
            case .klight: return "KBO-Dia-Gothic-Light"
            case .kmedium: return "KBO-Dia-Gothic-Medium"
            case .kbold: return "KBO-Dia-Gothic-Bold"
            case .player: return "I-AM-A-PLAYER"
        }
    }
}


// View 확장 정의
extension View {
    func style(fontName: StringType, fontSize: CGFloat = 24, fontColor: Color = .black) -> some View {
        self
            .font(Font.custom(fontName.name, size: fontSize))
            .foregroundColor(fontColor)
    }

    func withUnderline(height: CGFloat = 5, color: Color = .clear) -> some View {
            self
                .background(
                    GeometryReader { geometry in
                        VStack {
                            Spacer() // Text와 언더라인 간의 여백을 없앰
                            Rectangle()
                                .frame(width: geometry.size.width, height: height) // Text의 너비에 맞춤
                                .foregroundColor(color) // 언더라인 색상 설정
                        }
                    }
                )
        }
}


extension Date {
    /// 오늘의 요일을 문자열로 반환하는 메서드
    func dayOfWeek(locale: Locale = Locale(identifier: "ko_KR")) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale // 로케일 설정 (기본: 한국어)
        formatter.dateFormat = "E" // 요일 포맷
        return formatter.string(from: self)
    }
}



