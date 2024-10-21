//
//  DoubleExt.swift
//  BruningRank
//
//  Created by mac on 10/10/24.
//

import Foundation

extension Double {
    // 소수점 두 자리로 포맷팅된 문자열을 반환하는 메서드
    func toString(withDecimalPlaces places: Int) -> String {
        return String(format: "%.\(places)f", self)
    }
}
