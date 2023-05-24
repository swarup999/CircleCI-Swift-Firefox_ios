// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit
import Storage
import Shared
import SiteImageView

/// This ViewController is meant to show a tableView of STG items in a flat list with NO section headers.
/// When we have coordinators, where the coordinator provides the VM to the VC, we can generalize this.
class SearchGroupedItemsViewController: UIViewController {
    // MARK: - Properties

    typealias a11y = AccessibilityIdentifiers.LibraryPanels.GroupedList

    enum Sections: CaseIterable {
        case main
    }

    let profile: Profile
    let viewModel: SearchGroupedItemsViewModel
    var libraryPanelDelegate: LibraryPanelDelegate? // Set this at the creation site!
    private var themeManager: ThemeManager
    private var logger: Logger

    lazy private var tableView: UITableView = .build { [weak self] tableView in
        guard let self = self else { return }
        tableView.dataSource = self.diffableDatasource
        tableView.accessibilityIdentifier = a11y.tableView
        tableView.delegate = self
        tableView.register(OneLineTableViewCell.self, forCellReuseIdentifier: OneLineTableViewCell.cellIdentifier)
        tableView.register(TwoLineImageOverlayCell.self, forCellReuseIdentifier: TwoLineImageOverlayCell.cellIdentifier)

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    fileprivate lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: String.AppSettingsDone, style: .done, target: self, action: #selector(doneButtonAction))
        button.accessibilityIdentifier = "ShowGroupDoneButton"
        return button
    }()

    private var diffableDatasource: UITableViewDiffableDataSource<Sections, AnyHashable>?

    // MARK: - Inits

    init(viewModel: SearchGroupedItemsViewModel,
         profile: Profile,
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         logger: Logger = DefaultLogger.shared) {
        self.viewModel = viewModel
        self.profile = profile
        self.themeManager = themeManager
        self.logger = logger

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        configureDatasource()
        setupNotifications()
        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applySnapshot()
    }

    // MARK: - Misc. helpers

    private func setupLayout() {
        // This View needs to be configured a certain way based on who's presenting it.
        switch viewModel.presenter {
        case .recentlyVisited:
            title = viewModel.asGroup.displayTitle
            navigationItem.rightBarButtonItem = doneButton
        default: break
        }

        // Adding subviews and constraints
        view.addSubviews(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    // MARK: - TableView datasource helpers

    private func configureDatasource() {
        diffableDatasource = UITableViewDiffableDataSource<Sections, AnyHashable>(tableView: tableView) { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }

            if let site = item as? Site {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TwoLineImageOverlayCell.cellIdentifier,
                                                               for: indexPath) as? TwoLineImageOverlayCell
                else {
                    self.logger.log("GeneralizedHistoryItems - Could not dequeue a TwoLineImageOverlayCell",
                                    level: .debug,
                                    category: .library)
                    return nil
                }

                cell.titleLabel.text = site.title
                cell.titleLabel.isHidden = site.title.isEmpty
                cell.descriptionLabel.text = site.url
                cell.descriptionLabel.isHidden = false
                cell.leftImageView.layer.borderColor = self.themeManager.currentTheme.colors.layer4.cgColor
                cell.leftImageView.layer.borderWidth = 0.5
                cell.leftImageView.setFavicon(FaviconImageViewModel(siteURLString: site.url))

                return cell
            }

            // This shouldn't happen! An empty row!
            return UITableViewCell()
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Sections, AnyHashable>()

        snapshot.appendSections(Sections.allCases)

        snapshot.appendItems(viewModel.asGroup.groupedItems, toSection: .main)

        diffableDatasource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Misc. helpers

    private func setupNotifications() {
        viewModel.notifications.forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotifications), name: $0, object: nil)
        }
    }

    @objc
    private func handleNotifications(_ notification: Notification) {
        switch notification.name {
        case .DisplayThemeChanged:
            applyTheme()
        default:
            break
        }
    }

    @objc
    private func doneButtonAction() {
        dismiss(animated: true, completion: nil)
    }
}

extension SearchGroupedItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffableDatasource?.itemIdentifier(for: indexPath) else { return }

        if let site = item as? Site {
            handleSiteItemTapped(site: site)
        }
    }

    private func handleSiteItemTapped(site: Site) {
        guard let url = URL(string: site.url) else {
            logger.log("Couldn't navigate to site",
                       level: .warning,
                       category: .library)
            return
        }

        libraryPanelDelegate?.libraryPanel(didSelectURL: url, visitType: .typed)

        TelemetryWrapper.recordEvent(category: .action,
                                     method: .tap,
                                     object: .selectedHistoryItem,
                                     value: .historyPanelGroupedItem,
                                     extras: nil)

        if viewModel.presenter == .recentlyVisited {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension SearchGroupedItemsViewController: NotificationThemeable {
    func applyTheme() {
        let theme = BuiltinThemeName(rawValue: LegacyThemeManager.instance.current.name) ?? .normal
        if theme == .dark {
            tableView.backgroundColor = UIColor.legacyTheme.homePanel.panelBackground
        } else {
            tableView.backgroundColor = UIColor.legacyTheme.homePanel.panelBackground
        }

        view.backgroundColor = .systemBackground
        tableView.separatorColor = themeManager.currentTheme.colors.borderPrimary

        tableView.reloadData()
    }
}
