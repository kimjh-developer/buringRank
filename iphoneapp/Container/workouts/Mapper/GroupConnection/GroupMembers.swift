//
//  GroupMembers.swift
//  iphoneapp
//
//  Created by mac on 12/19/24.
//

import SwiftUI

struct GroupMembers: View {
    let bluetoothManager = BluetoothManager()
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            Button {
                bluetoothManager.setPosition(isMypositionHost: true)
            } label: {
                Text("iam host")
                    .style(fontName: .kmedium, fontSize: 20, fontColor: .black)
            }
            .padding()

            
            Button {
                bluetoothManager.setPosition(isMypositionHost: false)
            } label: {
                Text("iam guest")
                    .style(fontName: .kmedium, fontSize: 20, fontColor: .black)
            }
            .padding()
        }
        
    }
}

#Preview {
    GroupMembers()
}
