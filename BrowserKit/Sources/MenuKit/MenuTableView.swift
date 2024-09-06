// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

class MenuTableView: UIView, UITableViewDataSource, UITableViewDelegate {
    // Declare the table view as a property of the container view
    private let tableView: UITableView
    private var dataSource: [[MenuElement]] = []

    override init(frame: CGRect) {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        setupTableView()
    }

    private func setupTableView() {
        self.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        tableView.register(
            MenuCell.self,
            forCellReuseIdentifier: MenuCell.cellIdentifier
        )

        tableView.dataSource = self
        tableView.delegate = self
    }

    func updateDataSource(_ newDataSource: [[MenuElement]]) {
        self.dataSource = newDataSource
        tableView.reloadData()
    }
    // MARK: - UITableViewDataSource Methods
    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return dataSource.count
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return dataSource[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MenuCell.cellIdentifier,
            for: indexPath
        ) as! MenuCell

        cell.configureCellWith(model: dataSource[indexPath.section][indexPath.row])

        return cell
    }

    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at index: \(indexPath.section)-\(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}