import 'package:flutter/material.dart';

/// Static design palette used by `unified_fields` for default field chrome
/// (label color, hint color, borders, sheets) and for several semantic accents
/// that internal widgets reuse (validation red, "actions" pink, etc.).
///
/// Most consumers should override colors via [UnifiedInputDecoration],
/// [UnifiedInputPalette], or a wrapping [Theme] rather than reading from this
/// class directly — these tokens are kept public mainly because the unified
/// inputs themselves reference them at default-style positions.
class UnifiedColors {
  UnifiedColors._();

  /// Default brand primary.
  static const primaryColor = Color.fromRGBO(50, 118, 177, 1);

  /// Dark variant of [primaryColor].
  static const primaryColorDark = Color(0xff312D2A);

  /// Secondary accent.
  static const secondaryColor = Color(0xFFF2C94C);

  /// Light scaffold background.
  static const scaffoldBackgroundColor = Color(0xFFF5F7FA);

  /// Dark scaffold background.
  static const scaffoldBackgroundColorDark = Color(0xff312D2A);

  /// Default surface for cards.
  static const cardColor = Colors.white;

  /// Default divider color.
  static const dividerColor = Color.fromRGBO(62, 57, 52, 1);

  /// Body text on light surfaces.
  static const textColor = Color(0xFF333333);

  /// Body text on dark / tinted surfaces (also used by field labels).
  static const textColorDark = Color(0xFFE3DACF);

  /// Disabled variant of [textColorDark].
  static const textColorDarkDisable = Color.fromRGBO(227, 218, 207, 0.16);

  /// Soft neutral used for "unreached" steps / progress.
  static const unreached = Color.fromRGBO(120, 114, 108, 1);

  /// Border for unselected list items / chips.
  static const unSelectedBorder = Color.fromRGBO(61, 59, 58, 1);

  /// Hint / placeholder text color.
  static const hintColor = Color(0xFF736E6B);

  /// Headline text color.
  static const headlineColor = Color(0xFF1A1A1A);

  /// Subhead text color.
  static const subheadColor = Color(0xFF666666);

  /// Default disabled control color.
  static final disabledColor = Colors.grey.shade400;

  /// Light border.
  static const borderColor = Color(0xFFE0E0E0);

  /// Lighter border variant.
  static const borderColor1 = Color(0xFFE9E9E9);

  /// Darker border variant.
  static const borderColor2 = Color(0xFF6C6C6C);

  /// Default error color.
  static const errorColor = Color(0xFFB00020);

  /// AppBar background tint.
  static const appBarBackground = Color(0xFF6094E7);

  /// Foreground accent.
  static const foregroundColor = Color(0xFF5A6F8A);

  /// Background used by inline "flight" widgets in the design system.
  static const flightWidgetBackgroundColor = Color(0xFFFFFCFC);

  /// Action / primary call-to-action pink.
  static const actions = Color(0xffFF3B7C);

  /// Deep slate blue tone.
  static const darkSlateBlue = Color(0xff133159);

  /// Slate blue tone.
  static const slateBlue = Color(0xff5f7b98);

  /// Scaffold background variant.
  static const scaffoldBg = Color(0xfff2f3f6);

  /// Header background for scaffolds with sticky headers.
  static const scaffoldHeader = Color(0xffeaecf2);

  /// Generic 12% black overlay.
  static const shade = Color.fromRGBO(0, 0, 0, 0.12);

  /// Light grey background.
  static const greyBG = Color(0xffF0F0F1);

  /// Muted grey text.
  static const greyText = Color(0xff858A99);

  /// White variant.
  static const white1 = Color.fromRGBO(245, 245, 245, 1);

  /// White variant.
  static const white2 = Color.fromRGBO(250, 250, 250, 1);

  /// White variant.
  static const white3 = Color.fromRGBO(255, 255, 255, 1);

  /// White variant.
  static const white4 = Color.fromRGBO(250, 250, 250, 1);

  /// White variant.
  static const white5 = Color.fromRGBO(247, 247, 247, 1);

  /// White variant.
  static const white6 = Color.fromRGBO(237, 237, 237, 1);

  /// Black variant.
  static const black1 = Color.fromRGBO(52, 52, 52, 1);

  /// Black variant.
  static const black2 = Color(0xFF0a1a3a);

  /// Deep neutral background.
  static const blackBack = Color.fromRGBO(37, 34, 32, 1);

  /// Default black tone.
  static const black = Color.fromRGBO(59, 59, 59, 1);

  /// "Not important" muted grey.
  static const notImportant = Color(0xffb9b9b9);

  /// Disabled overlay.
  static const disable = Color.fromRGBO(245, 245, 245, 0.5);

