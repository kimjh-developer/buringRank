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
                moreview(title: "이용약관")
                moreview(title: "개인정보처리방침")
                Spacer()
            }
            
        }
        
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
    Setting()
}
