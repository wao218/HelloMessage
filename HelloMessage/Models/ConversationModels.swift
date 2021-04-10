//
//  ConversationModels.swift
//  HelloMessage
//
//  Created by Wesley Osborne on 4/10/21.
//

import Foundation

struct Conversation {
  let id: String
  let name: String
  let otherUserEmail: String
  let latestMessage: LatestMessage
}

struct LatestMessage {
  let date: String
  let isRead: Bool
  let text: String
}
