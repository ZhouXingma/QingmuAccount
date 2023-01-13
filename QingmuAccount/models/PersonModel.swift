//
//  PersonModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/29.
//
import SwiftUI
import Combine

class PersonModel: ObservableObject {
    @Published var personViewType: PersonViewType = .MAIN
    
    public func changePesonViewType(_ type:PersonViewType) {
        withAnimation(.easeInOut) {
            personViewType = type
        }
    }
}
