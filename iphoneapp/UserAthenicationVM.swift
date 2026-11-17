//
//  UserAthenicationVM.swift
//  iphoneapp
//
//  Created by mac on 11/29/24.
//

import Foundation
import AuthenticationServices
class UserAthenicationVM:ObservableObject{
    let userdefaultKey = "appleUserIdentifier"
    @Published var AthenicationPass : Bool = false
    @Published var moveNext : Bool = false
    @Published var hideLogin : Bool = false
    @Published var warnActivate : Bool = false
    func checkoutAthenicationPass(){
        loadUserInformation { result in
            if let userState = result?.userState{
                if userState == .terminate{
                    self.warnActivate = true
//                    self.AthenicationPass = false
                    self.hideLogin = true
//                    self.moveNext = false
                }else{
                    if let info = result{
                        let value = userState == .normal
                        self.saveUserInformation(info)
                    }
                }
                
            }
        }
        
    }
    
    func handleSignInWithAppleResult(_ result: Result<ASAuthorization, Error>) {
        print("handleSignInWithAppleResult")
        switch result {
        case .success(let authResults):
            // 데이터가 Z없으면 새로 넣음
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                // 사용자 정보 추출
                loadExistUserInformation { existInfo in
                    if let userState = existInfo?.userState{
                        if userState == .terminate{
                            self.warnActivate = true
                            return
                        }else{
                            if var info = existInfo{
                                if info.userIdentifier ?? "" == credential.user{
                                    info.userState = .normal
                                    UserInformationManager.shared.userInformation = info
                                    self.saveUserInformation(info)
                                    self.executeAndMoveNext()
                                }else{
                                    self.registMember(credential: credential)
                                }
                            }else{
                                self.registMember(credential: credential)
                            }
                            
                        }
                    }else{
                        self.registMember(credential: credential)
                    }
                }
            }
            
            
        case .failure(let error):
            // 에러 처리
            print("Authorization failed: \(error.localizedDescription)")
            
        }
    }
    
    
    
    
    private func registMember(credential : ASAuthorizationAppleIDCredential){
        var userInformation = UserInformation()
        userInformation.userIdentifier = credential.user
        userInformation.userNickname = RandomIDS().generateRandomID()
        if let givenName = credential.fullName?.givenName,let familyName = credential.fullName?.familyName{
            userInformation.userFullName = givenName+familyName
        }
        if let email = credential.email{
            userInformation.userEmail = email
        }
        
        userInformation.userState = .normal
        saveUserInformation(userInformation)
        UserInformationManager.shared.userInformation = userInformation
        
        executeAndMoveNext()
        print("Set UserDefaults successfully")
        
    }
    
    private func executeAndMoveNext(){
        AthenicationPass = true
        hideLogin = true
        moveNext = true
    }
    
    func saveUserInformation(_ userInformation: UserInformation) {
        let encoder = JSONEncoder()
        do {
            // 구조체를 JSON 데이터로 변환
            let data = try encoder.encode(userInformation)
            // UserDefaults에 JSON 데이터 저장
            UserDefaults.standard.set(data, forKey: self.userdefaultKey)
            ConnectionManager.Call(tail: "user_add_modify",data: data) { res in
                print("res IS \(String(describing: res))")
                self.executeAndMoveNext()
            }
            
        } catch {
            print("Failed to encode UserInformation: \(error.localizedDescription)")
        }
    }
    
    func deleteUserInformation() {
        UserDefaults.standard.removeObject(forKey: userdefaultKey)
        print("User information has been deleted.")
    }
    
    
    
    func loadUserInformation(completion : @escaping (UserInformation?)->Void){
        if let savedData = UserDefaults.standard.data(forKey: userdefaultKey) {
            do {
                let userInformation = try JSONDecoder().decode(UserInformation.self, from: savedData)
                print("Retrieved UserInformation: \(userInformation)")
                UserInformationManager.shared.userInformation = userInformation
                completion(userInformation)
            } catch {
                print("Failed to decode UserInformation: \(error)")
                completion(nil)
            }
        }
        completion(nil)
    }
    
    func loadExistUserInformation(completion : @escaping (UserInformation?)->Void){
        if let savedData = UserDefaults.standard.data(forKey: userdefaultKey) {
            do {
                let userInformation = try JSONDecoder().decode(UserInformation.self, from: savedData)
                print("Retrieved UserInformation: \(userInformation)")
                
                    UserInformationManager.shared.userInformation = userInformation
                    completion(userInformation)
                
            } catch {
                print("Failed to decode UserInformation: \(error)")
                completion(nil)
            }
        }else{
            completion(nil)
        }
    }
    
    
}

final class UserInformationManager {
    static let shared = UserInformationManager()
    
    private init() {} // 외부에서 인스턴스 생성을 막기 위해 private
    
    var userInformation: UserInformation?
    func updateUserInformation(_ info: UserInformation) {
        self.userInformation = info
    }
    
    func clearUserInformation() {
        self.userInformation = UserInformation(
            userIdentifier: nil,
            userFullName: nil,
            userEmail: nil,
            userAge: nil,
            maxHeartRate: nil
        )
    }
}


