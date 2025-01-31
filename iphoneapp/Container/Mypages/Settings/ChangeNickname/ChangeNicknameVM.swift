//
//  File.swift
//  iphoneapp
//
//  Created by mac on 1/31/25.
//

import Foundation

class ChangeNicknameVM : ObservableObject{
    @Published var nickname : String = ""
    @Published var satisfied : Bool = false
    @Published var unsatisfyCondition: String? = nil
    @Published var toastString : String? = nil
    @Published var showToast : Bool = false
    init() {
        UserAthenicationVM().loadUserInformation(completion: { userInfo in
            if let userNickname = userInfo?.userNickname{
                self.nickname = userNickname
            }
        })
    }
    
    func changeTextSatisfing() {
           let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
           
           if trimmedNickname.isEmpty {
               unsatisfyCondition = "닉네임을 입력해주세요."
               satisfied = false
               return
           }

           let characterCount = trimmedNickname.count
           
           
           if characterCount >= 2 && characterCount <= 5 {
               satisfied = true
               unsatisfyCondition = nil // 조건 만족시 경고 메시지 삭제
           } else {
               satisfied = false
               if characterCount < 2{
                  unsatisfyCondition = "닉네임은 2자 이상이어야 합니다."
               } else if characterCount > 5{
                    unsatisfyCondition = "닉네임은 5자 이내여야 합니다."
               }  else{
                  unsatisfyCondition = "닉네임 조건이 만족하지 않습니다."
               }
              
           }
       }
    
    func changeNickname(){
        let encoder = JSONEncoder()
        UserAthenicationVM().loadUserInformation { UserInformation in
            guard var userInformation = UserInformation
            else {return}
            
            userInformation.userNickname = self.nickname
            
            if let data = try? encoder.encode(userInformation){
                UserDefaults.standard.set(data, forKey:UserAthenicationVM().userdefaultKey)
                self.toastString = "변경되었습니다"
                self.showToast = true
            }
        }
    }
}
