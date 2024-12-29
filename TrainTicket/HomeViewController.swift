//
//  File.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 02/12/2024.
//

import Foundation
import UIKit
import DropDown
class HomeViewController: UIViewController {
    @IBOutlet weak var tvEmail: UILabel!
    @IBOutlet weak var edtTimeStart: UITextField!
    @IBOutlet weak var edtStop: UITextField!
    @IBOutlet weak var iconPerson: UIImageView!
    @IBOutlet weak var edtStart: UITextField!
    
    @IBOutlet weak var btnSearch: UIButton!
    var stations: [Station] = []
    
    var stationNames: [String] = []
    
    var stationCodeStart = ""
    
    var stationCodeStop = ""
    
    let dropDownStart = DropDown()
    
    let dropDownStop = DropDown()
    static var stationStart: Station? = nil
    static var stationStop: Station? = nil
    
    // Tạo UIDatePicker
    var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButton()
        getInfo()
        callGetStations()
        initClick()
        initDropDown()
        initDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func initButton() {
        btnSearch.backgroundColor = UIColor(named: "colorMain")
        btnSearch.layer.cornerRadius = 16
        btnSearch.layer.borderWidth = 1
        btnSearch.layer.borderColor = UIColor(named: "colorMain")?.cgColor
        btnSearch.setTitleColor(UIColor.white, for: .normal)
    }
    
    private func initDatePicker() {
        // Khởi tạo UIDatePicker
        datePicker = UIDatePicker()
        
        // Chỉ sử dụng chế độ ngày (không có giờ)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline  // Dạng compact cho giao diện đẹp
        
        // Đặt DatePicker làm input view cho UITextField
        edtTimeStart.inputView = datePicker
        
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
        edtTimeStart.inputAccessoryView = toolBar
        
        datePicker.minimumDate = Date()  // Giới hạn ngày chọn từ hiện tại trở đi
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) // Giới hạn ngày đến 1 năm sau
        
    }
    
    // Xử lý sự kiện khi người dùng nhấn nút Done
    @objc func doneButtonTapped() {
        // Định dạng ngày theo định dạng chỉ có ngày
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Gán giá trị ngày đã chọn vào UITextField
        edtTimeStart.text = dateFormatter.string(from: datePicker.date)
        
        // Ẩn DatePicker khi Done được nhấn
        edtTimeStart.resignFirstResponder()
    }
    
    // Xử lý sự kiện khi người dùng nhấn nút Cancel
    @objc func cancelButtonTapped() {
        // Ẩn DatePicker khi Cancel được nhấn
        edtTimeStart.resignFirstResponder()
    }
    
    private func initDropDown() {
        dropDownStart.anchorView = edtStart // UIView or UIBarButtonItem
        
        dropDownStart.dataSource = stationNames
        
        dropDownStart.direction = .any
        
        dropDownStart.width = 200
        
        // Action triggered on selection
        dropDownStart.selectionAction = { [unowned self] (index: Int, item: String) in
            edtStart.text = item
            HomeViewController.stationStart = stations[index]
            stationCodeStart = stations[index].stationCode
            print("Selected item: \(item) at index: \(index)")
        }
        
        
        dropDownStop.anchorView = edtStop // UIView or UIBarButtonItem
        
        dropDownStop.dataSource = stationNames
        
        dropDownStop.direction = .any
        
        dropDownStop.width = 200
        
        // Action triggered on selection
        dropDownStop.selectionAction = { [unowned self] (index: Int, item: String) in
            edtStop.text = item
            HomeViewController.stationStop = stations[index]
            stationCodeStop = stations[index].stationCode
            print("Selected item: \(item) at index: \(index)")
        }
        
        
        DropDown.startListeningToKeyboard()
    }
    
    private func initClick() {
        edtStart.isUserInteractionEnabled = true
        
        edtStop.isUserInteractionEnabled = true
        
        
        // Gắn UITapGestureRecognizer cho edtTimeStart
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleStartTap))
        edtStart.addGestureRecognizer(tapGesture1)
        
        // Gắn UITapGestureRecognizer cho edtStop
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleStopTap))
        edtStop.addGestureRecognizer(tapGesture2)
    }
    
    @objc func handleStartTap() {
        dropDownStart.show()
        print("edtTimeStart was tapped")
        // Hiển thị DatePicker hoặc thực hiện một hành động khác
    }
    
    @objc func handleStopTap() {
        dropDownStop.show()
        print("edtStop was tapped")
        // Thực hiện một hành động khác
    }
    
    private func getInfo() {
        if let info = CommonUserDefaults.shared.get(forKey: "currentCustomer", type: Customer.self) {
            tvEmail.text = "\(info.fname) \(info.lname)"
        }
    }
    
    @IBAction func searchTicket(_ sender: Any) {
        performSegue(withIdentifier: "toResultSearch", sender: self)

//        self.present(searchController, animated: true, completion: nil)
//        navigationController?.pushViewController(searchController, animated: true)
        print("edtTimeStart was tapped")
        
    }
    
    private func callGetStations() {
        guard let url = URL(string: "http://192.168.0.102:8080/stations") else {
            print("Invalid URL")
            return
        }
        
        // Tạo yêu cầu
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Hoặc "POST" nếu cần
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Gửi yêu cầu
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Parse JSON trả về
            do {
                let stations = try JSONDecoder().decode([Station].self, from: data)
                self.stations = stations
                for station in stations {
                    self.stationNames.append(station.stationName)
                }
                
                self.initDropDown()
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        
        // Bắt đầu task
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SearchTicket {
            vc.stationCodeStart = stationCodeStart
            vc.stationCodeStop = stationCodeStop
            vc.nameStop = edtStop.text ?? ""
            vc.nameStart = edtStart.text ?? ""
            vc.timeStart = "\(edtTimeStart.text)T00:00:00Z"
        }
    }
}
