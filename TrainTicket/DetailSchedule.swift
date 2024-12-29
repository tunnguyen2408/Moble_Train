//
//  Chi tiết lịch trình.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 17/12/2024.
//

import Foundation
import UIKit

class DetailSchedule: UIViewController {
    
    @IBOutlet weak var timeEnd: UILabel!
    @IBOutlet weak var detailTrain: UILabel!
    @IBOutlet weak var listSchedule: UILabel!
    @IBOutlet weak var typeTrain: UILabel!
    @IBOutlet weak var nameTrain: UILabel!
    @IBOutlet weak var numberChair: UILabel!
    @IBOutlet weak var timeStart: UILabel!
    
    
    @IBOutlet weak var buy: UIButton!
    private let baseURL = "http://localhost:8080"

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChoseTicketViewController {
            vc.dataSchedule = dataSchedule
        }
    }
    
    @IBAction func clickBuy(_ sender: Any) {
        performSegue(withIdentifier: "toSelectTicket", sender: self)
        
    }
    var dataSchedule: WelcomeElement? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("😗 \(dataSchedule)")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.backItem?.title = "Quay lại"
        fetchRouteDetails(routeId: dataSchedule?.routeID ?? 0)
        fetchTrainById(trainId: dataSchedule?.trNo ?? 0)
        timeStart.text = "Xuất phát: \(convertDateToString(date: dataSchedule?.departureTime ?? Date()))"
        timeEnd.text = "Kết thúc: \(convertDateToString(date: dataSchedule?.arrivalTime ?? Date()))"
        initButton()
    }
    
    private func initButton() {
        buy.backgroundColor = UIColor(named: "colorMain")
        buy.layer.cornerRadius = 16
        buy.layer.borderWidth = 1
        buy.layer.borderColor = UIColor(named: "colorMain")?.cgColor
        buy.setTitleColor(UIColor.white, for: .normal)
    }
    
    
    func convertDateToString(date: Date, format: String = "yyyy-MM-dd HH:mm:ss", locale: String = "en_US") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
    
    func fetchRouteDetails(routeId: Int) {
        // Tạo URL
        guard let url = URL(string: "http://192.168.0.102:8080/routes/\(routeId)") else {
            print("Invalid URL")
            return
        }
        
        // Tạo URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Thực hiện request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Xử lý lỗi
            if let error = error {
                return
            }
            
            // Kiểm tra phản hồi
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                return
            }
            
            // Parse JSON
            guard let data = data else {
                
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let route = try decoder.decode(RouteData.self, from: data)
                
                
                self.fetchAllStationDetails(from: route.stopStation) { stations in
                    print("Station details:")
                    var points = ""
                    for station in stations {
                        points.append("-> \(station.stationName)")
                        points.append("\n")
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.listSchedule.text = points
                    }
                }
                
            } catch {
                
            }
        }
        
        task.resume()
    }
    
    
    
    func fetchAllStationDetails(from stopStations: String, completion: @escaping ([Station]) -> Void) {
        let stationCodes = stopStations.split(separator: ",").map { String($0) }
        var stations: [Station] = []
        let group = DispatchGroup()
        
        for code in stationCodes {
            group.enter()
            fetchStationDetails(stationCode: code) { result in
                switch result {
                case .success(let station):
                    stations.append(station)
                case .failure(let error):
                    print("Error fetching station \(code): \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(stations)
        }
    }
    
    func fetchStationDetails(stationCode: String, completion: @escaping (Result<Station, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/stations/\(stationCode)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let station = try decoder.decode(Station.self, from: data)
                completion(.success(station))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // Lấy thông tin tàu theo ID
    func fetchTrainById(trainId: Int) {
        guard let url = URL(string: "\(baseURL)/trains/\(trainId)") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                return
            }
            
            do {
                let train = try JSONDecoder().decode(Train.self, from: data)
                DispatchQueue.main.async {
                    self.nameTrain.text = "Tên tàu: \(train.trName)"
                    self.typeTrain.text = "Loại tàu: \(train.trType ?? "")"
                    self.numberChair.text = "Số ghế: \(train.seats)"
                    self.detailTrain.text = "Mô tả: \(train.description ?? "")"
                }
            } catch {
            }
        }
        task.resume()
    }
    
}
