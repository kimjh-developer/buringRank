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
    @State private var moveNext : Bool = false
    @State private var hideLogin : Bool = false
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
                
                if !hideLogin{
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
                                userAthenicationVM.handleSignInWithAppleResult(result){result in
                                    if result{
                                        hideLogin = true
                                        moveNext = true
                                    }
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .padding()
                        
                        Button {
                            moveNext.toggle()
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
                userAthenicationVM.checkoutAthenicationPass(){result in
                    if result{
                        hideLogin = true
                        locationManager.requestAuthorization ()
                    }else{
                        hideLogin = false
                    }
                }
            }
            .onChange(of: userAthenicationVM.AthenicationPass, { oldValue, newValue in
                if newValue{
                    moveNext = true
                }
            })
//            .onChange(of: workoutManager.AuthorizationFullyGranted) { oldValue, newValue in
//                if newValue == true && userAthenicationVM.AthenicationPass == true{
//                        moveNext.toggle()
//                    }
//            }
            .alert(isPresented: $workoutManager.AuthoriseWarn){
                Alert(
                    title: Text("권한 필요"),
                    message: Text("운동 경로 데이터를 가져오려면 권한이 필요합니다. 설정에서 권한을 활성화하세요."),
                    primaryButton: .default(Text("설정 열기"), action: openAppSettings),
                    secondaryButton:  .default(Text("바로 사용"), action: {
                        moveNext.toggle()
                    })
                )
            }
        }
        .ignoresSafeArea() // 전체 화면 사용
        .navigationDestination(isPresented: $moveNext) {
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


