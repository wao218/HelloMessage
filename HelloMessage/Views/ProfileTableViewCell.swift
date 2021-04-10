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
    textLabel?.text = viewModel.title
    switch viewModel.viewModelType {
    case .info:
      textLabel?.textAlignment = .left
      selectionStyle = .none
    case .logout:
      textLabel?.textColor = .red
      textLabel?.textAlignment = .center
    }
  }
}
