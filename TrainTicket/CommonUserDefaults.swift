//
//  CommonUserDefaults.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 02/12/2024.
//

import Foundation

class CommonUserDefaults {
    
    static let shared = CommonUserDefaults()
    
    private let defaults = UserDefaults.standard
    
    private init() {} // Đảm bảo Singleton
    
    /// Lưu dữ liệu vào UserDefaults
    /// - Parameters:
    ///   - value: Dữ liệu cần lưu (phải tuân theo Codable)
    ///   - key: Key để lưu trữ
    func save<T: Codable>(value: T, forKey key: String) {
        do {
            let jsonData = try JSONEncoder().encode(value)
            defaults.set(jsonData, forKey: key)
            print("Data saved successfully for key: \(key)")
        } catch {
            print("Error saving data for key \(key): \(error)")
        }
    }
    
    /// Lấy dữ liệu từ UserDefaults
    /// - Parameters:
    ///   - key: Key để truy xuất dữ liệu
    ///   - type: Kiểu dữ liệu cần lấy (phải tuân theo Codable)
    /// - Returns: Giá trị tương ứng với key hoặc nil nếu không tìm thấy
    func get<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let jsonData = defaults.data(forKey: key) else {
            print("No data found for key: \(key)")
            return nil
        }
        do {
            let value = try JSONDecoder().decode(T.self, from: jsonData)
            return value
        } catch {
            print("Error decoding data for key \(key): \(error)")
            return nil
        }
    }
    
    /// Xóa dữ liệu trong UserDefaults
    /// - Parameter key: Key cần xóa
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
        print("Data removed for key: \(key)")
    }
    
    /// Kiểm tra xem key có tồn tại trong UserDefaults hay không
    /// - Parameter key: Key cần kiểm tra
    /// - Returns: `true` nếu key tồn tại, `false` nếu không
    func exists(forKey key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
}
