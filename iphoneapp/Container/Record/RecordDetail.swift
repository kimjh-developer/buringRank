//
//  RecordDetail.swift
//  iphoneapp
//
//  Created by mac on 10/22/24.
//

import SwiftUI

struct RecordDetail: View {
    private enum DateType:CaseIterable{
        case WEEK,MONTH,YEAR,PERIOD
    }
    private enum SummaryType:CaseIterable{
        case heatRate,calories,workCount,distance,face
        var name : String{
            switch self {
            case .heatRate:
                return "심박수"
            case .calories:
                return "칼로리"
            case .workCount:
                return "걸음수"
            case .distance:
                return "거리"
            case .face:
                return "페이스"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                <#code#>
            }
            
        }
    }
}

#Preview {
    RecordDetail()
}
