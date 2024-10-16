// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

/// Holds the cases that the browser coordinator can navigate to
/// This type exists as a field on the BrowserViewControllerState
enum BrowserNavigationDestination {
    case customizeHomepage
    case link
}

struct NavigationDestination: Equatable {
    let destination: BrowserNavigationDestination
    let urlToVisit: URL?

    init(
        _ destination: BrowserNavigationDestination,
        urlToVisit: URL? = nil
    ) {
        self.destination = destination
        self.urlToVisit = urlToVisit
    }
}
