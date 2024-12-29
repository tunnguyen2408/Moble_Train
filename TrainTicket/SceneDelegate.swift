//
//  SceneDelegate.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 28/11/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Tạo cửa sổ
        let window = UIWindow(windowScene: windowScene)
        
        // Kiểm tra nếu có thông tin `currentCustomer`
        if let _ = CommonUserDefaults.shared.get(forKey: "currentCustomer", type: Customer.self) {
            // Điều hướng tới Home
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController") as? UITabBarController else {
                fatalError("HomeTabBarController not found in Home.storyboard")
            }
            window.rootViewController = tabBarController
        } else {
            // Nếu không có, điều hướng tới màn hình Login
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
                fatalError("LoginViewController not found in Main.storyboard")
            }
            window.rootViewController = loginViewController
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

