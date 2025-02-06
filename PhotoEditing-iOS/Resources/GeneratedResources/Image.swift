
import SwiftUI


// swiftlint:disable superfluous_disable_command
// swiftlint:disable identifier_name line_length nesting type_body_length type_name file_length
public enum Img {

    public enum Icons {

        public enum Checkbox {
            public static var checkmark: Image {
                Image("Checkmark")
            }
        }

        public enum ProfileView {
            public static var icHomeFill: Image {
                Image("ic_home_fill")
            }
            public static var icPalm: Image {
                Image("ic_palm")
            }
            public static var icPlane: Image {
                Image("ic_plane")
            }
            public static var icThanks: Image {
                Image("ic_thanks")
            }
            public static var icVirus: Image {
                Image("ic_virus")
            }
            public static var sparksBg: Image {
                Image("sparks_bg")
            }
        }

        public enum Tabbar {
            public static var documents: Image {
                Image("Documents")
            }
            public static var news: Image {
                Image("News")
            }
            public static var profile: Image {
                Image("Profile")
            }
            public static var services: Image {
                Image("Services")
            }
        }

        public enum DsIcons {
            public static var icArrowRight: Image {
                Image("ic_arrow_right")
            }
            public static var icAt: Image {
                Image("ic_at")
            }
            public static var icCaseFill: Image {
                Image("ic_case_fill")
            }
            public static var icClock: Image {
                Image("ic_clock")
            }
            public static var icCoins: Image {
                Image("ic_coins")
            }
            public static var icCopy: Image {
                Image("ic_copy")
            }
            public static var icCross: Image {
                Image("ic_cross")
            }
            public static var icGift: Image {
                Image("ic_gift")
            }
            public static var icMailBorder: Image {
                Image("ic_mail_border")
            }
            public static var icPhone: Image {
                Image("ic_phone")
            }
            public static var icPin: Image {
                Image("ic_pin")
            }
            public static var icTg: Image {
                Image("ic_tg")
            }
        }
    }

    private static func image(named name: String) -> Image {
        let bundle = Bundle(for: BundleToken.self)
        let image = Image(name, bundle: bundle)
        return image
    }
}

private final class BundleToken {}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name file_length
