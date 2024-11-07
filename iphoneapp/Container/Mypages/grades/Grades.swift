//
//  grades.swift
//  iphoneapp
//
//  Created by mac on 11/7/24.
//

import SwiftUI

struct Grades: View {
    @StateObject var vm = GradesVM()
    
    var body: some View {
        ZStack {
            if vm.grade == .Basic{
                LinearGradient(colors: [Color.basicTop,Color.basicBottom], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }else{
                Color.black
                    .ignoresSafeArea()
            }
            VStack (spacing:0){
                Image("banner")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                modes()
                
                VStack(spacing:28) {
                    Text("Elite 모드(PRIMIUM) 구독")
                        .style(fontName: .kbold, fontSize: 28, fontColor: .white)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    Text("[구독 혜택](전체 기간) 운동 기록 조회+소모칼로리 기록 조회+이동 거리 조회+이동 루트 조회+광고 제거")
                        .style(fontName: .kmedium, fontSize: 15, fontColor: .white)
                        .frame(maxWidth: .infinity,alignment: .leading)
                }
                .padding()
                .padding(.top,20)
                
                if vm.grade != .Elite{
                    chooseTypes()
                }
                
                Spacer()
                
                Text("구독 해제는 폰 설정 > 구독 메뉴에서 활성 및 비활성 관리 가능")
                    .style(fontName: .klight, fontSize: 12, fontColor: .white)
                    .padding(5)
                
                Btn(defaultString: vm.grade == .Basic ? "프리미엄 UP" : "구독하기", fontsize: 20, fontcolor: .white, defaultColor: vm.grade == .Basic ? .black : .red)
                    .cornerRadius(50)
                    .padding(.horizontal)
            }
        }
    }
    
    // MARK: - 모드
    @ViewBuilder
    private func modes() -> some View{
        if vm.grade == .Basic{
            HStack {
                Text("헬린이 모드(BASIC) 이용중")
                    .style(fontName: .kmedium, fontSize: 22, fontColor: .black)
                Image("health")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 22, height: 22)
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            .padding()
            .background {
                Color.white
            }
        }else{
            VStack(spacing: 5) {
                HStack {
                    Text("헬창 모드(PRIMIUM) 이용중")
                        .style(fontName: .kmedium, fontSize: 22, fontColor: .white)
                    Image("logoColor")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                Text("24.08.03~25.08.02")
                    .style(fontName: .kmedium, fontSize: 22, fontColor: .white)
                    .frame(maxWidth: .infinity,alignment: .leading)
            }
            .padding()
            .background {
                LinearGradient(colors: [.themeRed,.black], startPoint: .topLeading, endPoint:.bottomTrailing)
            }
        }
    }
    
    // MARK: - 선택하는 아이템
    @ViewBuilder
    private func chooseTypes() -> some View{
        
        VStack {
            ForEach(SubscribeType.allCases, id: \.self) { item in
                Button {
                    vm.subscribeType = item
                } label: {
                    HStack {
                        Text("\(item.name) \(item.salePrice.addComma())")
                            .style(fontName: .kmedium, fontSize: 19, fontColor: vm.subscribeType == item ? .white : .black)
                        Text("\(item.name) \(item.originPrice.addComma())")
                            .style(fontName: .kmedium, fontSize: 15, fontColor: vm.subscribeType == item ? .white : .black)
                        Text("(\(item.discountRate.addComma())%)")
                            .style(fontName: .kmedium, fontSize: 15, fontColor: vm.subscribeType == item ? .white : .themeRed)
                    }
                    .frame(maxWidth: .infinity,alignment:.leading)
                    .padding()
                    .background {
                        if vm.subscribeType == item {
                            if vm.grade == .Pause {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.themeRed)
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.black)
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
}

#Preview {
    Grades()
}
