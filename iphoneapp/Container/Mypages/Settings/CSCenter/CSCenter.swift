//
//  CSCenter.swift
//  iphoneapp
//
//  Created by mac on 11/8/24.
//

import SwiftUI

struct CSCenter: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack (alignment: .leading,spacing:8){
                Image("csLogo")
                    .aspectRatio(contentMode: .fit)
                    
                Text("Developer. Joohyung Kim")
                    .style(fontName: .player, fontSize: 23, fontColor: .white)
                Text("Email : fylfotkim@gmail.com")
                    .style(fontName: .player, fontSize: 23, fontColor: .white)
                Text("[이메일 문의 답변 시간]\n매일 09:00 ~ 18:00")
                    .style(fontName: .player, fontSize: 20, fontColor: .white)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    CSCenter()
}
