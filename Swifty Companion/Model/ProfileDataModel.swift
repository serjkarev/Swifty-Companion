//
//  ProfileDataModel.swift
//  Swifty Companion
//
//  Created by MacBook Pro on 8/12/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileDataModel {

    var imagrURL: String = ""
    var name: String = ""
    var login: String = ""
    var location: String = ""
    var level: Double = 0.0
    var evaluationPoints: Int = 0
    var wallet: Int = 0
    var grade: String = ""
    var email: String = ""
    var coalitionCoverURL: String = ""
    var backgroundColor: UIColor? = nil
    var skills: [JSON] = []
    var projects: [JSON] = []
}
