//
//  GradesVM.swift
//  iphoneapp
//
//  Created by mac on 11/7/24.
//

import SwiftUI
enum Grade{case Basic,Elite,Pause}

class GradesVM:ObservableObject{
    @Published var grade : Grade = .Basic
    @Published var subscribeType : SubscribeType = .month
}

enum SubscribeType:CaseIterable{
    case month,year
    
    var name : String{
        switch self {
        case .month:
            return "월"
        case .year:
            return "연"
        }
    }
    var salePrice : Int{
        switch self {
        case .month:
            return 2900
        case .year:
            return 29900
        }
    }
    var originPrice : Int{
        switch self {
        case .month:
            return 2900
        case .year:
            return 29900
        }
    }
    var discountRate : Int{
        switch self {
        case .month:
            return 51
        case .year:
            return 58
        }
    }
}
