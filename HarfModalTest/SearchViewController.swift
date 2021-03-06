//
//  SearchViewController.swift
//  HarfModalTest
//
//  Created by 服部　翼 on 2019/09/17.
//  Copyright © 2019 服部　翼. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.placeholder = "Search for a place or address"
        hideHeader()
        let grabbleHandleView = GrabberHandleView()
        view.addSubview(grabbleHandleView)
        layoutGrabberHandle(grabberView: grabbleHandleView)
        
    }
    
    func showHeader() {
        changeHeader(height: 116.0)
    }
    
    func hideHeader() {
        changeHeader(height: 0.0)
    }
    
    
    private func changeHeader(height: CGFloat) {
        tableView.beginUpdates()
        if let headerView = tableView.tableHeaderView {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self = self else {return}
                var frame = headerView.frame
                frame.size.height = height
                self.tableView.tableHeaderView?.frame = frame
            }
        }
        tableView.endUpdates()
    }
    
    private func layoutGrabberHandle(grabberView: GrabberHandleView) {
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        grabberView.topAnchor.constraint(equalTo: view.topAnchor, constant: 6.0).isActive = true
        grabberView.heightAnchor.constraint(equalToConstant: grabberView.frame.height).isActive = true
        grabberView.widthAnchor.constraint(equalToConstant: grabberView.frame.width).isActive = true
        grabberView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0).isActive = true
    }


}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "東京タワー"
            return cell
        case 1:
            cell.textLabel?.text = "０件"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}
