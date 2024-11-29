//
//  UserAthenicationVM.swift
//  iphoneapp
//
//  Created by mac on 11/29/24.
//

import Foundation
import AuthenticationServices
class UserAthenicationVM:ObservableObject{
    @Published var AthenicationPass : Bool = false
    
    func checkoutAthenicationPass(completion : @escaping (Bool)->Void){
        
            completion(loadUserInformation() != nil)
        
    }
    
    func handleSignInWithAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            checkoutAthenicationPass { result in
                if result{//데이터가 없으면 새로 넣음
                    if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                        // 사용자 정보 추출
                            var userInformation = UserInformation()
                            userInformation.userIdentifier = credential.user
                            userInformation.userFullName = "\(credential.fullName?.givenName ?? "") \(credential.fullName?.familyName ?? "")"
                            userInformation.userEmail = credential.email
                            UserDefaults.standard.set(userInformation, forKey: "appleUserIdentifier")
                        
                    }
                }
                self.AthenicationPass = true
            }
            
        case .failure(let error):
            // 에러 처리
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
    
    func saveUserInformation(_ userInformation: UserInformation) {
        let encoder = JSONEncoder()
        do {
            // 구조체를 JSON 데이터로 변환
            let data = try encoder.encode(userInformation)
            // UserDefaults에 JSON 데이터 저장
            UserDefaults.standard.set(data, forKey: "appleUserIdentifier")
        } catch {
            print("Failed to encode UserInformation: \(error.localizedDescription)")
        }
    }

    
    func loadUserInformation() -> UserInformation? {
        if let savedData = UserDefaults.standard.data(forKey: "appleUserInformation") {
            let decoder = JSONDecoder()
            if let loadedUserInformation = try? decoder.decode(UserInformation.self, from: savedData) {
                return loadedUserInformation
            }
        }
        return nil
    }
    
    func updateUserInformation(updates: (inout UserInformation) -> Void) {
        // 기존 데이터 불러오기
        var currentInfo = loadUserInformation() ?? UserInformation()

        // 업데이트 적용
        updates(&currentInfo)

        // 수정된 데이터 다시 저장
        saveUserInformation(currentInfo)
        
        /*
         updateUserInformation { userInfo in
             userInfo.userFullName = "Jane Doe"
             userInfo.userAge = 32
         }

         */
    }
}

