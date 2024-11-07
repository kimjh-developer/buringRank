//
//  TimerCount.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/12/24.
//

import SwiftUI
import HealthKit

struct TimerCount: View {
    @Binding var Gohome : Bool
    @StateObject var vm = TimerCountVM()
    var body: some View {
        GeometryReader { geometry in
            ZStack(content: {
                Circle()
                    .trim(from: 0, to: vm.progress) // progress에 따라 원이 채워짐
                    .stroke(vm.colorIndex == 1 ? Color.green : Color.white, lineWidth: 15) // 색상 변경
                    .rotationEffect(.degrees(-90)) // 시계 방향으로 애니메이션
                    .frame(width: geometry.size.width)
                    .onAppear {
                        vm.startTimer()
                    }
                
                Text("\(vm.number)")
                    .style(fontName: .player, fontSize: geometry.size.width/2, fontColor: .white)
            })
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $vm.moveNext) {
            MatrixView(Gohome: $Gohome)
        }
    }
}

#Preview {
    TimerCount(Gohome: .constant(true))
}
