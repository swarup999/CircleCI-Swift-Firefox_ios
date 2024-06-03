// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI
import Common
import Shared
import Storage

// MARK: - AddressListView

/// A view displaying a list of addresses.
struct AddressListView: View {
    // MARK: - Properties

    let windowUUID: WindowUUID
    @Environment(\.themeManager)
    var themeManager
    @ObservedObject var viewModel: AddressListViewModel
    @State private var customLightGray: Color = .clear

    // MARK: - Body

    var body: some View {
        List {
            if viewModel.showSection {
                Section(header: Text(String.Addresses.Settings.SavedAddressesSectionTitle)) {
                    ForEach(viewModel.addresses, id: \.self) { address in
                        AddressCellView(
                            windowUUID: windowUUID,
                            address: address,
                            onTap: {
                                if viewModel.isEditingFeatureEnabled {
                                    viewModel.addressTapped(address)
                                }
                            }
                        )
                    }
                }
                .font(.caption)
                .foregroundColor(customLightGray)
            }
        }
        .listStyle(.plain)
        .listRowInsets(EdgeInsets())
        .sheet(item: $viewModel.destination) { destination in
            NavigationView {
                switch destination {
                case .add:
                    NavigationView {
                        EditAddressViewControllerRepresentable(model: viewModel)
                            .navigationBarTitle(String.Addresses.Settings.Edit.AutofillAddAddressTitle, displayMode: .inline)
                            .navigationBarItems(
                                leading: Button(String.Addresses.Settings.Edit.CloseNavBarButtonLabel) {
                                    viewModel.cancelAddButtonTap()
                                },
                                trailing: Button(String.Addresses.Settings.Edit.AutofillSaveButton) {
                                    viewModel.saveAddressTap()
                                }
                            )
                    }

                case .edit:
                    EditAddressViewControllerRepresentable(model: viewModel)
                        .toolbar {
                            ToolbarItemGroup(placement: .cancellationAction) {
                                Button(String.Addresses.Settings.Edit.AutofillCancelButton) {
                                    viewModel.cancelEditButtonTap()
                                }
                            }
                        }
                }
            }
        }
        .onAppear {
            viewModel.fetchAddresses()
            applyTheme(theme: themeManager.currentTheme(for: windowUUID))
        }
        .onReceive(NotificationCenter.default.publisher(for: .ThemeDidChange)) { notification in
            guard let uuid = notification.windowUUID, uuid == windowUUID else { return }
            applyTheme(theme: themeManager.currentTheme(for: windowUUID))
        }
    }

    // MARK: - Theme Application

    /// Applies the theme to the view.
    /// - Parameter theme: The theme to be applied.
    func applyTheme(theme: Theme) {
        let color = theme.colors
        customLightGray = Color(color.textSecondary)
    }
}
