//
//  InfoViewController.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 02/12/2024.
//

import Foundation
import UIKit
class InfoViewController: UIViewController {
    @IBOutlet weak var tvName: UILabel!
    @IBOutlet weak var tvMail: UILabel!
    @IBOutlet weak var tvPhone: UILabel!
    @IBOutlet weak var tvAddress: UILabel!
    @IBOutlet weak var tvGender: UILabel!
    @IBOutlet weak var tvDob: UILabel!
    @IBAction func logoutFunc(_ sender: Any) {
        logoutAndRedirectToLogin()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
    }
    
    
    
    private func getInfo() {
        if let info = CommonUserDefaults.shared.get(forKey: "currentCustomer", type: Customer.self) {
            tvName.text = "\(info.fname) \(info.lname)"
            tvMail.text = "Email: \(info.mailid)"
            tvPhone.text = "SĐT: \(info.phno)"
            tvAddress.text = "Địa chỉ: \(info.addr)"
            tvGender.text = "Giới tính: \(info.gender)"
            tvDob.text = "Ngày sinh: \(info.dob)"
        }
    }
    func logoutAndRedirectToLogin() {
        // Xóa thông tin user
        CommonUserDefaults.shared.remove(forKey: "currentCustomer")
        
        // Lấy Scene hiện tại
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.delegate as? SceneDelegate else {
            print("No active scene found.")
            return
        }
        
        // Điều hướng tới màn hình Login
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("LoginViewController not found in Main.storyboard")
        }
        
        window.window?.rootViewController = loginViewController
        window.window?.makeKeyAndVisible()
    }
}
