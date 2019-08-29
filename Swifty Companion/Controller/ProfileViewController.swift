//
//  ProfileViewController.swift
//  Swifty Companion
//
//  Created by MacBook Pro on 8/12/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var profileData = ProfileDataModel()
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var loginLable: UILabel!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var corectionLable: UILabel!
    @IBOutlet weak var walletLable: UILabel!
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var coalitionImageView: UIImageView!
    @IBOutlet weak var gradeLable: UILabel!
    @IBOutlet weak var levelLable: UILabel!
    @IBOutlet weak var levelProgressBar: UIView!
    @IBOutlet weak var skillTableView: UITableView!
    @IBOutlet weak var projectTableView: UITableView!
    
    @IBOutlet weak var evalInscription: UILabel!
    @IBOutlet weak var walletInscription: UILabel!
    @IBOutlet weak var gradeInscription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skillTableView.delegate = self
        projectTableView.delegate = self
        skillTableView.dataSource = self
        projectTableView.dataSource = self
        skillTableView.allowsSelection = false
        projectTableView.allowsSelection = false
        loadUserData()
        loadCoalitionData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 1
        switch tableView {
        case skillTableView:
            numberOfRow = profileData.skills.count
        case projectTableView:
            numberOfRow = profileData.projects.count
        default:
            print("Error : Some problem in numberOfRowInSection")
        }
        return numberOfRow
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case skillTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "skillCell", for: indexPath) as! SkillCell
            cell.skillNameLabel.text = profileData.skills[indexPath.row]["name"].string!
            cell.skillLevelLabel.text = String(format: "%.02f", profileData.skills[indexPath.row]["level"].double!)
            return cell
        case projectTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectCell
            if let projectName = profileData.projects[indexPath.row]["project"]["name"].string {
                cell.projectNameLabel.text = projectName
            }
            if let status = profileData.projects[indexPath.row]["status"].string {
                if status == "finished" {
                    if let finalMark = profileData.projects[indexPath.row]["final_mark"].int{
                        if finalMark >= 60{
                            cell.projectGrade.text = "✓" + String(finalMark)
                            cell.projectGrade.textColor = UIColor(displayP3Red: 0.365, green: 0.575, blue: 0.321, alpha: 1)
                        }else{
                            cell.projectGrade.text = "╳" + String(finalMark)
                            cell.projectGrade.textColor = UIColor(displayP3Red: 0.791, green: 0.415, blue: 0.443, alpha: 1)
                        }
                    }
                }else if status == "in_progress" || status == "searching_a_group"{
                    cell.projectGrade.text = "🕓"
                }
            }
            return cell
        default:
            print("Error : Some problem in cellForRowAt indexPath")
            return UITableViewCell()
        }
    }
    
    @IBAction func goBackButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func loadUserData(){
        loadImage(url: profileData.imagrURL, imageView: userImageView)
        nameLable.text = profileData.name
        loginLable.text = profileData.login
        locationLable.text = profileData.location
        levelLable.text = "Level \(profileData.level)"
        corectionLable.text = "\(profileData.evaluationPoints)"
        walletLable.text = "\(profileData.wallet) ₳"
        gradeLable.text = profileData.grade
        campusLabel.text = profileData.campus
        emailLable.text = profileData.email
        if profileData.backgroundColor != nil {
            evalInscription.textColor = profileData.backgroundColor
            walletInscription.textColor = profileData.backgroundColor
            gradeInscription.textColor = profileData.backgroundColor
            campusLabel.textColor = profileData.backgroundColor
            emailLable.textColor = profileData.backgroundColor
        }
    }
    
    func loadCoalitionData(){
        let level = profileData.level
        if profileData.backgroundColor != nil{
            levelProgressBar.backgroundColor = profileData.backgroundColor
        }
        levelProgressBar.frame.size.width = view.frame.size.width / 100 * CGFloat(Int(level*100) % 100)
        loadImage(url: profileData.coalitionCoverURL, imageView: coalitionImageView)
    }
    
    func loadImage(url: String, imageView: UIImageView){
        if let imageURL = URL(string: url){
            let data = try? Data(contentsOf: imageURL)
            if let imageData = data{
                let image = UIImage(data: imageData)
                imageView.image = image
            }
        }
    }
    
}

class SkillCell: UITableViewCell{
    
    @IBOutlet weak var skillNameLabel: UILabel!
    @IBOutlet weak var skillLevelLabel: UILabel!
}

class ProjectCell: UITableViewCell{
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var projectGrade: UILabel!
}
