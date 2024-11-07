//
//  CalendarView.swift
//  tripCoach
//
//  Created by 김주형 on 2023/04/19.
//
import SwiftUI

import FSCalendar

//#Preview(body: {
//    RecordDetail()
//})
struct CalendarView: UIViewRepresentable {
    @Binding var choosedDatas : Array<Date>?
    @Binding var warnMSG : String?
    @Binding var warnActivate : Bool
    
    var selectedDate : Date?
    
    var firstDate: Date?
    var lastDate: Date?
    
    var minday : Int?
    var maxDay : Int?
    
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    private let calendar = FSCalendar()
    
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        setCalendarInit()
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.select(selectedDate)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func setCalendarInit(){
        calendar.scrollEnabled = true
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.scrollDirection = .vertical
        calendar.appearance.headerDateFormat = "YYYY년 MM월"
        calendar.appearance.headerTitleAlignment = .left
//        calendar.appearance.headerTitleFont = UIFont(name: "KBO Dia Gothic_medium", size: 14)
        calendar.appearance.headerTitleColor = UIColor(Color.black)
        calendar.appearance.headerSeparatorColor = .clear
        
        calendar.appearance.headerTitleOffset = CGPoint(x: 15, y: -7)
        calendar.appearance.titleTodayColor = .yellow
        calendar.appearance.todaySelectionColor = .lightGray.withAlphaComponent(0.8)
//        calendar.appearance.titleFont = UIFont(name: "KBO Dia Gothic_medium", size: 13)
        calendar.appearance.weekdayTextColor = UIColor(Color.black)
//        calendar.appearance.weekdayFont = UIFont(name: "KBO Dia Gothic_medium", size: 13)
        calendar.placeholderType = .none
        calendar.allowsMultipleSelection = true
        calendar.pagingEnabled = false
        calendar.register(CalendarCell.self, forCellReuseIdentifier: "cell")
    }
    
    class Coordinator: NSObject, FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance {
        var parent: CalendarView
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            updateUI(for: calendar, with: date)
        }
        
        func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
            if Calendar.current.isDateInToday(date){
                return  "오늘"
            }else{
                return " "
            }
        }
        
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//            if date.nextDate() ?? Date() < Date() {return false} // 오늘 기준 이전 날짜는 선택 불가능
            
            if !calendar.selectedDates.isEmpty{
                if calendar.selectedDates.count<2{
                    if let first = calendar.selectedDates.first{
                        if let maxDay = parent.maxDay{
                            if first.dayAfter(maxDay) ?? Date() < date{
                                parent.warnMSG = "최대 선택한 가능한 기간은 \(maxDay+1)(\(maxDay)박 \(maxDay+1)일)일입니다"
                                parent.warnActivate.toggle()
                                return false
                            }
                        }
                        
                        
                        if let minday = parent.minday{
                            if first.dayAfter(minday-2) ?? Date() >= date{
                                parent.warnMSG = "최소 선택한 가능한 기간은 \(minday)일입니다"
                                parent.warnActivate.toggle()
                                return false
                                
                                
                            }else{
                                parent.selectedDate = date
                            }
                        }
                    }
                    if let last = calendar.selectedDates.last{
                        if let maxDay = parent.maxDay{
                            if last.dayAfter(-maxDay) ?? Date() > date{
                                parent.warnMSG = "최대 선택한 가능한 기간은 \(maxDay+1)(\(maxDay)박 \(maxDay+1)일)일입니다"
                                parent.warnActivate.toggle()
                                return false
                            }
                        }
                    }
                }
                else{
                    parent.selectedDate = nil
                    
                    parent.selectedDate = date
                    
                    updateUI(for: calendar, with: date)
                }
                
            }
            

            
            return true
            //
        }
        
        func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            