  /// Black with 80% opacity.
  static const black3 = Color.fromRGBO(59, 59, 59, 0.8);

  /// 7% black overlay.
  static const black7 = Color.fromRGBO(0, 0, 0, 0.07);

  /// 8% black overlay.
  static const black8 = Color.fromRGBO(0, 0, 0, 0.08);

  /// 12% black overlay.
  static const black12 = Color.fromRGBO(0, 0, 0, 0.12);

  /// 24% black overlay.
  static const black24 = Color.fromRGBO(0, 0, 0, 0.24);

  /// Teal / blue-green accent.
  static const blueGreen = Color.fromRGBO(20, 122, 137, 1);

  /// Print-blue accent.
  static const printBlue = Colors.blueAccent;

  /// Adobe-warm-orange brand accent.
  static const adobe = Color.fromRGBO(186, 112, 72, 1);

  /// Olive accent.
  static const oliveDrab = Color.fromRGBO(111, 108, 46, 1);

  /// Pale grey variant.
  static const paleGrey2 = Color.fromRGBO(247, 248, 255, 1);

  /// Pale grey variant.
  static const paleGrey = Color.fromRGBO(226, 240, 237, 1);

  /// Neutral greyish brown.
  static const greyishBrown = Color(0xff484848);

  /// Soft grey-blue accent.
  static const greyBlue = Color.fromRGBO(129, 185, 171, 1);

  /// Pale grey variant.
  static const paleGreyTwo = Color.fromRGBO(239, 249, 255, 1);

  /// Light-ish blue accent.
  static const lightIshBlue = Color.fromRGBO(77, 111, 255, 1);

  /// Very light blue surface.
  static const veryLightBlue = Color.fromRGBO(230, 236, 255, 1);

  /// Light blue accent.
  static const lightBlue = Color.fromRGBO(142, 219, 230, 1);

  /// Light blue-grey divider.
  static const lightBlueGrey = Color(0xffcbd1d8);

  /// Light green surface.
  static const lightGreen = Color(0xffdce6e3);

  /// Light peach accent.
  static const lightPeach = Color.fromRGBO(255, 204, 177, 1);

  /// Greenish beige accent.
  static const greenishBeige = Color.fromRGBO(208, 204, 114, 1);

  /// Eggshell off-white.
  static const eggshell = Color.fromRGBO(244, 243, 225, 1);

  /// Dull orange accent.
  static const dullOrange = Color.fromRGBO(217, 152, 65, 1);

  /// Bright orange brand accent.
  static const orange = Color(0xffF57B00);

  /// Pale orange tint.
  static const lightOrange = Color(0xffFFeddc);

  /// Aqua-marine 10% tint.
  static const aquaMarine = Color.fromRGBO(77, 204, 182, 0.1);

  /// Dark mint accent.
  static const darkMint = Color.fromRGBO(72, 192, 162, 1);

  /// Brown grey variant.
  static const brownGrey = Color.fromRGBO(141, 141, 141, 1);

  /// Brown grey variant.
  static const brownGrey2 = Color.fromRGBO(134, 134, 134, 1);

  /// Brown grey variant.
  static const brownGrey3 = Color.fromRGBO(173, 173, 173, 1);

  /// Brown grey variant.
  static const brownGrey4 = Color.fromRGBO(170, 170, 170, 1);

  /// Brown grey variant.
  static const brownGrey5 = Color.fromRGBO(130, 130, 130, 1);

  /// Brown grey variant.
  static const brownGrey6 = Color.fromRGBO(178, 178, 178, 1);

  /// Brown grey variant.
  static const brownGrey7 = Color.fromRGBO(175, 175, 175, 1);

  /// Soft pinkish grey.
  static const pinkishGrey = Color.fromRGBO(206, 206, 206, 1);

  /// Pale grey variant.
  static const paleGreyThree = Color.fromRGBO(241, 244, 255, 1);

  /// Very light red surface.
  static const veryLightRed = Color(0xfffff2f2);

  /// Very light pink surface.
  static const veryLightPink = Color.fromRGBO(237, 237, 237, 1);

  /// Very light pink variant.
  static const veryLightPink2 = Color.fromRGBO(234, 234, 234, 1);

  /// Very light pink variant.
  static const veryLightPink3 = Color.fromRGBO(235, 235, 235, 1);

  /// Very light pink variant.
  static const veryLightPink4 = Color.fromRGBO(242, 242, 242, 1);

  /// Very light pink variant.
  static const veryLightPink5 = Color.fromRGBO(195, 195, 195, 1);

