//
//  TimerCountVM.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/12/24.
//

import Foundation
import SwiftUI
class TimerCountVM:ObservableObject{
    @Published var colorIndex = 0
    @Published var progress: CGFloat = 0.0
    @Published var number : Int = 3
    var timer: Timer?
    @Published var moveNext = false
    // 타이머 시작 함수
    func startTimer() {
        // 기존 타이머가 있으면 종료
        timer?.invalidate()
        
        // 새로운 타이머 시작
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 애니메이션을 적용하며 progress 업데이트
            withAnimation(.linear(duration: 0.9)) {
                self.progress = 1.0
                self.colorIndex = 1 // 녹색으로 변경
            }
            
            // 1초 후에 progress 및 colorIndex 초기화
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                if self.number>1{
                    self.number-=1
                }else{
//                    self.number = 3
                    self.timer?.invalidate()
                    self.moveNext.toggle()
                }
                withAnimation(.linear(duration: 0.0)) {
                    self.progress = 0.0
                    self.colorIndex = 0 // 흰색으로 변경
                }
            }
        }
    }
    
    // 타이머 종료 함수
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
