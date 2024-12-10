//
//  grades.swift
//  iphoneapp
//
//  Created by mac on 11/7/24.
//

import SwiftUI

struct Grades: View {
//    @StateObject var vm = GradesVM()
    @StateObject var storeManager = StoreManager()
    let dateFormat : String = "yy.M.d hh:mm:ss"
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [Color.basicTop,Color.basicBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        
            VStack (spacing:0){
                Image("banner")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                
                modes()
                
//                Text(storeManager.purchaseStatus)
                
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
                
                if storeManager.activateProduct == nil{
                    chooseTypes()
                }
                
                Spacer()
                
                Text("구독 해제는 폰 설정 > 구독 메뉴에서 활성 및 비활성 관리 가능")
                    .style(fontName: .klight, fontSize: 12, fontColor: .white)
                    .padding(5)
                
                
                if !storeManager.isSubscribed{
                    Button {
                        Task {
                            if let selectProduct = storeManager.selectProduct {
                                await storeManager.purchaseSubscription(selectProduct)
                                } else {
                                    print("No product selected for purchase.")
                                }
                            }
                    } label: {
                        Btn(defaultString: "프리미엄 UP" , fontsize: 20, fontcolor: .white, defaultColor: .black)
                            .cornerRadius(50)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await storeManager.fetchSubscriptions()
                await storeManager.checkSubscriptionStatus()
            }
        }
        
    }
    // MARK: - 모드
    @ViewBuilder
    private func modes() -> some View{
        if let product = storeManager.activateProduct{
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
                
                
                if let expiredate = storeManager.activateProduct?.expirationDate?.toKST()?.toString(format: dateFormat),
                   let purchaseDate = storeManager.activateProduct?.purchaseDate.toKST()?.toString(format: dateFormat){
                    Text("\(purchaseDate) ~ \(expiredate)")
                        .style(fontName: .kmedium, fontSize: 15, fontColor: .white)
                        .frame(maxWidth: .infinity,alignment: .leading)
                }
                
                
            }
            .padding()
            .background {
                LinearGradient(colors: [.themeRed,.black], startPoint: .topLeading, endPoint:.bottomTrailing)
            }
        }else{
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
        }
        
    }
    
    // MARK: - 선택하는 아이템
    @ViewBuilder
    private func chooseTypes() -> some View{
        VStack {
            ForEach(storeManager.subscriptions, id: \.self) { item in
                if let type = storeManager.guessSubscribeType(item: item){
                    Button {
                        storeManager.selectProduct = item
                    } label: {
                        HStack {
                            Text("\(type.name) \(type.salePrice.addComma())")
                                .style(fontName: .kmedium, fontSize: 19, fontColor: storeManager.selectProduct == item ? .white : .black)
                            Text("\(type.name) \(type.originPrice.addComma())")
                                .style(fontName: .kmedium, fontSize: 15, fontColor: storeManager.selectProduct == item ? .white : .black)
                            Text("(\(type.discountRate.addComma())%)")
                                .style(fontName: .kmedium, fontSize: 15, fontColor: storeManager.selectProduct == item ? .white : .themeRed)
                        }
                        .frame(maxWidth: .infinity,alignment:.leading)
                        .padding()
                        .background {
                            if storeManager.selectProduct == item {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.black)
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.white)
                            }
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
