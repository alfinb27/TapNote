//
//  VoiceNote.swift
//  Tapnote
//
//  Created by Alfin Baby on 10/06/26.
//

import Foundation

struct VoiceNote: Identifiable, Hashable {
    let id: UUID
    let url: URL
    let createdAt: Date
    let title: String
    let duration: TimeInterval
    var isStarred: Bool
}
