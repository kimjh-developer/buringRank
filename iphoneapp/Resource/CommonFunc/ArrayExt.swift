//
//  ArrayExt.swift
//  iphoneapp
//
//  Created by mac on 1/20/25.
//

import Foundation

extension Array where Element == String {
    mutating func removeItem(_ item: String?) {
        guard let item = item else { return }
        self.removeAll { $0 == item }
    }
}

