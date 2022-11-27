//
//  FileManager-DocumentsDirectory.swift
//  BucketList
//
//  Created by Michael Knych on 11/22/22.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = self.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
