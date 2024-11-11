//
//  ContentView.swift
//  iphoneapp
//
//  Created by mac on 10/18/24.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var workoutmanager : WorkoutManager
    let splashArray = ["sp0", "sp1", "sp2", "sp3"]
    @State private var moveNext : Bool = false
    var body: some View {
        GeometryReader { geometry in
            let wsize = geometry.size.width
            ZStack {
                Image(splashArray[Int.random(in: 0...3)])
                    .resizable()
                    .scaledToFill() // 이미지를 화면에 꽉 채우도록 설정
                    .frame(width: wsize, height: geometry.size.height+10)
                    .offset(y: -5)
                
                Color.black.opacity(0.4)
                
                Image("logoWithTitle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: wsize*0.7)
            }
            .onAppear {
                workoutmanager.requestAuthorization()
            }
            .onChange(of: workoutmanager.AuthorizationGranted ?? false) { oldValue, newValue in
                
                if newValue == true{
                        moveNext.toggle()
                    }else{
                        Alert(title: Text("권한설정"),
                              message: Text("버닝랭크를 사용하기위해 운동정보를 허용해 주세요"),
                              dismissButton: .default(Text("확인"), action: {
                            moveNext.toggle()
                        }))
                    }
                
                
            }
        }
        .ignoresSafeArea() // 전체 화면 사용
        .navigationDestination(isPresented: $moveNext) {
            Container()
        }
    }
}



#Preview {
    ContentView()
}


