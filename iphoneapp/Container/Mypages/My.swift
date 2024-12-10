//
//  My.swift
//  iphoneapp
//
//  Created by mac on 10/20/24.
//

import SwiftUI

struct My: View {
    @StateObject var vm = MyVM()
    
    @EnvironmentObject var workoutManager : WorkoutManager
    let timePeriod = TimePeriod.custom(startDate: Date(), endDate: Date())
    @Binding var backToSplash : Bool
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                HStack {
                    VStack(spacing: 5) {
                        Text("랭커님의 최고 기록")
                            .style(fontName: .kbold, fontSize: 25, fontColor: .black)
                            
                        HStack(spacing: 0) {
                            Text("지피지기")
                                .style(fontName: .klight, fontSize: 15, fontColor: .black)
                            Text("BURNING")
                                .style(fontName: .klight, fontSize: 15, fontColor: .themeRed)
                            Text("RANKUP")
                                .style(fontName: .klight, fontSize: 15, fontColor: .black)
                        }
                        
                    }
                    Spacer()
                    NavigationLink {
                        Setting(backToSplash: $backToSplash)
                    } label: {
                        Image("SettingIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                }
                .padding(.horizontal)
                ScrollView {
                    VStack {
                        ZStack {
                            Image("summaryBack")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                            VStack(spacing: 20) {
                                summaryRow(info: MysummaryInfo(title: "운동 시간", value: vm.workoutTime ?? ""))
                                if let row = vm.SummaryArray.first(where: { $0.summaryType == .heartRate }) {
                                    summaryRow(info: MysummaryInfo(title: "심박수", value: "\(Int(row.best?.Value ?? 0))",  measure: "BPM"))
                                }
                                if let row = vm.SummaryArray.first(where: { $0.summaryType == .distance }) {
                                    summaryRow(info: MysummaryInfo(title: "이동 거리", value: "\(Int(row.best?.Value ?? 0))",measure: "KM"))
                                }
                                if let row = vm.SummaryArray.first(where: { $0.summaryType == .calorie }) {
                                    summaryRow(info: MysummaryInfo(title: "소모 칼로리", value: "\(Int(row.stack?.Value ?? 0))",measure: "KCAL"))
                                }
                                
                            }
                            .padding()
                        }
                        
//                        NavigationLink {
//                            Text("기본 정보 수정")
//                        } label: {
//                            navigationRow(title: "기본 정보 수정")
//                        }
                        
//                        NavigationLink {
//                            measurement()
//                        } label: {
//                            navigationRow(title: "측정 기준 설정")
//                        }
                        
                        NavigationLink {
                            Grades()
                        } label: {
                            navigationRow(title: "Elite모드 구독",iconActivate: true)
                        }
                        
                        NavigationLink {
                            CSCenter()
                        } label: {
                            navigationRow(title: "고객센터")
                        }

                    }
                }
                .onAppear(perform: {
                    vm.getTodayData()
                })
                NavigationLink {
                    Grades()
                } label: {
                    Image("banner")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
        }
        
    }
    
    // MARK: - 로우
    @ViewBuilder
    private func summaryRow(info:MysummaryInfo) -> some View{
        HStack(alignment: .bottom) {
            Text(info.title)
                .style(fontName: .kmedium, fontSize: 23, fontColor: .white)
            Spacer()
            if let value = info.updownValue{
                if value != 0{
                    HStack(spacing: 0) {
                        Text("\(abs(value))")
                            .style(fontName: .player, fontSize: 15, fontColor: value > 0 ? .themeRed : .blue)
                        Image(systemName: "triangleshape.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(value>0 ? .themeRed : .blue)
                            .rotationEffect(Angle(degrees: value>0 ? 0 : 180))
                    }
                }
            }
            Text(info.value)
                .style(fontName: .player, fontSize: 25, fontColor: .white)
            if let value = info.measure{
                Text(value)
                    .style(fontName: .player, fontSize: 25, fontColor: .white)
            }
        }
    }
    
    // MARK: - 네비게이션 로우
    @ViewBuilder
    private func navigationRow(title:String,iconActivate : Bool = false) -> some View{
        HStack(spacing:5) {
            Text(title)
                .style(fontName: .klight, fontSize: 16, fontColor: .black)
            if iconActivate{
                Image("saleIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
        }
            .frame(maxWidth: .infinity,alignment: .leading)
            .padding()
    }
    
    private func calculateDatas(){
        
//        workoutManager.analyzeHeartRateZonesForTimePeriod(for: timePeriod) {
//            workoutManager.updateSummary(for: .heartRate, timePeriod: timePeriod) {
//                    workoutManager.updateMaxHeartRates(for: timePeriod) {
//                        print("done")
//                    }
//                }
//            }
        
    }
}

#Preview {
    My(backToSplash: .constant(false))
}
struct MysummaryInfo{
    var title : String
    var value : String
    var updownValue : Int?
    var measure : String?
}
