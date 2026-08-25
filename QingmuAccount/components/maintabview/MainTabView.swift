//
//  MainTabView.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/30.
//

import SwiftUI

struct MainTabView : View {
    var body: some View {
        VStack {
            MainTabViewRepresentable()
        }
    }
}

struct MainTabViewRepresentable : UIViewRepresentable {
    typealias UIViewType = UIScrollView
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollview = UIScrollView()
        // 设置背景颜色
        scrollview.backgroundColor = UIColor.yellow
        // 设置代理
        scrollview.delegate = context.coordinator
        return scrollview
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        
    }
    
    func makeCoordinator() -> MainTabViewCoordinator {
        MainTabViewCoordinator(self)
    }
    
    class MainTabViewCoordinator : NSObject,UIScrollViewDelegate {
        var mainTabViewRepresentable: MainTabViewRepresentable
        
        init(_ mainTabViewRepresentable: MainTabViewRepresentable) {
            self.mainTabViewRepresentable = mainTabViewRepresentable
        }
        
        
    }
    
   
    
    
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView().preferredColorScheme(.light)
    }
}
