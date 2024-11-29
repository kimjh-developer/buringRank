//
//  IntExt.swift
//  BruningRank
//
//  Created by mac on 10/14/24.
//

import Foundation

extension Int{
    func intToHMS() -> String {
        var retTime = ""
        if self / 3600 < 10 {retTime += "0"}
        retTime += "\(self / 3600):"
        if ((self % 3600) / 60) < 10 {retTime += "0"}
        retTime += "\((self % 3600) / 60):"
        if ((self % 3600) % 60) < 10 {retTime += "0"}
        retTime += "\((self % 3600) % 60)"
        return retTime
    }
    
    func formatSeconds() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let remainingSeconds = self % 60
           
           return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
       }
    
    func formatSingleNumber() -> String {
            let formattedNumber: String
            if self < 10 {
                formattedNumber = String(format: "0%d", self)
            } else {
                formattedNumber = String(self)
            }
            return formattedNumber
        }
    
    func addComma() -> String {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
        }
}

extension Array where Element == Int {
    func average() -> Double? {
        guard !self.isEmpty else { return nil }
        let sum = self.reduce(0, +)
        return Double(sum) / Double(self.count)
    }
    
    func total() -> Int {
       return self.reduce(0, +)
    }
}
extension Array where Element == TimeInterval {
    /// 배열의 평균을 계산합니다. 배열이 비어있으면 `nil`을 반환합니다.
    func average() -> TimeInterval? {
        guard !self.isEmpty else { return nil }
        let total = self.reduce(0, +) // 합계를 계산
        return total / TimeInterval(self.count) // 평균 계산
    }
    
    func total() -> TimeInterval {
        return self.reduce(0, +)
        }
}


