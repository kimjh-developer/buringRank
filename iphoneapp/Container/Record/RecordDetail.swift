//
//  RecordDetail.swift
//  iphoneapp
//
//  Created by mac on 10/22/24.
//

import SwiftUI
import Charts
struct Data {
    let name: String = "jake"
    let date: Date
    let value: Int
}
struct RecordDetail: View {
    @StateObject var vm = RecordDetailVM()
    @EnvironmentObject var workoutManager : WorkoutManager
    private let months = Array(1...12) // 1월부터 12월까지
    private let years = Array(2000...2100) // 2000년부터 2100년까지 선택 가능
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                choosePeriods()
                
                chooseType()
                ScrollView {
                    theChart()
                    
                    summaryProgressBar()
                }
            }
            .padding()
            if vm.datePopupActivate{
                datePopups()
            }
            if isLoading{
                ProgressView("데이터 로딩중....")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5) // ProgressView 크기 조정
                    .padding()
            }
            
        }
        .onAppear {
            isLoading = true
            workoutManager.analyzeHeartRateZonesForTimePeriod(for: .weekly) {
                workoutManager.updateSummary(for: .heartRate, timePeriod: .weekly) {
                    workoutManager.updateMaxHeartRates(for: vm.timePeriod) {
                        print("이번 주 최고 심박수: \(workoutManager.ThismaxHeartRate ?? 0) BPM")
                        self.isLoading = false
                    }
                }
            }
        }
        
    }
    
    // MARK: - 요약
    @ViewBuilder
    private func summaryProgressBar() -> some View{
        VStack(alignment: .leading,spacing: 18) {
            if vm.selectSummaryType == .heartRate{
                summaryRow(item: SummaryRow(summaryType: .heartRate, stack: nil, best: SummaryRowElement(Str: "이번주 최고", Updown: Int(workoutManager.ThismaxHeartRate ?? 0 - (workoutManager.LastmaxHeartRate ?? 0)), Value: workoutManager.ThismaxHeartRate)))
                summaryRow(item: SummaryRow(summaryType: .heartRate, stack: nil, best: SummaryRowElement(Str: "지난주 최고", Value: workoutManager.LastmaxHeartRate)))
            }else{
                if let array = workoutManager.summaryArray{
                ForEach(array.indices, id: \.self) { i in
                        if i>0{
                            line()
                        }
                        summaryRow(item: array[i])
                    }
                }
            }
            
            line()
            
            if vm.selectSummaryType == .heartRate{
                Text("· 심박수 비중")
                    .style(fontName: .kmedium, fontSize: 20, fontColor: .white)
                VStack (spacing: 15){
                    ForEach(workoutManager.workoutProgressArray, id: \.self) { row in
                        progressCell(item: row)
                    }
                }
            }
            
            if vm.selectSummaryType == .distance && vm.timePeriod == .weekly{
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
                        .frame(maxWidth: .infinity,alignment: .center)
                        
                    }
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
                
                Text("13"+"%")
                    .style(fontName: .player, fontSize: 14, fontColor: item.progressLevel.color)
                    .padding(.leading,10)
            }
        }
    }
    
    // MARK: - 요약 row
    @ViewBuilder
    private func summaryRow(item : SummaryRow) -> some View{
        VStack(spacing:15){
            if let stack = item.stack{
                var fontColor: Color {
                    if let stackValue = stack.Value, let bestValue = item.best?.Value {
                        return stackValue > bestValue ? Color.themeRed : Color.blue
                    }
                    return .white
                }
                    cellDetail(element: stack, measure: item.summaryType, fontColor: fontColor)
                }
            
            if let best = item.best{
                cellDetail(element: best, measure: item.summaryType, fontColor: .white)
            }
        }
    }
    
    // MARK: - 셀 뷰
    @ViewBuilder
    private func cellDetail(element : SummaryRowElement,measure : SummaryType?,fontColor : Color) -> some View{
        
        if let str = element.Str{
            HStack (alignment:.bottom){
                Text("· \(str)")
                    .style(fontName: .kmedium, fontSize: 20, fontColor: .white)
                Spacer()
                HStack(spacing: 0) {
                    if let value = element.Value{
                        let ival = Int(value)
                        HStack(spacing: 4) {
                            Text(ival.addComma())
                                .style(fontName: .player, fontSize: 20, fontColor: fontColor)
                            
                            Text(vm.selectSummaryType.element.measure ?? "")
                                    .style(fontName: .player, fontSize: 20, fontColor: .white)
                            
                        }
                    }
                }
            }
        }
        
    }
    
    // MARK: - 차트
    @ViewBuilder
    private func theChart() -> some View{
        
        VStack {
            Button {
                vm.datePopupActivate.toggle()
            } label: {
                if vm.timePeriod == .custom(startDate: nil, endDate: nil){
                    if let choosedDatas = vm.choosedDatas{
                        if choosedDatas.count>1{
                            Text("\(choosedDatas.first!.toString())~\(choosedDatas.first!.toString(format: "MM월 dd일"))")
                            .style(fontName: .kmedium, fontSize: 18, fontColor: .white)
                        }else{
                            Text(choosedDatas.first!.toString())
                            .style(fontName: .kmedium, fontSize: 18, fontColor: .white)
                        }
                        
                    }else{
                        Text("선택하세요")
                        .style(fontName: .kmedium, fontSize: 18, fontColor: .white)
                    }
                }else{
                    Text(vm.timePeriod.formattedDateText(for: vm.chooseDate.first ?? Date()))
                        .style(fontName: .kmedium, fontSize: 18, fontColor: .white)
                }
            }
            ZStack {
                GeometryReader { proxy in
                    Color.clear
                    Chart(vm.data, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(.red)
                        .symbol {
                            Circle() // 심볼로 원 사용
                                .strokeBorder(.white, lineWidth: 1.5) // 외곽선 빨간색
                                .background(Circle().foregroundColor(Color.themeRed)) // 내부 흰색
                                .frame(width: 8)
                        }
                        .offset(x: proxy.size.width / CGFloat(vm.data.count * 2))
                    }
                    .chartXScale(domain: vm.data.first!.date...Calendar.current.date(byAdding: .day, value: 1, to: vm.data.last!.date)!)
                    .chartXAxis {
                        AxisMarks(values: strideDates(data: vm.data)) { value in
                            if let date = value.as(Date.self) {
                                AxisGridLine().foregroundStyle(.white) // 세로선 흰색 설정
                                AxisValueLabel(centered:true) {
                                    Text(date, formatter: DateFormatter.koreanMonthDay) // 한글 형식 날짜 표시
                                        .style(fontName: .player, fontSize: 12, fontColor: .white)
                                }
                            }
                        }
                    }
                    .chartYAxis{
                        AxisMarks { value in
                            AxisGridLine(stroke: .init(lineWidth: 1.0, dash: [2.0])) // 가로선 표시
                                .foregroundStyle(.white)
                            
                        }
                    }
                }
                
            }
            .frame(height: 140)
            .padding(.vertical)
            HStack {
                Spacer()
                Image("icon_chartNode")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16)
                Text("최고 심박수")
                    .style(fontName: .kmedium, fontSize: 9, fontColor: .white)
            }
        }
        
    }
    // MARK: - Helper Function: 포인트 사이 날짜 계산
    private func strideDates(data: [DValue]) -> [Date] {
        guard data.count > 1 else { return data.map { $0.date } }
        var result: [Date] = []
        // 날짜와 값을 로컬 시간대에 맞게 출력
          let formatter = DateFormatter()
            formatter.dateFormat = "M/d" // 한글 형식으로 월/일 표시
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC로 설정
            formatter.locale = Locale.current
        
        for index in 0..<data.count {
            result.append(data[index].date)
        }
        if let nextDay = data.last?.date.nextDate(){
            result.append(nextDay)
        }
        
        return result
    }
    
    // MARK: - 기간선택
    @ViewBuilder
    private func choosePeriods() -> some View {
        HStack(spacing: 0) {
            ForEach(TimePeriod.allCases, id: \.self) { row in
                let color = vm.timePeriod.isSameCase(as: row) ? Color.black : Color.btnDisable

                Button {
                    if !vm.isFreeMember {
                        self.isLoading = true
                        vm.timePeriod = row
                        
                        calculateDatas()
                    }
                } label: {
                    ZStack {
                        Text(row.measure) // measure 속성 사용
                            .style(fontName: .player, fontSize: 15, fontColor: color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background {
                                ZStack {
                                    if vm.timePeriod.isSameCase(as: row) {
                                        CustomRoundedRectangle(
                                            topLeft: row == .weekly ? 5 : 0,
                                            topRight: row == .custom(startDate: nil, endDate: nil) ? 5 : 0,
                                            bottomLeft: row == .weekly ? 5 : 0,
                                            bottomRight: row == .custom(startDate: nil, endDate: nil) ? 5 : 0
                                        )
                                        .foregroundStyle(.white)
                                    } else {
                                        CustomRoundedRectangle(
                                            topLeft: row == .weekly ? 5 : 0,
                                            topRight: row == .custom(startDate: nil, endDate: nil) ? 5 : 0,
                                            bottomLeft: row == .weekly ? 5 : 0,
                                            bottomRight: row == .custom(startDate: nil, endDate: nil) ? 5 : 0
                                        )
                                        .stroke(.white, lineWidth: 1.0)
                                    }
                                }
                            }
                        
                        if vm.isFreeMember && row != .weekly {
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
                    Button(action: {
                        vm.selectSummaryType = row
                        calculateDatas()
                    }) {
                        ZStack(alignment: .bottom) {
                            Text(row.element.title)
                                .style(fontName: .kmedium, fontSize: 15, fontColor: .white)
                                .withUnderline(height: 5, color: row == vm.selectSummaryType ? Color.themeRed : Color.clear)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
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
    
    // MARK: - 기간팝업
    @ViewBuilder
    private func datePopups() -> some View {
        ZStack {
            GeometryReader { proxy in
                Color.black.opacity(0.5)
                    .onTapGesture {
                        vm.datePopupActivate = false
                    }

                VStack {
                    Spacer()

                    VStack {
                        switch vm.timePeriod {
                        case .weekly:
                            EmptyView()
                        case .monthly:
                            VStack {
                                Text("월 선택")
                                    .style(fontName: .kmedium, fontSize: 25, fontColor: .black)
                                HStack {
                                    Spacer()
                                    Picker("월", selection: $vm.selectedMonth) {
                                        ForEach(months, id: \.self) { month in
                                            Text("\(month)월")
                                                .tag(month)
                                                .style(fontName: .kmedium, fontSize: 20, fontColor: .black)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                    .frame(width: 150)
                                    .clipped()
                                    Spacer()
                                    Picker("연도", selection: $vm.selectedYear) {
                                        ForEach(years, id: \.self) { year in
                                            Text("\(String(year))년")
                                                .tag(year)
                                                .style(fontName: .kmedium, fontSize: 20, fontColor: .black)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                    .frame(width: 150)
                                    .clipped()
                                    Spacer()
                                }
                            }
                            .padding(.vertical)
                        case .yearly:
                            VStack {
                                Text("년 선택")
                                    .style(fontName: .kmedium, fontSize: 25, fontColor: .black)
                                HStack {
                                    Spacer()
                                    Picker("연도", selection: $vm.selectedYear) {
                                        ForEach(years, id: \.self) { year in
                                            Text("\(String(year))년")
                                                .tag(year)
                                                .style(fontName: .kmedium, fontSize: 20, fontColor: .black)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                    .frame(width: 150)
                                    .clipped()
                                    Spacer()
                                }
                            }
                            .padding(.vertical)
                        case .custom(let startDate, let endDate):
                            VStack {
                                Text("기간 선택")
                                    .style(fontName: .kmedium, fontSize: 25, fontColor: .black)
                                CalendarView(choosedDatas: $vm.choosedDatas, warnMSG: $vm.warnMSG, warnActivate: $vm.warnActivate)
                            }
                            .padding(.vertical)
                        }

                        let buttonText = vm.timePeriod == .custom(startDate: nil, endDate: nil) && vm.choosedDatas != nil
                            ? (vm.choosedDatas!.count < 2
                                ? vm.choosedDatas!.first!.toString()
                                : "\(vm.choosedDatas!.first!.toString())~\(vm.choosedDatas!.last!.toString(format: "MM월 dd일"))")
                            : "선택완료"
                        Button {
                            if let firstD = vm.choosedDatas?.first,
                               let lastD = vm.choosedDatas?.last{
                                vm.timePeriod = .custom(startDate: firstD, endDate: lastD)
                                calculateDatas()
                                vm.datePopupActivate = false
                            }
                        } label: {
                            Btn(defaultString: buttonText, fontsize: 20, fontcolor: .white, defaultColor: .black)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }

                        
                    }
                    .padding()
                    .frame(height: vm.timePeriod == .custom(startDate: nil, endDate: nil) ? proxy.size.height * 0.7 : proxy.size.height * 0.35)
                    .frame(maxWidth: .infinity)
                    .background {
                        CustomRoundedRectangle(topLeft: 20, topRight: 20, bottomLeft: 0, bottomRight: 0)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func calculateDatas(){
        isLoading = true
        if vm.timePeriod == .custom(startDate: nil, endDate: nil){
            workoutManager.resetDatas()
            self.isLoading = false
        }else{
            workoutManager.analyzeHeartRateZonesForTimePeriod(for: vm.timePeriod) {
                workoutManager.updateSummary(for: .heartRate, timePeriod: vm.timePeriod) {
                    workoutManager.updateMaxHeartRates(for: vm.timePeriod) {
                        self.isLoading = false
                    }
                }
            }
        }
    }

}

#Preview {
    RecordDetail()
}



