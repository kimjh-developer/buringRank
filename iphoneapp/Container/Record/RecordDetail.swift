//
//  RecordDetail.swift
//  iphoneapp
//
//  Created by mac on 10/22/24.
//

import SwiftUI

struct RecordDetail: View {

    @State var selectDateType : DateType = .WEEK
    @State var selectSummaryType : SummaryType = .calories
    @State var isFreeMember : Bool = true
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                choosePeriods()
                
                chooseType()
            }
        }
    }
    // MARK: - 기간선택
    @ViewBuilder
    private func choosePeriods() -> some View{
        HStack(spacing: 0) {
            ForEach(DateType.allCases, id: \.self) { row in
                let color = selectDateType == row ? Color.black : Color.btnDisable
                Button {
                    if !isFreeMember{selectDateType = row}
                } label: {
                    ZStack {
                        Text(row.name)
                            .style(fontName: .player, fontSize: 15, fontColor: color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical,10)
                            .background {
                                ZStack {
                                    if selectDateType == row{
                                        CustomRoundedRectangle(topLeft: row == .WEEK ? 5 : 0, topRight: row == .PERIOD ? 5 : 0, bottomLeft: row == .WEEK ? 5 : 0, bottomRight: row == .PERIOD ? 5 : 0)
                                            .foregroundStyle(.white)
                                    }
                                    else{
                                        CustomRoundedRectangle(topLeft: row == .WEEK ? 5 : 0, topRight: row == .PERIOD ? 5 : 0, bottomLeft: row == .WEEK ? 5 : 0, bottomRight: row == .PERIOD ? 5 : 0)
                                            .stroke(.white, lineWidth: 1.0)
                                    }
                                }
                            }
                        
                        if isFreeMember && row != .WEEK{
                            Image("icon_lock")
                        }
                    }
                    
                }
            }
        }
    }
    
    // MARK: - 기간선택
    @ViewBuilder
    private func chooseType() -> some View{
        VStack {
            line()
            HStack(spacing: 0) {
                ForEach(SummaryType.allCases, id: \.self) { row in
                    
                    Button {
                        selectSummaryType = row
                    } label: {
                        ZStack(alignment:.bottom) {
                            Text(row.name)
                                .style(fontName: .kmedium, fontSize: 15, fontColor: .white)
                                .withUnderline(height: 5, color: row == selectSummaryType ?  Color.themeRed : Color.clear)
                        }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical,10)
                            
                    }
                }
            }
            line()
        }
        .padding(.vertical,10)
    }
    
    // MARK: - horizontalDivider
    @ViewBuilder
    private func line() -> some View{
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(Color.white)
    }
}

#Preview {
    RecordDetail()
}

enum DateType:String,CaseIterable{
   case WEEK,MONTH,YEAR,PERIOD
   var name:String{
       self.rawValue
   }
}
enum SummaryType:CaseIterable{
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
           return "이동거리"
       case .face:
           return "페이스"
       }
   }
}
