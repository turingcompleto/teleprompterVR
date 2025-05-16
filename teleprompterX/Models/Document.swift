//
//  Document.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import Foundation

struct Document: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    let createdAt: Date
    var updatedAt: Date
}
