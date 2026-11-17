////
////  BluetoothManager.swift
////  iphoneapp
////  Created by mac on 12/19/24.

import Foundation
import MultipeerConnectivity
class BluetoothManager: NSObject,ObservableObject{
    
    private let serviceType = "brankserv" // 1~15자 이내로 간소화
//    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    @Published var peerID : MCPeerID? //=
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    var isHost: Bool?
    @Published var isSearching : Bool = false
    @Published var hostPeerID:String?
    @Published var guestArray : Array<String>?
    
    override init(){
        super.init()
        // 세션 초기화
        if session != nil{
            print("🐽 session exist")
            return
        }
        connectSession()
    }
    
    deinit {
        terminateBlueToothManager()
        session?.disconnect()
        session = nil
       }
    
    func reconnectSession(){
        terminatePage()
        DispatchQueue.main.async {
            self.connectSession()
        }
    }
    
    private func connectSession(){
        UserAthenicationVM().loadUserInformation(completion: { info in
            guard let uid = info?.userIdentifier?.prefix(6) else {return}
            self.peerID = MCPeerID(displayName: "\(UIDevice.current.name)-\(uid)")
            guard let peerID = self.peerID else {return}
            self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            self.session?.delegate = self
            print("🔓BluetoothManager 시작")
        })
    }
    
    func terminatePage(){
        terminateBlueToothManager()
        session?.disconnect()
        session = nil
        isSearching = false
    }
    
    private func terminateBlueToothManager() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        browser?.stopBrowsingForPeers()
        browser = nil
        
        print("🔒BluetoothManager 해제됨")
    }

    
    func setPosition(isMypositionHost:Bool){
        terminateBlueToothManager()
        isHost = isMypositionHost
        // 호스트와 게스트에 따른 초기화
        guard let isHost = isHost,
        let peerID = peerID
        else{return}
        guestArray = []
        print("ID PEER IS : \(peerID.displayName)")
        if isHost {
            hostPeerID = peerID.displayName
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: ["scope": "local"], serviceType: serviceType)
            advertiser?.delegate = self // Delegate 설정
            do {
                    advertiser?.startAdvertisingPeer()
                print("📢 Advertising started successfully-\(peerID.displayName)")
                }
        } else {
            browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
            browser?.delegate = self // Delegate 설정
            do {
                browser?.startBrowsingForPeers()
                    print("📢 Advertising started successfully")
                }
        }
    }
    
    // 데이터 전송 메서드
   func send(data: Foundation.Data) {
       guard let session = session else {
           print("send💀session_is_empty")
           return
       }
       guard !session.connectedPeers.isEmpty else {
           print("No connected peers to send data")
           return
       }
       do {
           try session.send(data, toPeers: session.connectedPeers, with: .reliable)
           print("데이터 전송 성공: \(data)")
       } catch {
           print("데이터 전송 실패: \(error.localizedDescription)")
       }
   }
    

}

extension BluetoothManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        guard let isHost = isHost else {return}
        switch state {
        case .connected:
            print("✅ \(peerID.displayName) 연결됨")
            DispatchQueue.main.async{
                if isHost{
                        self.guestArray?.append(peerID.displayName)
                }else{
                        self.hostPeerID = peerID.displayName
                        self.guestArray?.append(self.peerID?.displayName ?? "")
                }
            }
            
        case .connecting:
            print("⏳ \(peerID.displayName) 연결 중")
        case .notConnected:
            print("❌ \(peerID.displayName) 연결 끊김")
            if var garray = guestArray{
                garray.removeItem(peerID.displayName)
                DispatchQueue.main.async{
                    self.guestArray = garray
                }
                
            }
        @unknown default:
            print("⚠️ 알 수 없는 상태")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Foundation.Data, fromPeer peerID: MCPeerID) {
        // 데이터 수신 이벤트 처리
        if let receivedString = String(data: data, encoding: .utf8) {
            print("📥 데이터 수신: \(receivedString)")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("finish session")
    }
    
}


extension BluetoothManager:MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Foundation.Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
            print("🔗 내가방장임 ! 초대 수신: \(peerID.displayName)")
            
           invitationHandler(true, session)
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        if let nsError = error as NSError? {
            print("💀 Error: \(nsError), Code: \(nsError.code), Domain: \(nsError.domain)")
        } else {
            print("💀 Unknown error: \(error)")
        }
    }
    
}


extension BluetoothManager:MCNearbyServiceBrowserDelegate{
    // MARK: - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        guard let session = session else {
            print("💀session_is_empty")
            return
        }
        print("Peer 발견: \(peerID.displayName)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer 분실: \(peerID.displayName)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: any Error) {
        if let nsError = error as NSError? {
                print("💀 Browser Error: \(nsError), Code: \(nsError.code), Domain: \(nsError.domain)")
            } else {
                print("💀 Unknown browser error: \(error.localizedDescription)")
            }
    }
}
