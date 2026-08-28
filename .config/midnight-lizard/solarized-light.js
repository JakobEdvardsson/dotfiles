const scheme = {
  backgroundContrast: 6,
  backgroundGrayHue: 44,
  backgroundGraySaturation: 87,
  backgroundHueGravity: 100,
  backgroundImageLightnessLimit: 100,
  backgroundImageSaturationLimit: 100,
  backgroundLightnessLimit: 94,
  backgroundReplaceAllHues: true,
  backgroundSaturationLimit: 87,

  blueFilter: 0,

  borderContrast: 30,
  borderGrayHue: 180,
  borderGraySaturation: 7,
  borderHueGravity: 100,
  borderLightnessLimit: 60,
  borderReplaceAllHues: true,
  borderSaturationLimit: 7,

  buttonContrast: 6,
  buttonGrayHue: 46,
  buttonGraySaturation: 42,
  buttonHueGravity: 100,
  buttonLightnessLimit: 88,
  buttonReplaceAllHues: true,
  buttonSaturationLimit: 42,

  colorSchemeId: "solarizedLight",
  colorSchemeName: "Solarized Light",

  doNotInvertContent: false,
  excludeMatches: "*://chatgpt.com/*\n*://claude.ai/*\n*://*.neo4j.io/*\n*://*.slack.com/*\n*://*.neo4j-dev.io/*\n*://cdn.oaistatic.com/*",

  hideBigBackgroundImages: false,
  imageLightnessLimit: 100,
  imageSaturationLimit: 100,
  includeMatches: "",
  isEnabled: true,

  linkContrast: 45,
  linkDefaultHue: 205,
  linkDefaultSaturation: 69,
  linkHueGravity: 100,
  linkLightnessLimit: 49,
  linkReplaceAllHues: true,
  linkSaturationLimit: 69,
  linkVisitedHue: 237,

  maxBackgroundImageSize: 500,
  mode: "auto",
  modeAutoSwitchLimit: 5000,
  runOnThisSite: true,

  scheduleFinishHour: 24,
  scheduleStartHour: 0,

  scrollbarContrast: 0,
  scrollbarGrayHue: 180,
  scrollbarLightnessLimit: 60,
  scrollbarSaturationLimit: 7,
  scrollbarSize: 10,
  scrollbarStyle: true,

  textContrast: 52,
  textGrayHue: 196,
  textGraySaturation: 13,
  textHueGravity: 0,
  textLightnessLimit: 45,
  textReplaceAllHues: false,
  textSaturationLimit: 90,
  textSelectionHue: 44,

  useDefaultSchedule: true,
  useImageHoverAnimation: false
};

const stored = await chrome.storage.sync.get("userColorSchemeIds");
const ids = stored.userColorSchemeIds || [];

await chrome.storage.sync.set({
  "cs:solarizedLight": scheme,
  userColorSchemeIds: [...new Set([...ids, "solarizedLight"])]
});

console.log("Solarized Light installed");
