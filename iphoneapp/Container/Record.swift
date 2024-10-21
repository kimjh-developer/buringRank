//
//  Record.swift
//  iphoneapp
//
//  Created by mac on 10/20/24.
//

import SwiftUI

struct Record: View {
    
    private let weeks = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    private let thisDay = Date().dayOfWeek(locale: Locale(identifier: "en_US")).uppercased()
    @State var selectWeek = [0,2,3]
    @State var selectDay : Int?
    var body: some View {
        VStack(spacing:0) {
            // MARK: - weekCELL barco 1022
            HStack {
                ForEach(weeks.indices, id: \.self) { i in
                    Button {
                        if selectWeek.contains(i){selectDay = i}
                    } label: {
                        weekCell(item: weeks[i],
                                 activate: selectWeek.contains(i),
                                 isToday: weeks[i] == thisDay,
                                 selected: selectDay == i
                        )
                    }
                    .disabled(!selectWeek.contains(i))
                }
            }
            
            
            Rectangle()
                .frame(height: 2)
                .foregroundStyle(Color.white)
                .padding(.vertical)
            
            
        }
        .padding()
    }
    
    // MARK: - cell
    @ViewBuilder
    private func weekCell(item : String,activate:Bool,isToday:Bool = false,selected:Bool = false) -> some View{
        VStack {
            Text(item)
                .style(fontName: .player, fontSize: 15, fontColor: .white)
            Image(activate ? "logoColor" : "logoJustWhite")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 33)
                .padding(.vertical,2)
            ZStack(alignment: .bottom) {
                if selected{
                    Rectangle()
                        .foregroundStyle(Color.themeRed)
                        .frame(height: 4)
                }
                
                Text(isToday ? "TODAY" : " ")
                        .style(fontName: .player, fontSize: 10, fontColor: .white)
            }
            
            
        }
        .frame(maxWidth: .infinity)
    }
        
}

#Preview {
    Container()
        .environmentObject(WorkoutManager())
}
