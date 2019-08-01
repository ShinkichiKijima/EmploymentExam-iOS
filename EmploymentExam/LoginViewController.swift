//
//  LoginViewController.swift
//  EmploymentExam
//
//  Created by Keita Yamamoto on 2019/07/30.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit

/// ログイン画面
class LoginViewController: UIViewController {

    static var accessToken: String?

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    /// ログインボタンタップ時の処理
    @IBAction func onTapLoginButton(_ sender: Any) {
        guard let url = URL(string: "https://apidemo.altonotes.co.jp/login") else {
            return
        }

        let parmeter = "userName=\(userNameTextField.text ?? "")&password=\(passwordTextField.text ?? "")"

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parmeter.data(using: .utf8)
        URLSession.shared.dataTask(with: request as URLRequest) {[weak self] data, resp, error in
            DispatchQueue.main.async {
                self?.indicator.stopAnimating()
            }

            let statusCode = (resp as? HTTPURLResponse)?.statusCode
            if statusCode != 200 {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: "ステータスコードエラーが発生しました。[\(statusCode ?? 0)]", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                }
            }

            guard let data = data else {
                return
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                LoginViewController.accessToken = jsonObject?["accessToken"] as? String

                let result = jsonObject?["result"] as? String
                var message: String

                if result == "0" {
                    message = "ログインに成功しました。"
                } else if result == "1" {
                    message = "ユーザーネームまたはパスワードに誤りがあります。"
                } else {
                    message = jsonObject?["message"] as? String ?? ""
                }

                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
        indicator.startAnimating()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
