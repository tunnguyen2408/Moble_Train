//
//  RegisterController.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 03/01/2025.
//

import UIKit
import DropDown

class RegisterController: UIViewController {
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputHo: UITextField!
    @IBOutlet weak var inputTen: UITextField!
    @IBOutlet weak var inputGender: UITextField!
    @IBOutlet weak var inputAddress: UITextField!
    @IBOutlet weak var inputDob: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var back: UIImageView!
    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var inputPhone: UITextField!
    
    
    let dropDownGender = DropDown()
    // Tạo UIDatePicker
    var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        back.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        back.addGestureRecognizer(tapGesture)
        initButton()
        initClick()
        initDatePicker()
        dropDownGender.anchorView = inputGender // UIView or UIBarButtonItem
        
        dropDownGender.dataSource = ["Nam", "Nữ"]
        
        dropDownGender.direction = .any
        
        dropDownGender.width = 200
        
        // Action triggered on selection
        dropDownGender.selectionAction = { [unowned self] (index: Int, item: String) in
            inputGender.text = item
        }
    }
    
    
    private func initDatePicker() {
        // Khởi tạo UIDatePicker
        datePicker = UIDatePicker()
        
        // Chỉ sử dụng chế độ ngày (không có giờ)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline  // Dạng compact cho giao diện đẹp
        
        // Đặt DatePicker làm input view cho UITextField
        inputDob.inputView = datePicker
        
        // Tạo toolbar với các nút Done và Cancel
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // Nút Cancel
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        // Nút Done
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        // Đặt các nút vào toolbar
        toolBar.setItems([cancelButton, doneButton], animated: false)
        
        // Đặt toolbar vào inputAccessoryView của UITextField
        inputDob.inputAccessoryView = toolBar
        
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) // Giới hạn ngày đến 1 năm sau
        
    }
    
    @objc func doneButtonTapped() {
        // Định dạng ngày theo định dạng chỉ có ngày
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Gán giá trị ngày đã chọn vào UITextField
        inputDob.text = dateFormatter.string(from: datePicker.date)
        
        // Ẩn DatePicker khi Done được nhấn
        inputDob.resignFirstResponder()
    }
    
    // Xử lý sự kiện khi người dùng nhấn nút Cancel
    @objc func cancelButtonTapped() {
        // Ẩn DatePicker khi Cancel được nhấn
        inputDob.resignFirstResponder()
    }
    
    
    private func initClick() {
        inputGender.isUserInteractionEnabled = true
        inputDob.isUserInteractionEnabled = true
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleStartGender))
        inputGender.addGestureRecognizer(tapGesture1)
    }
    
    
    @objc func handleStartGender() {
        dropDownGender.show()
    }
    
    
    private func initButton() {
        buttonRegister.backgroundColor = UIColor(named: "colorMain")
        buttonRegister.layer.cornerRadius = 16
        buttonRegister.layer.borderWidth = 1
        buttonRegister.layer.borderColor = UIColor(named: "colorMain")?.cgColor
        buttonRegister.setTitleColor(UIColor.white, for: .normal)
    }
    
    @IBAction func handleRegister(_ sender: Any) {
        
        guard let email = inputEmail.text, !email.isEmpty,
                  let password = inputPassword.text, !password.isEmpty,
                  let firstName = inputTen.text, !firstName.isEmpty,
                  let lastName = inputHo.text, !lastName.isEmpty,
                  let address = inputAddress.text, !address.isEmpty,
                  let phone = inputPhone.text, !phone.isEmpty,
                  let dob = inputDob.text, !dob.isEmpty,
                  let gender = inputGender.text, !gender.isEmpty else {
                // Show an error if any field is empty
                return
            }
            
            // Prepare the JSON data
            let parameters: [String: Any] = [
                "mailid": email,
                "pword": password,
                "fname": firstName,
                "lname": lastName,
                "addr": address,
                "phno": phone,
                "dob": dob,
                "gender": gender
            ]
            
            guard let url = URL(string: "http://localhost:8080/customers") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Set the HTTP body with the JSON data
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print("Error creating JSON: \(error)")
                return
            }
            
            // Create a data task to send the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Request error: \(error)")
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    // Handle successful registration
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Đăng ký thành công", message: "Quay lại trang đăng nhập", preferredStyle: .alert)
                        
                        // Thêm nút "OK"
                        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                            self.dismiss(animated: true)
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true)
                    }
                } else {
                    // Handle failure (e.g., show error message)
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Đăng ký thất bại", message: "Thông tin bạn nhập không hợp lệ", preferredStyle: .alert)
                        
                        // Thêm nút "OK"
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true)

                    }
                }
            }
            
            // Start the data task
            task.resume()
        
    }
    
    @objc func imageTapped() {
        self.dismiss(animated: true)
    }
}