  /// Very light pink variant.
  static const veryLightPink6 = Color.fromRGBO(225, 225, 225, 1);

  /// Very light pink variant.
  static const veryLightPink7 = Color.fromRGBO(255, 238, 237, 1);

  /// Greenish teal accent.
  static const greenishTeal = Color.fromRGBO(46, 198, 157, 1);

  /// Bright green accent.
  static const green = Color.fromRGBO(106, 240, 29, 1);

  /// Mint-green brand accent.
  static const green2 = Color(0xff2fc488);

  /// Green background tint.
  static const greenBg = Color(0xff00c69E);

  /// Macaroni-cheese orange accent.
  static const macAndCheese = Color.fromRGBO(239, 176, 75, 1);

  /// Ocean-green accent.
  static const oceanGreen = Color.fromRGBO(48, 141, 117, 1);

  /// Butterscotch accent.
  static const butterscotch = Color.fromRGBO(239, 176, 75, 1);

  /// Turquoise accent.
  static const turquoise = Color.fromRGBO(10, 195, 159, 1);

  /// Grapefruit accent.
  static const grapefruit = Color.fromRGBO(255, 93, 93, 1);

  /// Red accent.
  static const red = Color(0xffff3f42);

  /// Bright red accent.
  static const shinyRed = Color(0xfffa3030);

  /// Default divider line tint.
  static const lineColor = Color(0xffE1E1E1);

  /// Default grey accent.
  static const mainGrey = Color(0xffABABAB);

  /// 12% line border.
  static const lineBorderColor = Color.fromRGBO(0, 0, 0, 0.12);

  /// Live indicator background tint.
  static const liveBG = Color(0xffF0F1f3);

  /// Faded blue accent.
  static const fadedBlue = Color(0xff7c8ac9);

  /// Dusk-blue accent.
  static const duskBlue = Color(0xff293a84);

  /// Main brand blue.
  static const mainBlue = Color(0xff2A5CFF);

  /// Main brand orange.
  static const mainOrange = Color(0xFFFFa32c);

  /// Main brand red.
  static const mainRed = Color(0xFFFF3f42);

  /// Main brand green.
  static const mainGreen = Color(0xFF08AB7D);

  /// Light periwinkle accent.
  static const lightPeriwinkle = Color(0xffbdcaff);

  /// Ice tint.
  static const ice = Color.fromRGBO(218, 250, 246, 1);

  /// Ice-blue tint.
  static const iceBlue = Color.fromRGBO(248, 255, 253, 1);

  /// Brand pink (Hava primary).
  static const havaPrime = Color.fromRGBO(229, 20, 100, 1);

  /// Brand teal (Hava accent).
  static const havaAccent = Color.fromRGBO(102, 196, 189, 1);

  /// Warm grey accent.
  static const warmGrey = Color.fromRGBO(131, 131, 131, 1);

  /// Adult-passenger accent.
  static const adl = Color.fromRGBO(77, 111, 255, 1);

  /// Infant-passenger accent.
  static const inf = Color.fromRGBO(222, 125, 13, 1);

  /// Child-passenger accent.
  static const chd = Color.fromRGBO(230, 50, 133, 1);

  /// Auto-assigned-seat accent.
  static const autoSeat = Color.fromRGBO(252, 90, 15, 1);

  /// Manually-assigned-seat accent.
  static const manualSeat = Color.fromRGBO(25, 163, 7, 1);

  /// Pax-grey accent.
  static const paxGrey = Color(0xffB9b9b9);

  /// Checked-in green accent.
  static const checkinGreen = Color.fromRGBO(72, 192, 162, 1);

  /// Boarding blue accent.
  static const boardingBlue = Color.fromRGBO(77, 111, 255, 1);

  /// Reserved-seat green tint.
  static const reserveGreen = Color.fromRGBO(176, 255, 223, 1);

  /// Striped row, even row.
  static const evenRow = Color(0xfff8f8f8);

  /// Striped row, odd row.
  static const oddRow = Color(0xffffffff);

  /// Index column accent.
  static const indexColor = Color(0xff3b3b3b);

  /// Travel-document accent (semi-transparent purple).
  static const travelDocColor = Color.fromARGB(100, 200, 100, 250);

  /// Dark red accent.
  static const darkRed = Color.fromRGBO(200, 0, 0, 1.0);

  /// Gradient start (dark theme).
  static const gradientStart = Color(0xff312D2A);

  /// Gradient end (dark theme).
  static const gradientEnd = Color(0xff434039);

  /// Gradient start (light theme).
  static const gradientStartLight = Color(0xffE8D8C4);

  /// Gradient end (light theme).
  static const gradientEndLight = Color(0xffECE5DC);
}
