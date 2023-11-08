// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Common
import Shared
import ComponentLibrary

final class FakespotReliabilityScoreView: UIView, Notifiable, ThemeApplicable {
    private struct UX {
        static let cornerRadius: CGFloat = 4
        static let ratingLetterFontSize: CGFloat = 13
        static let ratingSize: CGFloat = 24
        static let maxRatingSize: CGFloat = 58
    }

    var notificationCenter: NotificationProtocol = NotificationCenter.default

    public var grade: ReliabilityGrade {
        didSet {
            reliabilityLetterLabel.text = grade.rawValue
            reliabilityLetterLabel.accessibilityLabel = String(format: .Shopping.ReliabilityScoreGradeA11yLabel,
                                                               grade.rawValue)
        }
    }

    private lazy var reliabilityLetterView: UIView = .build()

    private lazy var reliabilityLetterLabel: UILabel = .build { label in
        label.adjustsFontForContentSizeCategory = true
        label.font = DefaultDynamicFontHelper.preferredFont(withTextStyle: .body,
                                                            size: UX.ratingLetterFontSize,
                                                            weight: .semibold)
    }

    private var ratingHeightConstraint: NSLayoutConstraint?
    private var ratingWidthConstraint: NSLayoutConstraint?

    init(grade: ReliabilityGrade) {
        self.grade = grade
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupNotifications(forObserver: self,
                           observing: [.DynamicFontChanged])
        setupLayout()
        setupView()
        reliabilityLetterLabel.text = grade.rawValue
        reliabilityLetterLabel.accessibilityLabel = String(format: .Shopping.ReliabilityScoreGradeA11yLabel,
                                                           grade.rawValue)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        let size = min(UIFontMetrics.default.scaledValue(for: UX.ratingSize), UX.maxRatingSize)
        ratingHeightConstraint = heightAnchor.constraint(equalToConstant: size)
        ratingHeightConstraint?.isActive = true

        ratingWidthConstraint = widthAnchor.constraint(equalToConstant: size)
        ratingWidthConstraint?.isActive = true

        addSubview(reliabilityLetterView)
        reliabilityLetterView.addSubview(reliabilityLetterLabel)

        NSLayoutConstraint.activate([
            reliabilityLetterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            reliabilityLetterView.topAnchor.constraint(equalTo: topAnchor),
            reliabilityLetterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            reliabilityLetterView.bottomAnchor.constraint(equalTo: bottomAnchor),

            reliabilityLetterLabel.centerXAnchor.constraint(equalTo: reliabilityLetterView.centerXAnchor),
            reliabilityLetterLabel.centerYAnchor.constraint(equalTo: reliabilityLetterView.centerYAnchor)
        ])
        adjustLayout()
    }

    private func setupView() {
        layer.cornerRadius = UX.cornerRadius
        layer.borderWidth = 1
        clipsToBounds = true
        layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
    }

    private func adjustLayout() {
        ratingHeightConstraint?.constant = min(UIFontMetrics.default.scaledValue(for: UX.ratingSize), UX.maxRatingSize)
        ratingWidthConstraint?.constant = min(UIFontMetrics.default.scaledValue(for: UX.ratingSize), UX.maxRatingSize)

        setNeedsLayout()
        layoutIfNeeded()
    }

    func handleNotifications(_ notification: Notification) {
        switch notification.name {
        case .DynamicFontChanged:
            adjustLayout()
        default: break
        }
    }

    func applyTheme(theme: Theme) {
        reliabilityLetterView.layer.backgroundColor = grade.color(theme: theme).cgColor
        reliabilityLetterLabel.textColor = theme.colors.textOnLight
    }
}
