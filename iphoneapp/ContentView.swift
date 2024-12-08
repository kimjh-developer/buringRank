//
//  ContentView.swift
//  iphoneapp
//
//  Created by mac on 10/18/24.
//

import SwiftUI
import HealthKit
import AuthenticationServices
struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @StateObject var locationManager  = LocationManager()
    @StateObject var userAthenicationVM = UserAthenicationVM()
    let splashArray = ["sp0", "sp1", "sp2", "sp3"]
    
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
                
                if !userAthenicationVM.hideLogin{
                    VStack {
                        Spacer()
                        
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                // 애플 로그인 요청 구성
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                // 결과 처리
        //                        vm.handleSignInWithAppleResult(result)
                                userAthenicationVM.handleSignInWithAppleResult(result)
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .padding()
                        
                        Button {
                            userAthenicationVM.moveNext = true
                        } label: {
                            Text("로그인없이 버닝랭크이용하기")
                                .style(fontName: .klight, fontSize: 12, fontColor: .white)
                                .underline()
                        }

                    }
                    .padding(.bottom,40)
                }
                
                
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
                    
                        userAthenicationVM.checkoutAthenicationPass ()
                    
                }
            }
            .alert(isPresented: $userAthenicationVM.warnActivate) {
                Alert(title: Text("탈퇴한계정입니다"), message:Text("설정->애플 apple로 로그인 iphoneapp을 삭제해주세요 에서 버닝랭크를 초기화해주세요") , dismissButton: .default(Text("확인"), action: {
                    userAthenicationVM.warnActivate.toggle()
                }))
            }
            .foregroundColor(.black) // 텍스트 색상 강제 적용
        }
        .ignoresSafeArea() // 전체 화면 사용
        .navigationDestination(isPresented: $userAthenicationVM.moveNext) {
            Container()
        }
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}



#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}


