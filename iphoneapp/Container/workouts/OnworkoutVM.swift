//
//  OnworkoutVM.swift
//  iphoneapp
//
//  Created by mac on 10/21/24.
//

import Foundation
import SwiftUI
class OnworkoutVM:ObservableObject{
    @Published var isComplete : Bool = false
    @Published var bGLevel : BGLevel = .mid
    @Published var workoutInformationArray : [WorkoutInformation] = [
        WorkoutInformation(title: "목표심박수", content: "114-142", measure: "BPM"),
        WorkoutInformation(title: "심박수", titleICO: Image("icon_watch"),isHeart: true,content: "134", measure: "BPM"),
        WorkoutInformation(title: "운동시간", content: "00 : 58 : 24"),
        WorkoutInformation(title: "적정심박유지", content: "00 : 58 : 20"),
        WorkoutInformation(title: "오버트레이닝", content: "00 : 11 : 21"),
        WorkoutInformation(title: "휴식시간", content: "00 : 11 : 23"),
    ]
}

enum BGLevel{
    case start,low,mid,high,danger
    
    var bgcolor : [Color]{
        switch self {
        case .start:
            return [Color.ready,Color.readyBottom]
        case .low:
            return [Color.low,Color.lowBottom]
        case .mid:
            return [Color.mid,Color.midBottom]
        case .high:
            return [Color.high,Color.highBottom]
        case .danger:
            return [Color.danger,Color.dangerBottom]
        }
    }
}

struct WorkoutInformation: Hashable { // Conform to Hashable
    var title: String
    var titleICO: Image?
    var isHeart: Bool = false
    var content: String
    var measure: String?

    // Implementing the hash(into:) function if needed for custom behavior
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(content)
    }

    static func == (lhs: WorkoutInformation, rhs: WorkoutInformation) -> Bool {
        lhs.title == rhs.title && lhs.content == rhs.content
    }
}
