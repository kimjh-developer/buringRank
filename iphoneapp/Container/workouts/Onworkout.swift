//
//  Onworkout.swift
//  iphoneapp
//
//  Created by mac on 10/21/24.
//

import SwiftUI

struct Onworkout: View {
    @EnvironmentObject var workoutManager : WorkoutManager
    @StateObject var vm = OnworkoutVM()
    @Binding var workoutDone : Bool
    let gridItem : [GridItem] = [GridItem(.flexible(),spacing: 10),GridItem(.flexible(),spacing: 10)]
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(LinearGradient(colors: vm.isComplete ? [.black,.black]: vm.bGLevel.bgcolor, startPoint: .top, endPoint: .bottom))
                .ignoresSafeArea()
            VStack(spacing: 20) {
                ScrollView {
                    titleRow()
                    grids()
                }
                if vm.isComplete{
                    Button {
                        workoutManager.workoutLevel = nil
                        workoutManager.selectedWorkout = nil
                        workoutDone.toggle()
                    } label: {
                        Btn(defaultString: "버랭업 완료", fontsize: 20, fontcolor: .black, defaultColor: .white)
                            .cornerRadius(50)
                            .padding(.horizontal)
                    }

                    
                }else{
                    Btn(defaultString: "일시 정지", fontsize: 20, fontcolor: .black, defaultColor: .white)
                        .cornerRadius(50)
                        .padding(.horizontal)
                    Button {
                        vm.isComplete.toggle()
                    } label: {
                        Btn(defaultString: "운동 종료", fontsize: 20, fontcolor: .white, defaultColor: .black)
                            .cornerRadius(50)
                            .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
    }
    // MARK: - titleRow
    @ViewBuilder
    private func titleRow() -> some View{
        VStack {
            HStack(spacing: 5) {
                if !vm.isComplete{
                    if let selectedWorkout = workoutManager.selectedWorkout{
                        Text(selectedWorkout.name)
                            .style(fontName: .kmedium, fontSize: 22, fontColor: .white)
                        selectedWorkout.icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                    }
                    if !vm.isComplete{
                        Text("버닝버닝🔥")
                            .style(fontName: .kmedium, fontSize: 22, fontColor: .white)
                    }
                }
                else{
                    HStack {
                        Spacer()
                        Text("이번 운동 기록")
                            .style(fontName: .kmedium, fontSize: 22, fontColor: .black)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            .padding(.vertical,10)
            .padding(.horizontal)
            .background(content: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(vm.isComplete ? .white : .black)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 3, y: 10)
            })
            .onAppear {
                workoutManager.selectedWorkout = .mindAndBody
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - gridView
    @ViewBuilder
    private func grids() -> some View{
        LazyVGrid(columns: gridItem,spacing:15) {
            ForEach(vm.workoutInformationArray, id: \.self) { row in
                cell(item: row)
            }
        }
    }
    
    // MARK: - cell
    @ViewBuilder
    private func cell(item : WorkoutInformation) -> some View{
        VStack(spacing: 0) {
            HStack(spacing:0) {
                Text(item.title)
                    .style(fontName: .kbold, fontSize: 20, fontColor: .white)
                if let titleICO = item.titleICO{
                    titleICO
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                vm.isComplete ? Color.completeCard : Color.black
            }
            HStack {
                if item.isHeart{
                    Image(systemName: "heart.fill")
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .font(.system(size: 10))
                        .foregroundStyle(.themeRed)
                }
                Text(item.content)
                    .style(fontName: .player, fontSize: 23, fontColor: .black)
                    .fixedSize()
                if let measure = item.measure{
                    Text(measure)
                        .style(fontName: .player, fontSize: 23, fontColor: .black)
                        .fixedSize()
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                Color.white
            }
        }
        .cornerRadius(10)
    }
}

#Preview {
    Onworkout( workoutDone: .constant(true))
        .environmentObject(WorkoutManager())
}
