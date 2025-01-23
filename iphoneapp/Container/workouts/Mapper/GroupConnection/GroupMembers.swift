//
//  GroupMembers.swift
//  iphoneapp
//
//  Created by mac on 12/19/24.
//

import SwiftUI

struct GroupMembers: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @StateObject var vm = GroupMembersVM()
    var body: some View {
        VStack (spacing: 20){
            NavigationLink(destination: Tracker()) {
                Text("나홀로 여행")
                    .foregroundStyle(.black)
            }
            
            Button {
                vm.isShowGroupMembers.toggle()
            } label: {
                Text("팀 트래킹")
                    .foregroundStyle(.black)
            }

        }
        .sheet(isPresented: $vm.isShowGroupMembers) {
            TeamHikeOption()
        }

        
    }
    // MARK: - 옵션시트
    @ViewBuilder
    private func TeamHikeOption() -> some View{
                    VStack {
                        if let hostPeerID = bluetoothManager.hostPeerID{
                            Text("호스트 생성: \(hostPeerID)")
                                .foregroundStyle(.black)
                        }
                        
                        if let guestArray = bluetoothManager.guestArray{
                            ForEach(guestArray.indices, id: \.self) { i in
                                Text(guestArray[i])
                                    .foregroundStyle(.black)
                            }
                        }
                        
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
                        
                        if let isHost = bluetoothManager.isHost,
                           let guestArray = bluetoothManager.guestArray,
                           let peerID = bluetoothManager.peerID?.displayName{
                                if guestArray.contains(peerID){
                                    Button {
                                        bluetoothManager.terminatePage()
                                    } label: {
                                        Text("파티떠나기")
                                            .style(fontName: .kmedium, fontSize: 10, fontColor: .black)
                                    }

                                }
                        }
                        
    //                    Button {
    //                        UserAthenicationVM().loadUserInformation { data in
    //                            if let userInformation = data{
    //
    //                                ConnectionManager.Call(tail: "add-user-data",data: try? JSONEncoder().encode(userInformation)) { res in
    //                                    print("res IS \(res)")
    //
    //                                }
    //                            }
    //                        }
    //                    } label: {
    //                        Text("callTest")
    //                            .style(fontName: .kmedium, fontSize: 20, fontColor: .black)
    //                    }
    //                    .padding()
    //
    //
    //
    //                    Button {
    //                        ConnectionManager.Call(tail: "list-users",connectionMethod: .get) { Data in
    //                                            guard let D = Data else {return}
    //                                            print(D)
    //                                        }
    //                    } label: {
    //                        Text("callTest2")
    //                            .style(fontName: .kmedium, fontSize: 20, fontColor: .black)
    //                    }
    //                    .padding()
            
                    }
        
    }
    
    
}

#Preview {
    GroupMembers()
}
