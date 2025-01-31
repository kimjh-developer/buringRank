//
//  ChangeNickname.swift
//  iphoneapp
//
//  Created by mac on 1/31/25.
//

import SwiftUI

struct ChangeNickname: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = ChangeNicknameVM()
    @State var toastActivated : Bool = false
    var body: some View {
        ZStack {
            VStack(alignment:.leading,content: {
                VStack {
                    TextField(vm.nickname, text: $vm.nickname)
                        .onChange(of: vm.nickname, { oldValue, newValue in
                            vm.changeTextSatisfing()
                        })
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.btnInactivate, lineWidth: 1.0)
                        }
                    if let unsatisfyCondition = vm.unsatisfyCondition{
                        Text(unsatisfyCondition)
                            .style(fontName: .klight, fontSize: 11, fontColor: .danger)
                    }
                }
                .padding(.vertical)
                
                Spacer()
                
                Button {
                    vm.changeNickname()
                } label: {
                    Btn(defaultString: "변경하기", fontsize: 20, fontcolor: .white, defaultColor: vm.satisfied ? .midBottom : .btnDisable)
                }
                .disabled(!vm.satisfied)

                
            })
            
            if vm.showToast{
                ToastView(message: vm.toastString ?? "unIdentified",complete: $toastActivated)
                    .transition(.opacity)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black) // 커스텀 뒤로가기 버튼 색상
                    }
                    Text("닉네임 변경")
                        .style(fontName: .kbold, fontSize: 22, fontColor: .black)
                }
                
            }
        }
        .navigationBarBackButtonHidden()
        .onChange(of: toastActivated) { oldValue, newValue in
            if newValue{dismiss()}
        }
    }
    
}



#Preview {
    ChangeNickname()
}
