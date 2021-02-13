//
//  UserData.swift
//  Tuner
//
//  Created by John Watson on 2/12/21.
//
import SwiftUI

class UserData: ObservableObject {
       
    @AppStorage(wrappedValue: 0, "sessionNumber") var sessionNumber: Int
}
