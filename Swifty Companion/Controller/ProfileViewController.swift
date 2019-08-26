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

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchProfileDelegate {

    var profileData = ProfileDataModel()
    var token = ""
    
    let API_URL = "https://api.intra.42.fr/v2/users/"
    var json: JSON = []
    var parameters: [String:String] = [:]
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var loginLable: UILabel!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet weak var corectionLable: UILabel!
    @IBOutlet weak var walletLable: UILabel!
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var coalitionImageView: UIImageView!
    @IBOutlet weak var gradeLable: UILabel!
    @IBOutlet weak var levelLable: UILabel!
    @IBOutlet weak var levelProgressBar: UIView!
    @IBOutlet weak var skillTableView: UITableView!
    @IBOutlet weak var projectTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skillTableView.delegate = self
        projectTableView.delegate = self
        skillTableView.dataSource = self
        projectTableView.dataSource = self
        skillTableView.allowsSelection = false
        projectTableView.allowsSelection = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
//        var cell = UITableViewCell()
        switch tableView {
        case skillTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "skillCell", for: indexPath) as! SkillCell
            cell.textLabel?.text = profileData.skills[indexPath.row]["name"].string!
            cell.skillLevelLabel.text = String(profileData.skills[indexPath.row]["level"].double!)
            return cell
        case projectTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectCell
            cell.textLabel?.text = profileData.projects[indexPath.row]["project"]["name"].string!
            if profileData.projects[indexPath.row]["status"].string! == "finished"{
                cell.projectGrade.text = String(profileData.projects[indexPath.row]["final_mark"].int!)
                if profileData.projects[indexPath.row]["final_mark"] > 60{
                    cell.textLabel?.textColor = UIColor.green
                    cell.projectGrade.textColor = UIColor.green
                }else{
                    cell.textLabel?.textColor = UIColor.red
                    cell.projectGrade.textColor = UIColor.red
                }
            }else if profileData.projects[indexPath.row]["status"].string! == "in_progress"{
                cell.projectGrade.text = "in progress"
                cell.projectGrade.textColor = UIColor.black
                cell.textLabel?.textColor = UIColor.black
            }
            return cell
        default:
            print("Error : Some problem in cellForRowAt indexPath")
            return UITableViewCell()
        }
//        return cell
    }
    
    @IBAction func goBackButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func getUserData(login: String, token: String){
        SVProgressHUD.show()
        self.token = token
        let parameters = ["access_token": token]
        Alamofire.request(API_URL + login, method: .get, parameters: parameters).responseJSON { (responce) in
            if responce.result.isSuccess{
                let userJSON = JSON(responce.result.value!)
                self.updateUserData(json: userJSON)
            }else{
                print("Error \(String(describing: responce.result.error))")
            }
        }
    }
    
    func updateUserData(json: JSON){
        if let imageURL = json["image_url"].string{
            profileData.imagrURL = imageURL
        }
        if let name = json["displayname"].string{
            profileData.name = name
        }
        if let login = json["login"].string{
            profileData.login = login
        }
        if let location = json["location"].string {
            profileData.location = "Available\n" + location
        }else{
            profileData.location = "Unavailable\n - "
        }
        if let level = json["cursus_users"][0]["level"].double{
            profileData.level = level
        }
        if let correction = json["correction_point"].int{
            profileData.evaluationPoints = correction
        }
        if let wallet = json["wallet"].int{
            profileData.wallet = wallet
        }
        if let grade = json["cursus_users"][0]["grade"].string{
            profileData.grade = grade
        }
        if let email = json["email"].string {
            profileData.email = email
        }
        if let skills = json["cursus_users"][0]["skills"].array{
            profileData.skills = skills
        }
        if let projects = json["projects_users"].array{
            profileData.projects = projects
        }
        if let userID = json["languages_users"][0]["user_id"].int {
            getCoalitionData(userID: userID)
        }
        loadUserData()
        SVProgressHUD.dismiss()
    }
    
    func getCoalitionData(userID: Int){
        
        let parameters = ["access_token": token]
        Alamofire.request("https://api.intra.42.fr/v2/users/\(userID)/coalitions", method: .get, parameters: parameters).responseJSON { (responce) in
            if responce.result.isSuccess {
                let coalitionJSON: JSON = JSON(responce.result.value!)
                self.updateCoalitionData(json: coalitionJSON)
            }else{
                print("Error \(String(describing: responce.result.error))")
            }
            DispatchQueue.main.async {
                self.skillTableView.reloadData()
                self.projectTableView.reloadData()
            }
        }
    }
    
    func updateCoalitionData(json: JSON){
        if let cover = json[0]["cover_url"].string{
            profileData.coalitionCoverURL = cover
        }
        if let backgroundColor = json[0]["color"].string{
            profileData.backgroundColor = backgroundColor
            loadCoalitionData()
        }
    }

    func loadUserData(){
        if profileData.login == ""{
            loadEmpty()
        }else{
            loadImage(url: profileData.imagrURL, imageView: userImageView)
            nameLable.text = profileData.name
            loginLable.text = profileData.login
            locationLable.text = profileData.location
            levelLable.text = "Level \(profileData.level)"
            corectionLable.text = "\(profileData.evaluationPoints)"
            walletLable.text = "\(profileData.wallet) ₳"
            gradeLable.text = profileData.grade
            emailLable.text = profileData.email
            
        }
    }
    
    func loadCoalitionData(){
        let level = profileData.level
        levelProgressBar.backgroundColor = UIColor(hex: profileData.backgroundColor)
        levelProgressBar.frame.size.width = view.frame.size.width / 100 * CGFloat(Int(level*100) % 100)
        loadImage(url: profileData.coalitionCoverURL, imageView: coalitionImageView)
    }
    
    func loadEmpty(){
        print("NOT FOUND")
    }
    
    func loadImage(url: String, imageView: UIImageView){
        let imageURL = URL(string: url)
        let data = try? Data(contentsOf: imageURL!)
        if let imageData = data{
            let image = UIImage(data: imageData)
            imageView.image = image
        }
    }
    
    
}

extension UIColor {
    
    // MARK: - Initialization
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

class SkillCell: UITableViewCell{
    
    @IBOutlet weak var skillLevelLabel: UILabel!
}

class ProjectCell: UITableViewCell{
    
    @IBOutlet weak var projectGrade: UILabel!
}
