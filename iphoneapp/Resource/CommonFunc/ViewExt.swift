//
//  ViewExt.swift
//  iphoneapp
//
//  Created by mac on 1/31/25.
//

import SwiftUI

struct ToastView: View {
    let message: String
    @Binding var complete : Bool
    var body: some View {
        Text(message)
            .style(fontName: .kmedium, fontSize: 15, fontColor: .white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
                    self.complete.toggle()
                }
            }
    }
}
