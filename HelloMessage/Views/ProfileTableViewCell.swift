//
//  ProfileTableViewCell.swift
//  HelloMessage
//
//  Created by Wesley Osborne on 4/10/21.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
  
  static let identifier = "ProfileTableViewCell"
  
  public func setUp(with viewModel: ProfileViewModel) {
    self.textLabel?.text = viewModel.title
    switch viewModel.viewModelType {
    case .info:
      self.textLabel?.textAlignment = .left
      self.selectionStyle = .none
    case .logout:
      self.textLabel?.textColor = .red
      self.textLabel?.textAlignment = .center
    }
  }
}
