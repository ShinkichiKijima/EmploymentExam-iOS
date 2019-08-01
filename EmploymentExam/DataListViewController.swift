//
//  DataListViewController.swift
//  EmploymentExam
//
//  Created by Keita Yamamoto on 2019/07/30.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit

/// データ表示画面
class DataListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var items: [[String: String]]?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }

    func requestData() {
        guard let url = URL(string: "https://test.altonotes.co.jp/data") else {
            return
        }

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if let accessToken = LoginViewController.accessToken {
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request as URLRequest) { [weak self] data, resp, error in
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
                self?.items = jsonObject?["items"] as? [[String: String]]
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

extension DataListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        if let item = items?[indexPath.row] {
            let code = item["code"] ?? ""
            let name = item["name"] ?? ""
            cell.textLabel?.text = "[\(code)] \(name)"
        }

        return cell
    }
}
