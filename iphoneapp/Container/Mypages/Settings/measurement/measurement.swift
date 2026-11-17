//
//  measurement.swift
//  iphoneapp
//
//  Created by mac on 11/8/24.
//

import SwiftUI

struct measurement: View {
    @Environment(\.dismiss) var dismiss
    private let weeks = ["월","화","수","목","금","토","일"]
    @State var startYoil = "월"
    @State var popActivate : Bool = false
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack {
                Text("주간 시작 요일")
                    .style(fontName: .kbold, fontSize: 22, fontColor: .black)
                    .frame(maxWidth: .infinity,alignment: .leading)
                Button {
                    popActivate.toggle()
                } label: {
                    HStack {
                        Text("\(startYoil)요일")
                            .style(fontName: .klight, fontSize: 20, fontColor: .btnDisable)
                        Spacer()
                        Image(systemName: "triangleshape.fill")
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.btnDisable)
                            .rotationEffect(Angle(degrees: 180))
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.btnDisable, lineWidth: 1.0)
                    }
                }
                Spacer()
                Button {
                    print("saveSetting")
                } label: {
                    Btn(defaultString: "저장하기", fontsize: 20, fontcolor: .white, defaultColor: .black)
                }

            }
            .padding()
            
            if popActivate{
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    VStack {
                        Picker("요일 선택", selection: $startYoil) {
                            ForEach(weeks, id: \.self) { yoil in
                                Text("\(yoil)요일")
                            }
                        }
                        .pickerStyle(WheelPickerStyle()) // Wheel 스타일 적용
                        .frame(height: 150) // 높이 조정
                        .foregroundStyle(Color.red)
                        Button {
                            popActivate.toggle()
                        } label: {
                            Btn(defaultString: "선택완료", fontsize: 20, fontcolor: .white, defaultColor: .black)
                                .padding()
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.white)
                    }
                    .padding()
                }
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
}


#Preview {
    measurement()
}
