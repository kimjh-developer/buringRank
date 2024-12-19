////
////  BluetoothManager.swift
////  iphoneapp
////
////  Created by mac on 12/19/24.
////
//
import Foundation
import MultipeerConnectivity


class BluetoothManager: NSObject,ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    private let serviceType = "brankservice"
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    var isHost: Bool?

    override init(){
        super.init()
        // 세션 초기화
        if session != nil{
            print("🐽 session exist")
            return
        }
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        print("BluetoothManager 시작")
    }
    
    deinit {
           // 광고 및 브라우징 중지
           advertiser?.stopAdvertisingPeer()
           browser?.stopBrowsingForPeers()
           
           // 세션 종료
           session?.disconnect()
           print("BluetoothManager 해제됨")
       }
    
    func setPosition(isMypositionHost:Bool){
        isHost = isMypositionHost
        // 호스트와 게스트에 따른 초기화
        guard let isHost = isHost else{return}
        if isHost {
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
            advertiser?.delegate = self // Delegate 설정
            advertiser?.startAdvertisingPeer()
        } else {
            browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
            browser?.delegate = self // Delegate 설정
            browser?.startBrowsingForPeers()
        }
    }
    
    // 데이터 전송 메서드
   func send(data: Foundation.Data) {
       guard let session = session else {
           print("💀session_is_empty")
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

    // MARK: - MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("\(peerID.displayName) 연결됨")
        case .connecting:
            print("\(peerID.displayName) 연결 중")
        case .notConnected:
            print("\(peerID.displayName) 연결 끊김")
        @unknown default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Foundation.Data, fromPeer peerID: MCPeerID) {
        if let receivedString = String(data: data, encoding: .utf8) {
            print("데이터 수신 성공: \(receivedString)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Foundation.Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
            print("초대 수신: \(peerID.displayName)")
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
