// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

/// The source of a favicon or hero image.
public enum SiteResource {
    /// An image that may be downloaded over the network.
    /// - Parameter url: The URL of the image.
    case remoteURL(url: URL)
    /// An image bundled in the app in a .xcassets library.
    /// - Parameter name: The name of the image.
    case bundleAsset(name: String)
}
