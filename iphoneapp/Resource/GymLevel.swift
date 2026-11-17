//
//  GymLevel.swift
//  BruningRank
//
//  Created by mac on 10/10/24.
//

import Foundation
struct WorkoutLevel{
    var fLevel : FunctionWorkLevel?
    var cLevel : CardioLevel?
    var hLevel : HikeLevel?
    var mLevel : MeditationLevel?
}

enum GymLevel {
    case functionalWorkLevel(FunctionWorkLevel)
    case cardioLevel(CardioLevel)
    case hikeLevel(HikeLevel)
    case meditationLevel(MeditationLevel)
}

enum FunctionWorkLevel:CaseIterable{
    case bulkup,powerUp
    var name:String{
        switch self {
        case .bulkup:
            return "저강도"
        case .powerUp:
            return "고강도"
        }
    }
    var detail:String{
        switch self {
        case .bulkup:
            return "근 성장을 위한 워밍업 모드"
        case .powerUp:
            return "3대 500+을 꿈꾸는 헤비 헬창 모드"
        }
    }
    var lowLevel : Double{
        switch self {
        case .bulkup:
            return 60
        case .powerUp:
            return 70
        }
    }
    var highLevel : Double{
        switch self {
        case .bulkup:
            return 75
        case .powerUp:
            return 80
        }
    }
}
enum CardioLevel:CaseIterable{
    case level1,level2,level3,level4,level5
    var name:String{
        switch self {
        case .level1:
            return "1단계"
        case .level2:
            return "2단계"
        case .level3:
            return "3단계"
        case .level4:
            return "4단계"
        case .level5:
            return "5단계"
        }
    }
    var detail:String{
        switch self {
        case .level1:
            return "저질 체력 향상을 위한 워밍업 모드"
        case .level2:
            return "지구력 향상을 위한 가벼운 모드"
        case .level3:
            return "심폐 지구력 향상, 체중 감량 모드"
        case .level4:
            return "신체 성능 향상을 위한 고강도 모드"
        case .level5:
            return "순간 스퍼트 필살기  초고강도 모드"
        }
    }
    var lowLevel : Double{
        switch self {
        case .level1:
            return 50
        case .level2:
            return 60
        case .level3:
            return 70
        case .level4:
            return 80
        case .level5:
            return 90
        }
    }
    var highLevel : Double{
        switch self {
        case .level1:
            return 60
        case .level2:
            return 70
        case .level3:
            return 80
        case .level4:
            return 90
        case .level5:
            return 100
        }
    }
}
enum HikeLevel:CaseIterable{
    case lowLevel,midLevel,highLevel
    var name:String{
        switch self {
        case .lowLevel:
            return "저강도"
        case .midLevel:
            return "중강도"
        case .highLevel:
            return "고강도"
        }
    }
    var detail:String{
        switch self {
        case .lowLevel:
            return "건강 유지 및 기초 체력 향상 모드"
        case .midLevel:
            return "심폐 지구력 향상 및 체력 유지 모드"
        case .highLevel:
            return "K2 정복도 꿈꾸는 등친놈 모드"
        }
    }
    var lowLevel : Double{
        switch self {
        case .lowLevel:
            return 50
        case .midLevel:
            return 60
        case .highLevel:
            return 70
        }
    }
    var highLevel : Double{
        switch self {
        case .lowLevel:
            return 60
        case .midLevel:
            return 70
        case .highLevel:
            return 80
        }
    }
}
enum MeditationLevel:CaseIterable{
    case normalLevel,hardLevel
    var name:String{
        switch self {
        case .normalLevel:
            return "일반인"
        case .hardLevel:
            return "운동 선수급"
        }
    }
    var detail:String{
        switch self {
        case .normalLevel:
            return "이미 아무 것도 안하고 있지만\n더 격하게 아무 것도 안하고 싶다"
        case .hardLevel:
            return "근손실 모드"
        }
    }
    var lowLevel : Double{
        switch self {
        case .normalLevel:
            return 33.52
        case .hardLevel:
            return 25.14
        }
    }
    var highLevel : Double{
        switch self {
        case .normalLevel:
            return 55.87
        case .hardLevel:
            return 33.51
        }
    }
}


