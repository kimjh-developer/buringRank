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
    @StateObject var vm = RecordVM()
    var body: some View {
        ScrollView {
            VStack(spacing:20) {
                // MARK: - weekCELL barco 1022
                HStack {
                    ForEach(weeks.indices, id: \.self) { i in
                        Button {
                            if vm.workoutDay.contains(i){
                                vm.selectDay =  i
                            }
                        } label: {
                            weekCell(item: weeks[i],
                                     activate: vm.workoutDay.contains(i),
                                     isToday: weeks[i] == thisDay,
                                     selected: vm.selectDay == i
                            )
                        }
                        .disabled(!vm.workoutDay.contains(i))
                    }
                }
                
                line()
                
                
                // MARK: - 디테일페이지 barco 1023
                HStack {
                    if vm.selectDay != nil{
                        Button{
                            vm.selectDay = nil
                        }label : {
                            Text("<  이번 주 데이터")
                                .style(fontName: .kmedium, fontSize: 18, fontColor: .themeRed)
                        }
                    }
                    Spacer()
                    
                    NavigationLink {
                        Text("detail")
                    } label: {
                        Text("상세 데이터  >")
                            .style(fontName: .kmedium, fontSize: 18, fontColor: .themeRed)
                    }
                }
                
                
                summaryProgressBar()
                
                summarys()
            }
        }
        .padding()
    }
    
    // MARK: - 요약디테일
    @ViewBuilder
    private func summarys() -> some View{
        ForEach(vm.SummaryArray, id: \.self) { row in
            VStack {
                summaryCell(item: row)
                if row.summaryCommon == .distance{
                    Button {
                        vm.isFreeMember.toggle()
                    } label: {
                        HStack {
                            ZStack {
                                Text("이동 경로 보기")
                                    .style(fontName: .kmedium, fontSize: 20, fontColor: vm.isFreeMember ? Color.btnDisable : .black)
                                    .padding(.horizontal)
                                    .padding(.vertical,10)
                                    .background {
                                        if vm.isFreeMember{
                                            RoundedRectangle(cornerRadius: 50)
                                                .stroke(.white, lineWidth: 2)
                                        }else{
                                            RoundedRectangle(cornerRadius: 50)
                                                .foregroundStyle(.white)
                                        }
                                    }
                                
                                if vm.isFreeMember{
                                    Image("icon_lock")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 17)
                                }
                            }
                            .padding(.vertical)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    // MARK: - 요약셀
    @ViewBuilder
    private func summaryCell(item:SummaryRow) -> some View{
        VStack {
            line()
                .padding(.vertical)
            VStack(spacing:15){
                Text(item.summaryCommon.element.title)
                    .style(fontName: .kbold, fontSize: 25, fontColor: .white)
                    .frame(maxWidth: .infinity,alignment: .leading)
                
                HStack (alignment:.bottom){
                    Text("· \(vm.selectDay==nil ? item.stackStr : "오늘 누적")")
                        .style(fontName: .kmedium, fontSize: 20, fontColor: .white)
                    Spacer()
                    HStack(spacing: 0) {
                        if let stackUpdown = item.stackUpdown{
                            let color = stackUpdown>0 ? Color.themeRed : .blue
                            Text(abs(stackUpdown).addComma())
                                .style(fontName: .player, fontSize: 12, fontColor: color)
                            Image(systemName: stackUpdown>0 ? "arrowtriangle.up.fill" :"arrowtriangle.down.fill")
                                .renderingMode(.template)
                                .font(.system(size: 12))
                                .foregroundStyle(color)
                        }
                        if let stackValue = item.stackValue{
                            HStack(spacing: 4) {
                                Text(stackValue)
                                    .style(fontName: .player, fontSize: 20, fontColor: .white)
                                if let measure = item.summaryCommon.element.measure{
                                    Text(measure)
                                        .style(fontName: .player, fontSize: 20, fontColor: .white)
                                }
                            }
                        }
                    }
                }
                if let bestStr = item.bestStr{
                    HStack {
                        Text("· \(vm.selectDay==nil ? bestStr : "오늘 최고")")
//                        Text("· \(bestStr)")
                            .style(fontName: .kmedium, fontSize: 20, fontColor: .white)
                        Spacer()
                        HStack(alignment:.bottom,spacing: 0) {
                            if let bestUpdown = item.bestUpdown{
                                let color = bestUpdown>0 ? Color.themeRed : .blue
                                Text(abs(bestUpdown).addComma())
                                    .style(fontName: .player, fontSize: 12, fontColor: color)
                                Image(systemName: bestUpdown>0 ? "arrowtriangle.up.fill" :"arrowtriangle.down.fill")
                                    .renderingMode(.template)
                                    .font(.system(size: 12))
                                    .foregroundStyle(color)
                            }
                            if let bestValue = item.bestValue{
                                HStack(spacing: 4) {
                                    Text(bestValue)
                                        .style(fontName: .player, fontSize: 20, fontColor: .white)
                                    if let measure = item.summaryCommon.element.measure{
                                        Text(measure)
                                            .style(fontName: .player, fontSize: 20, fontColor: .white)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    
    // MARK: - horizontalDivider
    @ViewBuilder
    private func line() -> some View{
        Rectangle()
            .frame(height: 2)
            .foregroundStyle(Color.white)
    }
    // MARK: - 요약
    @ViewBuilder
    private func summaryProgressBar() -> some View{
        VStack(alignment: .leading,spacing: 18) {
            Text("심박수")
                .style(fontName: .kbold, fontSize: 25, fontColor: .white)
            HStack(alignment:.bottom) {
                Text("· \(vm.selectDay == nil ? "이번추 최고" : "오늘 최고")")
                    .style(fontName: .kmedium, fontSize: 20, fontColor: .white)
                Spacer()
                if let updownValue = vm.updownValue{
                    HStack(spacing: 0) {
                        let color = updownValue>0 ? Color.themeRed : .blue
                        Text(abs(updownValue).addComma())
                            .style(fontName: .player, fontSize: 12, fontColor: color)
                        Image(systemName: updownValue>0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            .renderingMode(.template)
                            .foregroundStyle(color)
                            .font(.system(size: 12))
                    }
                }
                Text("\(vm.hearRate?.addComma() ?? "-") BPM")
                    .style(fontName: .player, fontSize: 20, fontColor: .white)
                    .onAppear {
                        vm.hearRate = 120
                        vm.updownValue = -20
                    }
            }
            
            Text("· 심박수 비중")
                .style(fontName: .kmedium, fontSize: 20, fontColor: .white)
            VStack (spacing: 15){
                ForEach(vm.workoutProgressArray, id: \.self) { row in
                    progressCell(item: row)
                }
                
            }
        }
        .frame(maxWidth: .infinity,alignment: .leading)
    }
    // MARK: - 프로그레스셀
    @ViewBuilder
    private func progressCell(item:WorkoutProgress) -> some View{
        GeometryReader { proxy in
            HStack {
                Text(item.progressLevel.name)
                    .style(fontName: .klight, fontSize: 12, fontColor: .white)
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.white)
                    HStack {
                        CustomRoundedRectangle(topLeft: 5, topRight: 10, bottomLeft: 5, bottomRight: 10)
                            .fill(item.progressLevel.color)
                            .frame(width: proxy.size.width * (item.percentage / 100))
                        Spacer()
                    }
                }
                .frame(height: 17)
            }
        }
        
        
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
