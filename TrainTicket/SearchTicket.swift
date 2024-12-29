//
//  SearchTicket.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 15/12/2024.
//

import Foundation
import UIKit

extension SearchTicket: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 140)
    }
}
class SearchTicket: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Screen width.
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return result.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        posClickCell = indexPath.row
        performSegue(withIdentifier: "toDetailSchedule", sender: self)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath as IndexPath) as! MyCollectionViewCell
        
        cell.startName.text = nameStart
        cell.endName.text = nameStop
        cell.startTime.text = "\(self.result[indexPath.row].departureTime)"
        if let acc = self.result[indexPath.row].arrivalTime {
            cell.endTime.text = "\(acc)"
        } else {
            cell.endTime.text = ""
        }
       
        cell.backgroundColor = UIColor.cyan
        
        return cell
    }
    
    func convertDateToString(date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var posClickCell = 0
    var nameStart: String = ""
    
    var nameStop: String = ""
    
    var stationCodeStart: String = ""
    
    var stationCodeStop: String = ""
    
    var timeStart: String = ""
    
    var result: Welcome = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("6️⃣\(stationCodeStart)")
        print("6️⃣\(stationCodeStop)")
        print("6️⃣\(timeStart)")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.backItem?.title = "Quay lại"
        
//
//        let nib = UINib(nibName: "MyCollectionViewCell", bundle: .main)
//        uiCollectionView.register()
        uiCollectionView.delegate = self
        uiCollectionView.dataSource = self
        let nib = UINib(nibName: "MyCollectionViewCell", bundle: .main)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "cell1")
        // Define the URL for the request
        let urlString = "http://192.168.0.102:8080/schedules/search?startStation=\(stationCodeStart)&endStation=\(stationCodeStop)&startTime=2024-11-18T00:00:00Z"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        // Create the URLRequest with the proper HTTP method and header
        var request = URLRequest(url: url)
        request.httpMethod = "GET"  // The HTTP method for your request
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Perform the API request using URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Handle the response
            if let data = data {
                do {
                    // Decode the JSON response to Welcome array
                    let decoder = JSONDecoder()
                    
                    // Đảm bảo rằng JSON có định dạng đúng với định dạng thời gian
                    decoder.dateDecodingStrategy = .iso8601 // Đặt chiến lược giải mã ngày giờ theo định dạng ISO 8601
                    
                    // Chuyển đổi dữ liệu thành mảng Welcome
                    let welcomeArray = try decoder.decode(Welcome.self, from: data)
                    self.result = welcomeArray
                    DispatchQueue.main.async {
                        self.uiCollectionView.reloadData()
                    }
                   
                    // In kết quả ra console
                    print("Response: \(welcomeArray)")
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }

        // Đừng quên gọi task.resume() để bắt đầu task
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailSchedule {
            vc.dataSchedule = self.result[posClickCell]
        }
    }
    
}
    
