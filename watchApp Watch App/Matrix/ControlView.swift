//
//  ControlView.swift
//  burningRankWatch Watch App
//
//  Created by mac on 10/14/24.
//

import SwiftUI

struct ControlView: View {
    @Binding var Gohome : Bool
    @State var nowSaving:Bool = false
    @EnvironmentObject var workoutManager : WorkoutManager
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    Image(systemName: "xmark")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.red)
                        .frame(height: 32)
                        .padding()
                        .padding(.vertical)
                    Btn(defaultString: "운동종료",fontsize: 20,fontcolor: .white, defaultColor: Color.btnActivate)
                }
                .onTapGesture {
                    nowSaving.toggle()
                    workoutManager.endWorkout()
                    
                }
                
                
                VStack {
                    Image(systemName: workoutManager.running ? "pause" : "play")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle( workoutManager.running ? Color.btnDisable : Color.btnActivate)
                        .frame(height: 32)
                        .padding()
                        .padding(.vertical)
                    Btn(defaultString: workoutManager.running ? "일시정지" : "계속운동",fontsize: 20,fontcolor: .black, defaultColor: .white)
                }
                .onTapGesture {
                    workoutManager.togglePause()
                }
            }
            
            if nowSaving{
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView {
                    Text("운동을 저장합니다")
                        .style(fontName: .player, fontSize: 25, fontColor: .white)
                }
                
            }
        }
        .onChange(of: workoutManager.showingSummaryView) { oldValue, newValue in
            if newValue{
                self.Gohome.toggle()
            }
        }
    }
}

#Preview {
    ControlView(Gohome: .constant(true))
}
