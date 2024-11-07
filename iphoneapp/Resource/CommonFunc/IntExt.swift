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


