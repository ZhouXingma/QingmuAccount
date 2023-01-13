//
//  ContentView.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var globalModel:GlobalModel = GlobalModel()
    var body: some View {
        IndexView().environmentObject(globalModel)
            .onAppear() {
                globalModel.darkModeSettings = globalModel.darkModeSettings
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark)
    }
}
