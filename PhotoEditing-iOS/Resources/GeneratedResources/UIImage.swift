
import UIKit.UIImage


// swiftlint:disable superfluous_disable_command
// swiftlint:disable identifier_name line_length nesting type_body_length type_name file_length
public enum UIImg {

    public enum Icons {

        public enum Checkbox {
            public static var checkmark: UIImage {
                image(named: "Checkmark")
            }
        }

        public enum ProfileView {
            public static var icHomeFill: UIImage {
                image(named: "ic_home_fill")
            }
            public static var icPalm: UIImage {
                image(named: "ic_palm")
            }
            public static var icPlane: UIImage {
                image(named: "ic_plane")
            }
            public static var icThanks: UIImage {
                image(named: "ic_thanks")
            }
            public static var icVirus: UIImage {
                image(named: "ic_virus")
            }
            public static var sparksBg: UIImage {
                image(named: "sparks_bg")
            }
        }

        public enum Tabbar {
            public static var documents: UIImage {
                image(named: "Documents")
            }
            public static var news: UIImage {
                image(named: "News")
            }
            public static var profile: UIImage {
                image(named: "Profile")
            }
            public static var services: UIImage {
                image(named: "Services")
            }
        }

        public enum DsIcons {
            public static var icArrowRight: UIImage {
                image(named: "ic_arrow_right")
            }
            public static var icAt: UIImage {
                image(named: "ic_at")
            }
            public static var icCaseFill: UIImage {
                image(named: "ic_case_fill")
            }
            public static var icClock: UIImage {
                image(named: "ic_clock")
            }
            public static var icCoins: UIImage {
                image(named: "ic_coins")
            }
            public static var icCopy: UIImage {
                image(named: "ic_copy")
            }
            public static var icCross: UIImage {
                image(named: "ic_cross")
            }
            public static var icGift: UIImage {
                image(named: "ic_gift")
            }
            public static var icMailBorder: UIImage {
                image(named: "ic_mail_border")
            }
            public static var icPhone: UIImage {
                image(named: "ic_phone")
            }
            public static var icPin: UIImage {
                image(named: "ic_pin")
            }
            public static var icTg: UIImage {
                image(named: "ic_tg")
            }
        }
    }

    private static func image(named name: String) -> UIImage {
        let bundle = Bundle(for: BundleToken.self)
        guard let image = UIImage(named: name, in: bundle, compatibleWith: nil) else {
            fatalError("Unable to load image named \(name).")
        }
        return image
    }
}

private final class BundleToken {}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name file_length
