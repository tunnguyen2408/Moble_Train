//
//  ViewController.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 28/11/2024.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var container: UIView!
    @IBOutlet weak var edtPassword: UITextField!
    @IBOutlet weak var edtEmail: UITextField!
    
    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var buttonLogin: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
//        self.container.addGestureRecognizer(gesture)
        self.hideKeyboardWhenTappedAround()
        initButton()
        initButton1()
        edtEmail.text = "bob.jones@example.com"
        edtPassword.text = "bobpass"
        

    }
    
    private func initButton() {
        buttonLogin.backgroundColor = UIColor(named: "colorMain")
        buttonLogin.layer.cornerRadius = 16
        buttonLogin.layer.borderWidth = 1
        buttonLogin.layer.borderColor = UIColor(named: "colorMain")?.cgColor
        buttonLogin.setTitleColor(UIColor.white, for: .normal)
    }
    
    private func initButton1() {
        buttonRegister.backgroundColor = UIColor.white
        buttonRegister.layer.cornerRadius = 16
        buttonRegister.layer.borderWidth = 1
        buttonRegister.layer.borderColor = UIColor(named: "colorMain")?.cgColor
        buttonRegister.setTitleColor(UIColor(named: "colorMain"), for: .normal)
    }
    
    @IBAction func register(_ sender: Any) {
        self.performSegue(withIdentifier: "yourSegueIdentifier", sender: self)
    }
    @IBAction func login(_ sender: Any) {
        callAPi(textEmail: edtEmail.text, textPassword: edtPassword.text)
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
    }
    
    private func callAPi(textEmail: String?,textPassword: String?) {
        // Prepare the request
        let url = URL(string: "http://localhost:8080/customers/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode the credentials
        let credentials = LoginCredentials(mailid: textEmail ?? "", pword: textPassword ?? "")
        do {
            let jsonData = try JSONEncoder().encode(credentials)
            request.httpBody = jsonData
        } catch {
            print("Error encoding credentials: \(error)")
            return
        }

        // Make the API call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Handle response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("fail")
                return
            }
            
            // Handle data
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    if httpResponse.statusCode == 200 {
                        do {
                            let customer = try JSONDecoder().decode(Customer.self, from: responseString.data(using: .utf8) ?? Data())
                            print("Customer name: \(customer.fname) \(customer.lname)")
                            CommonUserDefaults.shared.save(value: customer, forKey: "currentCustomer")
                            self.navigateToTabBarController()
                            
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    } else {
                        do {
                            let customer = try JSONDecoder().decode(ErrorCommon.self, from: responseString.data(using: .utf8) ?? Data())
                            self.showAlert(title: "Đăng nhập thất bại", message: customer.errorMessage, in: self)
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }
            }
        }

        task.resume()
    }
    
    func showAlert(title: String, message: String, in viewController: UIViewController) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // Thêm nút "OK"
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            // Hiển thị alert
            viewController.present(alert, animated: true, completion: nil)
        })
    }
    
    func navigateToTabBarController() {
        DispatchQueue.main.async(execute: {
            // Tải storyboard "Home"
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            
            // Tạo TabBarController từ Storyboard
            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController") as? UITabBarController else {
                fatalError("HomeTabBarController not found in Home.storyboard")
            }
            
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let window = UIWindow(windowScene: scene)
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
                
                // Gán `window` vào `SceneDelegate`
                if let sceneDelegate = scene.delegate as? SceneDelegate {
                    sceneDelegate.window = window
                }
            }
        })
    }
    
}

