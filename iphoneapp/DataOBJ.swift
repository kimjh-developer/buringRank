//
//  DataOBJ.swift
//  iphoneapp
//
//  Created by mac on 11/29/24.
//

import Foundation
//001596.15cc7dd8235b4d0e8ae73653df24ee84.0212
struct UserInformation:Codable {
    var userIdentifier : String?
    var userFullName : String?
    var userEmail : String?
    var userAge : Int?
    var maxHeartRate : Double?
    var isTerminate:Bool = false
}
