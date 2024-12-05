//
//  Counter.swift
//  iphoneapp
//
//  Created by mac on 12/2/24.
//

import SwiftUI

struct Counter: View {
    @Environment(\.dismiss) var dismiss
    let grids : [GridItem] = [GridItem(.flexible(),spacing: 10),GridItem(.flexible(),spacing: 10)]
    @StateObject var vm = CounterVM()
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            GeometryReader { proxy in
                VStack {
                    Text("세트 카운터")
                        .style(fontName: .kbold, fontSize: 32, fontColor: .white)
                    workoutTypes()
                    counter(proxy: proxy)
                    Spacer()
                    timerView()
                    btnGroup()
                }
            }
            if vm.warnActivate {
               VStack {
                   Spacer()
                   Text(vm.warnMSG)
                       .padding()
                       .background(Color.black.opacity(0.8))
                       .foregroundColor(.white)
                       .cornerRadius(8)
                       .padding(.bottom, 50) // 아래쪽 여백
                       .transition(.move(edge: .bottom).combined(with: .opacity))
                       .animation(.easeInOut, value: vm.warnActivate)
               }
               .onAppear {
                   DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                       vm.warnActivate = false
                   }
               }
           }
        }
        .sheet(isPresented: $vm.showSummaryActivate, content: {
            completeSummary()
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white) // 커스텀 뒤로가기 버튼 색상
                }
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        .onDisappear {
            vm.stopTimer()
        }
    }

    // MARK: - 운동
    @ViewBuilder
    private func workoutTypes() -> some View{
        ScrollView(.horizontal) {
            HStack {
                if let choosedmuscleGroupExercises = vm.choosedmuscleGroupExercises{
                    ForEach(choosedmuscleGroupExercises.exercises.indices, id: \.self){i in
                        excersiseCell(item: choosedmuscleGroupExercises.exercises[i])
                    }
                    
                }else{
                    ForEach(vm.muscleGroupExercises.indices, id: \.self) { i in
                        groupCell(item: vm.muscleGroupExercises[i])
                    }
                }
            }
            .background {
                withAnimation {
                    vm.warnActivate ? Color.white.opacity(0.5) : Color.clear
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 셀
    @ViewBuilder
    private func groupCell(item : MuscleGroupExercise) -> some View{
        Button {
            vm.choosedmuscleGroupExercises = item
        } label: {
            Text(item.muscleGroup)
                .style(fontName: .kmedium, fontSize: 20, fontColor: .white)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white, lineWidth: 1)
                }
                .padding(5)
        }
    }
    @ViewBuilder
    private func excersiseCell(item : String) -> some View{
        Button {
            vm.startTimer()
            vm.exercises = item
        } label: {
            Text(item)
                .style(fontName: .kmedium, fontSize: 20, fontColor: vm.exercises == item ? .black : .white)
                .padding()
                .background {
                    if vm.exercises == item{
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.white)
                    }else{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white, lineWidth: 1)
                    }
                    
                }
                .padding(5)
        }
    }
    
    // MARK: - 카운터
    @ViewBuilder
    private func counter(proxy:GeometryProxy) -> some View{
        ZStack {
            Color.clear
            Text("\(vm.counter)")
                .style(fontName: .player, fontSize: 200, fontColor: .white)
                .background {
                    Circle()
                        .stroke(.white, lineWidth: 1.0)
                        .frame(width: proxy.size.width*0.9, height: proxy.size.width*0.9)
                        .aspectRatio(1.0, contentMode: .fit)
                }
                .frame(width: proxy.size.width*0.9, height: proxy.size.width*0.9)
        }
        
            
            
    }
    
    // MARK: - 타이머
    @ViewBuilder
    private func timerView() -> some View{
        Text(vm.timerString)
            .style(fontName: .player, fontSize: 25, fontColor: .white)
            
            
    }
    
    // MARK: - 버튼그룹
    @ViewBuilder
    private func btnGroup() -> some View{
        VStack {
            HStack {
                HStack {
                    Button {
                        vm.downCounter()
                    } label: {
                        Image(systemName: "arrowtriangle.down.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 30))
                    }
                    Rectangle()
                        .frame(width: 1,height: 25)
                        
                        .foregroundStyle(.white)
                    
                    Button {
                        vm.upCounter()
                    } label: {
                        HStack {
                            Text("셋트완료")
                                .style(fontName: .kbold, fontSize: 25, fontColor: .white)
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: 30))
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white, lineWidth: 1.0)
                }
                
                Button {
                    vm.otherWorkout()
                } label: {
                    Text("다른운동")
                        .style(fontName: .kbold, fontSize: 25, fontColor: .white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 1.0)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            Button {
                vm.finishWorkout()
            } label: {
                Text("운동완료")
                    .style(fontName: .kbold, fontSize: 25, fontColor: .black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                    
            }
        }
        .padding(12)
        
    }
    
    // MARK: - 완료summary
    @ViewBuilder
    private func completeSummary() -> some View{
        VStack(spacing:20) {
            Text("운동종료")
                .style(fontName: .kbold, fontSize: 25, fontColor: .black)
                
            HStack {
                Text("총 운동시간")
                    .style(fontName: .kbold, fontSize: 20, fontColor: .black)
                Spacer()
                Text(vm.timerString)
                    .style(fontName: .kbold, fontSize: 20, fontColor: .black)
            }
            HStack {
                Text("총 운동")
                    .style(fontName: .kbold, fontSize: 20, fontColor: .black)
                Spacer()
            }
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(vm.savedMuscleGroupExercises.indices, id: \.self) { i in
                        scrollRow(item: vm.savedMuscleGroupExercises[i])
                    }
                }
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Btn(defaultString: "운종종료", fontsize: 20, fontcolor: .white, defaultColor: .black)
            }

        }
        .padding()
    }
    
    // MARK: - 완료스크롤디테일
    @ViewBuilder
    private func scrollRow(item:SavedMuscleGroupExercises) -> some View{
        HStack(alignment:.bottom) {
            Text(item.muscleGroupExercise.muscleGroup)
                .style(fontName: .player, fontSize: 20, fontColor: .black)
            Text("(\(item.exercises))")
                .style(fontName: .player, fontSize: 10, fontColor: .black)
            Spacer()
            Text("\(item.counter) set")
                .style(fontName: .player, fontSize: 20, fontColor: .black)
        }
    }
    
}

#Preview {
    Counter()
}
