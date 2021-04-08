//
//  ChatViewController.swift
//  HelloMessage
//
//  Created by Wesley Osborne on 4/6/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
  var sender: SenderType
  var messageId: String
  var sentDate: Date
  var kind: MessageKind
}

extension MessageKind {
  var messageKindString: String {
    switch self {
    case .text(_):
      return "text"
    case .attributedText(_):
      return "attributed_text"
    case .photo(_):
      return "photo"
    case .video(_):
      return "video"
    case .location(_):
      return "location"
    case .emoji(_):
      return "emoji"
    case .audio(_):
      return "audio"
    case .contact(_):
      return "contact"
    case .linkPreview(_):
      return "link_preview"
    case .custom(_):
      return "custom"
    }
  }
}

struct Sender: SenderType {
  var photoURL: String
  var senderId: String
  var displayName: String
}

class ChatViewController: MessagesViewController {
  
  public static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .long
    formatter.locale = .current
    return formatter
  }()
  
  // MARK: - Initializers
  public let otherUserEmail: String
  public var isNewConversation = false
  
  private var messages = [Message]()

  private var selfSender: Sender? {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return nil
    }
    return Sender(photoURL: "",
           senderId: email,
           displayName: "Joe Smith")
  }
  
  init(with email: String) {
    self.otherUserEmail = email
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    messageInputBar.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    messageInputBar.inputTextView.becomeFirstResponder()
  }
  
}


// MARK: - MessageDataSource, MessageLayoutDelegate, MessageDisplayDelegate
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
  func currentSender() -> SenderType {
    if let sender = selfSender {
      return sender
    }
    
    fatalError("Self Sender is nil, email should be cached")
    return Sender(photoURL: "", senderId: "12", displayName: "")
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
          let selfSender = self.selfSender,
          let messageId = createMessageId() else {
      return
    }
    
    print("Sending: \(text)")
    // Send Message
    if isNewConversation {
      // create convo in database
      let message = Message(sender: selfSender,
                            messageId: messageId,
                            sentDate: Date(),
                            kind: .text(text))
      DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message) { (success) in
        if success {
          print("Message sent")
        } else {
          print("failed to send")
        }
      }
    } else {
      // append to exisiting conversation data
    }
    
  }
  
  private func createMessageId() -> String? {
    // date, otherUserEmail, senderEmail, randomInt
    guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
      return nil
    }
    
    let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
    
    let dateString = Self.dateFormatter.string(from: Date())
    let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
    print("created message id: \(newIdentifier)")
    return newIdentifier
  }
}