//            if date < Date() {
//                return false // 오늘 기준 이전 날짜는 선택 불가능
//            }
            ClearCalendar(for: calendar)
            return true // 이외의 날짜는 선택 가능
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
            return UIColor.black
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleSelectionColorFor date: Date) -> UIColor? {
            return UIColor.clear
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleOffsetFor date: Date) -> CGPoint {
            
            return CGPoint(x: 0, y: 8)
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleOffsetFor date: Date) -> CGPoint {
            return CGPoint(x: 0, y: 8)
        }
        
        
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
            // 선택된 날짜가 시작 날짜와 종료 날짜 사이에 있는 경우 opacity를 50%로 변경합니다.
            if let selectedStartDate = parent.choosedDatas?.first, let selectedEndDate = parent.choosedDatas?.last {
                if date > selectedStartDate && date < selectedEndDate {
                    return UIColor(Color.blue).withAlphaComponent(0.5)
                }
            }
            // 나머지 경우에는 기본 fill color를 반환합니다.
            //            appearance.borderRadius = 100
            return UIColor(Color.calenderChooseBG)
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
//            if date.nextDate() ?? Date()<Date(){
//                return UIColor.gray.withAlphaComponent(0.5)
//            }
            let day = Calendar.current.component(.weekday, from: date) - 1
            if Calendar.current.shortWeekdaySymbols[day] == "Sun" || Calendar.current.shortWeekdaySymbols[day] == "일" {
                return .systemRed
            } else if Calendar.current.shortWeekdaySymbols[day] == "Sat" || Calendar.current.shortWeekdaySymbols[day] == "토" {
                return .systemRed
            } else if Calendar.current.isDateInToday(date){
                return UIColor(Color.black)
            }else {
                return .label
            }
            
            
        }
        
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
            return cell
        }
        
        private func ClearCalendar(for calendar: FSCalendar){
            parent.choosedDatas = nil
            calendar.selectedDates.forEach {
                calendar.deselect($0)
            }
            configureVisibleCells()
        }
        
        private func updateUI(for calendar: FSCalendar, with date: Date?) {
            guard let selectedDate = date else {
                calendar.select(nil)
                return
            }
            
            if calendar.selectedDates.count > 2 {
                ClearCalendar(for: calendar)
                return
            }
            calendar.select(selectedDate)
            
            let chooseArr = calendar.selectedDates.sorted { $0 < $1}
            
            if let startDate = chooseArr.first
                , let endDate = chooseArr.last {
                
                let currentCalendar = Calendar.current
                
                currentCalendar.enumerateDates(startingAfter: startDate, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { (date, _, stop) in
                    guard let date = date else {
                        return
                    }
                    
                    if date < endDate {
                        calendar.select(date)
                    } else {
                        stop = true
                    }
                }
                
                parent.choosedDatas = calendar.selectedDates.sorted{$0<$1}
                
                configureVisibleCells()
            }
        }
        
        func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
            
            configureVisibleCells()
            
            
        }
        
        
        
        
        private func configureVisibleCells() {
            parent.calendar.visibleCells().forEach { (cell) in
                let date = self.parent.calendar.date(for: cell)
                let position = self.parent.calendar.monthPosition(for: cell)
                initCell(cell,for: date,at:position)
            }
            DispatchQueue.main.async{
                self.parent.calendar.visibleCells().forEach { (cell) in
                    let date = self.parent.calendar.date(for: cell)
                    let position = self.parent.calendar.monthPosition(for: cell)
                    self.configureCell(cell, for: date, at: position)
                }
            }
        }
        
        func initCell(_ cell: FSCalendarCell?, for date: Date?, at position: FSCalendarMonthPosition){
            let diyCell = (cell as! CalendarCell)
            diyCell.selectionType = .none
            diyCell.selectionLayer?.isHidden = true
        }
        
        func configureCell(_ cell: FSCalendarCell?, for date: Date?, at position: FSCalendarMonthPosition) {
            let diyCell = (cell as! CalendarCell)
            if position == .current {
                var selectionType = SelectionType.none
                
                if parent.calendar.selectedDates.isEmpty{
                    diyCell.selectionType = .none
                    diyCell.selectionLayer?.isHidden = true
                    return
                }
                
                if parent.calendar.selectedDates.contains(date!) {
                    let previousDate = parent.gregorian.date(byAdding: .day, value: -1, to: date!)!
                    let nextDate = parent.gregorian.date(byAdding: .day, value: 1, to: date!)!
                    if parent.calendar.selectedDates.contains(date!) {
                        if parent.calendar.selectedDates.contains(previousDate) && parent.calendar.selectedDates.contains(nextDate) {
                            //                            diyCell.selectionLayer?.fillColor = UIColor.red.cgColor
                            selectionType = .middle
                            diyCell.titleLabel.textColor = .black
                        }
                        else if parent.calendar.selectedDates.contains(previousDate) && parent.calendar.selectedDates.contains(date!) {
                            selectionType = .rightBorder // .rightBorder
                            diyCell.titleLabel.textColor = .black
                        }
                        else if parent.calendar.selectedDates.contains(nextDate) {
                            selectionType = .leftBorder // .leftBorder
                            diyCell.titleLabel.textColor = .black
                        }
                        else {
                            if parent.calendar.selectedDates.count<2{
                                selectionType = .single //.single
                            }else{
                                selectionType = .middle //.single
                            }
                            
                        }
                    }
                }
                else {
                    selectionType = .none
                }
                if selectionType == .none {
                    diyCell.selectionLayer?.isHidden = true
                    return
                }
                diyCell.selectionLayer?.isHidden = false
                diyCell.selectionType = selectionType
            }else {
                diyCell.selectionType = .none
            }
        }
        
        
        
        
        
    }
}

