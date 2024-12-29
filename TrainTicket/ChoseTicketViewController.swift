//
//  ChoseTicketViewController.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 17/12/2024.
//

import Foundation
import UIKit

extension ChoseTicketViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 70)
    }
}

class ChoseTicketViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var dataSchedule: WelcomeElement? = nil
    
    var stationsStart: [Station] = []
    
    var stationsEnd: [Station] = []
    
    var dataPrice: [Price] = []
    
    var posChoose = 0
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataPrice.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.posChoose = indexPath.row
        showAlert()
    }
    
    func showAlert() {
        // Tạo UIAlertController
        let alertController = UIAlertController(title: "Thông Báo", message: "Xác nhận đặt vé", preferredStyle: .alert)
        
        // Tạo Button "Cancel"
        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel) { _ in
            print("User tapped Cancel")
        }
        
        // Tạo Button "OK"
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("User tapped OK")
            let user = CommonUserDefaults.shared.get(forKey: "currentCustomer", type: Customer.self)
            let acc = self.dataPrice[self.posChoose]
            let ticket = Ticket(trNo: self.dataSchedule?.trNo ?? 0,
                                schedule: self.dataSchedule?.routeID ?? 0,
                                mailid: user?.mailid ?? "",
                                typeID: acc.typeID,
                                seatNumber: "A1",
                                bookingDate: Date(),
                                status: "Đã đặt",
                                price: acc.fare)
            self.createTicket(ticket: ticket) { result in
                switch result {
                case .success(let createdTicket):
                    DispatchQueue.main.async {
                        alertController.dismiss(animated: true)
                        self.showTicketBookingSuccessAlert()
                    }
                case .failure(let error):
                    print("Error creating ticket: \(error)")
                }
            }
        }
        
        // Thêm các action vào alertController
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        // Hiển thị alert
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showTicketBookingSuccessAlert() {
        // Tạo UIAlertController
        let alertController = UIAlertController(
            title: "Đặt vé thành công",
            message: "Chúc mừng bạn đã đặt vé thành công!",
            preferredStyle: .alert
        )
        
        // Tạo hành động cho nút "OK"
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Khi người dùng nhấn OK, quay về trang chủ
            self.navigateToHomePage()
        }
        
        // Thêm hành động vào alert
        alertController.addAction(okAction)
        
        // Hiển thị alert
        self.present(alertController, animated: true, completion: nil)
    }

    // Hàm chuyển về trang chủ
    func navigateToHomePage() {
        // Giả sử bạn đang sử dụng UINavigationController để điều hướng
        if let navigationController = self.navigationController {
            // Điều hướng về trang chủ (giả sử trang chủ là view controller đầu tiên trong stack)
            navigationController.popToRootViewController(animated: true)
        } else {
            // Nếu không sử dụng UINavigationController, bạn có thể dùng cách khác để chuyển màn hình
            // Ví dụ: Dùng present hoặc dismiss view controller
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func createTicket(ticket: Ticket, completion: @escaping (Result<String, Error>) -> Void) {
        // URL của API
        let url = URL(string: "http://192.168.0.102:8080/tickets")!
        
        // Chuyển đổi Ticket object thành JSON
        do {
            let jsonData = try JSONEncoder().encode(ticket)
            
            // Tạo request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            // Gửi request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "DataError", code: 0, userInfo: nil)))
                    return
                }
                
                // Giải mã dữ liệu JSON trả về từ server
                do {
                    completion(.success("success"))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
            
        } catch {
            completion(.failure(error))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath as IndexPath) as! TicketCell
        let datac = dataPrice[indexPath.row]
        
        fetchTicketType(by: datac.typeID) { valueType, err in
            if let valueType = valueType {
                DispatchQueue.main.async {
                    cell.ticketType.text = "Loại vé: \(valueType.typeName)"
                }
            }
        }
       
        
        let intValue = Int(datac.fare) // Kết quả: 266032
        print(intValue)
        
        cell.ticketPrice.text = "\(intValue).000 VNĐ"
       
        cell.backgroundColor = UIColor.cyan
        
        return cell
    }
    
    func fetchTicketType(by id: Int, completion: @escaping (TicketType?, Error?) -> Void) {
        // Tạo URL cho API với tham số id
        guard let url = URL(string: "http://192.168.0.102:8080/ticket-types/\(id)") else {
            completion(nil, NSError(domain: "InvalidURL", code: -1, userInfo: nil))
            return
        }

        // Tạo URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Tạo và bắt đầu URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            // Kiểm tra mã trạng thái HTTP
            guard let data = data else {
                completion(nil, NSError(domain: "NoData", code: -1, userInfo: nil))
                return
            }

            // Giải mã dữ liệu JSON thành object TicketType
            do {
                let decoder = JSONDecoder()
                let ticketType = try decoder.decode(TicketType.self, from: data)
                completion(ticketType, nil)
            } catch let decodingError {
                completion(nil, decodingError)
            }
        }

        // Bắt đầu task
        task.resume()
    }
    
    
    @IBOutlet weak var listTicket: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        listTicket.delegate = self
        listTicket.dataSource = self
        let nib = UINib(nibName: "TicketCell", bundle: .main)
        listTicket.register(nib, forCellWithReuseIdentifier: "cell2")
        callAPiGetTicket()
        
    }
    
    func callAPiGetTicket() {
        // Tạo URL từ chuỗi
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Đảm bảo UTC
        let isoDateString = isoFormatter.string(from: dataSchedule!.departureTime)
        
        guard let url = URL(string: "http://192.168.0.102:8080/price/schedule?trNo=\(dataSchedule?.trNo ?? 0)&routeId=\(dataSchedule?.routeID ?? 0)&stationCode=\(dataSchedule?.stationCode ?? "")&departureTime=\( isoDateString ?? "")&startLat=\(HomeViewController.stationStart?.latitude ?? 1)&startLon=\(HomeViewController.stationStart?.longitude ?? 1)&endLat=\(HomeViewController.stationStop?.latitude ?? 1)&endLon=\(HomeViewController.stationStop?.longitude ?? 1)") else {
            print("Invalid URL")
            return
        }

        // Tạo request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")

        // Sử dụng URLSession để gửi yêu cầu
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Kiểm tra lỗi
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            // Kiểm tra phản hồi HTTP
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Code: \(httpResponse.statusCode)")
            }

            // Xử lý dữ liệu trả về
            if let data = data {
                do {
                    // Parse JSON trả về

//                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
//                    print("Response JSON: \(jsonResponse)")
                    let prices = try JSONDecoder().decode([Price].self, from: data)
                    self.dataPrice = prices
                    DispatchQueue.main.async {
                        self.listTicket.reloadData()
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        }

        // Bắt đầu gửi request
        task.resume()
    }
}
    
