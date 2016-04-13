import UIKit

public struct Color {
    public static let White = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    public static let Red = UIColor(red: 249.0 / 255.0, green: 70.0 / 255.0, blue: 28.0 / 255.0, alpha: 1.0)
    public static let RedDarkened = UIColor(red: 197.0 / 255.0, green: 55.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)

    public static let Blue = UIColor(red: 0.0 / 255.0, green: 178.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
    public static let BlueDarkened = UIColor(red: 23.0 / 255.0, green: 149.0 / 255.0, blue: 187.0 / 255.0, alpha: 1.0)

    public static let DarkBlue = UIColor(red: 14.0 / 255.0, green: 47.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
    public static let LightBlue = UIColor(red: 199.0 / 255.0, green: 213.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0)

    public static let Green = UIColor(red: 0.0 / 255.0, green: 147.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0)

    public static let Black = UIColor(red: 16.0 / 255.0, green: 24.0 / 255.0, blue: 32.0 / 255.0, alpha: 1.0)

    public static let Gray = UIColor(red: 193.0 / 255.0, green: 202.0 / 255.0, blue: 206.0 / 255.0, alpha: 1.0)
}

struct Theme {
    static func fontOfSize(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "apercu-light", size: fontSize)!
    }

    static func boldFontOfSize(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "apercu-bold", size: fontSize)!
    }

    static func mediumFontOfSize(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "apercu-medium", size: fontSize)!
    }

    static func regularFontOfSize(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "apercu-regular", size: fontSize)!
    }
}