enum SelectionType {
    case none
    case today
    case single
    case leftBorder
    case middle
    case rightBorder
}

class CalendarCell: FSCalendarCell {
    
    private weak var circleImageView: UIImageView?
    weak var selectionLayer: CAShapeLayer?
    private weak var roundedLayer: CAShapeLayer?
    private weak var todayLayer: CAShapeLayer?
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor(Color.calenderChooseBG).cgColor// UIColor.lightGray.cgColor.calenderChooseBG
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel?.layer)
        self.selectionLayer = selectionLayer
        
        let roundedLayer = CAShapeLayer()
        roundedLayer.fillColor = UIColor(Color.calenderChooseBG).cgColor//  Color.blue.cgColor! //UIColor.blue.cgColor
        roundedLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(roundedLayer, below: self.titleLabel?.layer)
        self.roundedLayer = roundedLayer
        
        let todayLayer = CAShapeLayer()
        todayLayer.fillColor = UIColor.clear.cgColor
        todayLayer.strokeColor = UIColor.orange.cgColor
        todayLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(todayLayer, below: self.titleLabel?.layer)
        self.todayLayer = todayLayer
        
        self.shapeLayer.isHidden = true
        let view = UIView(frame: self.bounds)
        self.backgroundView = view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.selectionLayer?.frame = self.contentView.bounds
        self.roundedLayer?.frame = self.contentView.bounds
        self.todayLayer?.frame = self.contentView.bounds
        
        let contentHeight = self.contentView.frame.height
        let contentWidth = self.contentView.frame.width
        
        let selectionLayerBounds = selectionLayer?.bounds ?? .zero
        let selectionLayerWidth = selectionLayer?.bounds.width ?? .zero
        let roundedLayerHeight = roundedLayer?.frame.height ?? .zero
        let roundedLayerWidth = roundedLayer?.frame.width ?? .zero
        
        switch selectionType {
        case .middle:
            self.selectionLayer?.isHidden = false
            self.roundedLayer?.isHidden = true
            self.todayLayer?.isHidden = true
            
            //            let selectionRect = selectionLayerBounds
            //                .insetBy(dx: 0.0, dy: 4.0)
            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rect = CGRect(x: 0,//contentWidth / 2 - diameter / 2,
                              y: contentHeight / 2 - diameter / 2,
                              width: roundedLayerWidth + diameter / 2,
                              height: diameter)
                .insetBy(dx: 0, dy: 2.5)
            self.selectionLayer?.path = UIBezierPath(rect: rect).cgPath
            
        case .leftBorder:
            self.selectionLayer?.isHidden = false
            self.roundedLayer?.isHidden = false
            self.todayLayer?.isHidden = true
            
            //            let selectionRect = selectionLayerBounds
            //                .insetBy(dx: selectionLayerWidth / 4, dy: 4)
            //                .offsetBy(dx: selectionLayerWidth / 4, dy: 0.0)
            //            self.selectionLayer?.path = UIBezierPath(rect: selectionRect).cgPath
            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rects = CGRect(x: contentWidth / 2 - diameter / 2 - 10,
                               y: contentHeight / 2 - diameter / 2,
                               width: selectionLayerBounds.width,
                               height: diameter)
                .insetBy(dx: diameter/4, dy: 2.5)
                .offsetBy(dx: selectionLayerWidth / 3, dy: 0.0)
            self.selectionLayer?.path = UIBezierPath(rect: rects).cgPath
            
            //            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rect = CGRect(x: contentWidth / 2 - diameter / 2,
                              y: contentHeight / 2 - diameter / 2,
                              width: diameter,
                              height: diameter)
                .insetBy(dx: 2.5, dy: 2.5)
            self.roundedLayer?.path = UIBezierPath(ovalIn: rect).cgPath
            
        case .rightBorder:
            self.selectionLayer?.isHidden = false
            self.roundedLayer?.isHidden = false
            self.todayLayer?.isHidden = true
            
            //            let selectionRect = selectionLayerBounds
            //                .insetBy(dx: selectionLayerWidth / 4, dy: 4)
            //                .offsetBy(dx: -selectionLayerWidth / 4, dy: 0.0)
            //            self.selectionLayer?.path = UIBezierPath(rect: selectionRect).cgPath
            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rects = CGRect(x: contentWidth / 2 - diameter / 2,
                               y: contentHeight / 2 - diameter / 2,
                               width: diameter,
                               height: diameter)
                .insetBy(dx: diameter/4, dy: 2.5)
                .offsetBy(dx: -selectionLayerWidth / 4, dy: 0.0)
            self.selectionLayer?.path = UIBezierPath(rect: rects).cgPath
            
            
            let rect = CGRect(x: contentWidth / 2 - diameter / 2,
                              y: contentHeight / 2 - diameter / 2,
                              width: diameter,
                              height: diameter)
                .insetBy(dx: 2.5, dy: 2.5)
            self.roundedLayer?.path = UIBezierPath(ovalIn: rect).cgPath
            
        case .single:
            self.selectionLayer?.isHidden = true
            self.roundedLayer?.isHidden = false
            self.todayLayer?.isHidden = true
            
            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rect = CGRect(x: contentWidth / 2 - diameter / 2,
                              y: contentHeight / 2 - diameter / 2,
                              width: diameter,
                              height: diameter)
                .insetBy(dx: 2.5, dy: 2.5)
            self.roundedLayer?.path = UIBezierPath(ovalIn: rect).cgPath
            
        case .today:
            self.selectionLayer?.isHidden = true
            self.roundedLayer?.isHidden = true
            self.todayLayer?.isHidden = false
            
            let diameter: CGFloat = min(roundedLayerHeight, roundedLayerWidth)
            let rect = CGRect(x: contentWidth / 2 - diameter / 2,
                              y: contentHeight / 2 - diameter / 2,
                              width: diameter,
                              height: diameter)
                .insetBy(dx: 2.5, dy: 2.5)
            self.todayLayer?.path = UIBezierPath(ovalIn: rect).cgPath
            
        case .none:
            self.selectionLayer?.isHidden = true
            self.roundedLayer?.isHidden = true
            self.todayLayer?.isHidden = true
        }
    }
}

