//
//  Setting.swift
//  iphoneapp
//
//  Created by mac on 11/8/24.
//

import SwiftUI

struct Setting: View {
    @Environment(\.dismiss) var dismiss
    @State var pushActivate : Bool = true
    @State var logoutActivate : Bool = false
    @Binding var backToSplash : Bool
    @State var userState : UserState = .normal
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                VStack {
                    HStack {
                        Toggle(isOn: $pushActivate) {
                            Text("앱 푸시 알림")
                                .style(fontName: .klight, fontSize: 16, fontColor: .black)
                        }
                        .tint(.black)
                    }
                    .padding()
                    Divider()
                }
                VStack {
                    HStack {
                        Text("버전정보")
                            .style(fontName: .klight, fontSize: 16, fontColor: .black)
                        Spacer()
                        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            Text("\(appVersion)(\(buildNumber))")
                                .style(fontName: .klight, fontSize: 16, fontColor: Color.version)
                        }
                    }
                    .padding()
                    Divider()
                }
                NavigationLink {
                    DocumentPages(userDocument: .termCondition)
                } label: {
                    moreview(title: "이용약관")
                }
                NavigationLink {
                    DocumentPages(userDocument: .termCondition)
                } label: {
                    moreview(title: "개인정보처리방침")
                }
                Spacer()
                
                
                VStack {
                    HStack {
                        Button {
                            userState = .logout
                            logoutActivate.toggle()
                        } label: {
                            Text("로그아웃")
                                .style(fontName: .klight, fontSize: 16, fontColor: .black)
                            Spacer()
                        }
                    }
                    .padding()
                    Divider()
                }
                VStack {
                    HStack {
                        Button {
                            userState = .terminate
                            logoutActivate.toggle()
                        } label: {
                            Text("탈퇴")
                                .style(fontName: .klight, fontSize: 16, fontColor: .black)
                            Spacer()
                        }
                    }
                    .padding()
                    
                }
            }
            
            
        }
        .alert(isPresented: $logoutActivate) {
            Alert(
                title: Text("버닝랭크를 \(userState.name)아웃하시겠습니까?"),
                primaryButton: .default(Text(userState.name)) {
                    UserAthenicationVM().loadUserInformation(completion: { userinformation in
                        if var userInfo = userinformation { // 복사본 생성
                            userInfo.userState = userState
                            UserAthenicationVM().saveUserInformation(userInfo)
                            UserInformationManager.shared.userInformation = nil
                        }
                    })
                    backToSplash = true
                    dismiss()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
        .foregroundColor(.black) // 텍스트 색상 강제 적용
        

        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black) // 커스텀 뒤로가기 버튼 색상
                }
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        
    }
    // MARK: - 더보기row
    @ViewBuilder
    private func moreview(title:String) -> some View{
        VStack {
            HStack {
                Text(title)
                    .style(fontName: .klight, fontSize: 16, fontColor: .black)
                Spacer()
                Image(systemName: "chevron.right")
                    .renderingMode(.template)
                    .foregroundStyle(Color.more)
            }
            .padding()
            Divider()
        }
        
    }
    
    
}

#Preview {
    Setting(backToSplash: .constant(false))
}
