// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import UIKit

public protocol FaviconImageViewModel {
    var urlStringRequest: String { get }
    var faviconCornerRadius: CGFloat { get }
}

public struct DefaultFaviconImageViewModel: FaviconImageViewModel {
    public let urlStringRequest: String
    public let faviconCornerRadius: CGFloat

    public init(urlStringRequest: String, faviconCornerRadius: CGFloat) {
        self.urlStringRequest = urlStringRequest
        self.faviconCornerRadius = faviconCornerRadius
        self.usesIndirectDomain = usesIndirectDomain
    }
}
