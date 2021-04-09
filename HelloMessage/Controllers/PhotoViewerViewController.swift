//
//  PhotoViewerViewController.swift
//  HelloMessage
//
//  Created by Wesley Osborne on 4/2/21.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {
  
  // MARK: - UI Elements
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  // MARK: - Initializers
  private let url: URL
  
  init(with url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Photo"
    navigationItem.largeTitleDisplayMode = .never
    view.backgroundColor = .black
    view.addSubview(imageView)
    imageView.sd_setImage(with: self.url, completed: nil)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    imageView.frame = view.bounds
  }
}
