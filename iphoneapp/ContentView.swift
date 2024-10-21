//
//  ContentView.swift
//  iphoneapp
//
//  Created by mac on 10/18/24.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
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
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                    withAnimation {
                        moveNext.toggle()
                    }
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


