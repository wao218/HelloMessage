//
//  StorageManager.swift
//  HelloMessage
//
//  Created by Wesley Osborne on 4/6/21.
//

import Foundation
import FirebaseStorage

/// Manager object to fetch and upload to firebase storage
final class StorageManager {
  static let shared = StorageManager()
  
  private init() {}
  
  private let storage = Storage.storage().reference()
  
  public typealias UploadMediaCompletion = (Result<String, Error>) -> Void
  
  /// Uploads picture to firebase storage and returns completion with url string to download
  public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadMediaCompletion) {
    storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] (metadata, error) in
      guard error == nil else {
        // failed
        print("failed to upload data to firebase for picture")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }
      
      self?.storage.child("images/\(fileName)").downloadURL { (url, error) in
        guard let url = url else {
          print("failed to get download url")
          completion(.failure(StorageErrors.failedToGetDownloadUrl))
          return
        }
        
        let urlString = url.absoluteString
        print("download url returned: \(urlString)")
        completion(.success(urlString))
      }
    }
  }
  
  public enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadUrl
  }
  
  public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
    let reference = storage.child(path)
    
    reference.downloadURL { (url, error) in
      guard let url = url, error == nil else {
        completion(.failure(StorageErrors.failedToGetDownloadUrl))
        return
      }
      
      completion(.success(url))
    }
  }
  
  /// Uploads image that will be sent in a conversation message
  public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadMediaCompletion) {
    storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] (metadata, error) in
      guard error == nil else {
        // failed
        print("failed to upload data to firebase for picture")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }
      
      self?.storage.child("message_images/\(fileName)").downloadURL { (url, error) in
        guard let url = url else {
          print("failed to get download url")
          completion(.failure(StorageErrors.failedToGetDownloadUrl))
          return
        }
        
        let urlString = url.absoluteString
        print("download url returned: \(urlString)")
        completion(.success(urlString))
      }
    }
  }
  
  /// Uploads video that will be sent in a conversation
  public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadMediaCompletion) {
    storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil) { [weak self] (metadata, error) in
      guard error == nil else {
        // failed
        print("failed to upload video file to firebase for picture")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }
      
      self?.storage.child("message_videos/\(fileName)").downloadURL { (url, error) in
        guard let url = url else {
          print("failed to get download url")
          completion(.failure(StorageErrors.failedToGetDownloadUrl))
          return
        }
        
        let urlString = url.absoluteString
        print("download url returned: \(urlString)")
        completion(.success(urlString))
      }
    }
  }
}
