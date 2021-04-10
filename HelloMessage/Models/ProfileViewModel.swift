//
//  ProfileViewModel.swift
//  HelloMessage
//
//  Created by Wesley Osborne on 4/10/21.
//

import Foundation

enum ProfileViewModelType {
  case info, logout
}

struct ProfileViewModel {
  let viewModelType: ProfileViewModelType
  let title: String
  let handler: (() -> Void)?
}
