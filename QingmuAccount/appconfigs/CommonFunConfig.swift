//
//  CommonFunConfig.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/29.
//

import Foundation
import UIKit

func keyFeedback(_ index:Int = 1) {
    var feedbackStyke:UIImpactFeedbackGenerator.FeedbackStyle = .heavy
    if(index == 0) {
        feedbackStyke = .soft
    }
    let generator = UIImpactFeedbackGenerator(style: feedbackStyke)
    generator.impactOccurred(intensity: 1.0)
}
