/// How built-in Retro Pixel sprite art was authored.
enum RetroPixelSpriteSource {
  /// Hand-drawn native 64×64 grid.
  native64,

  /// Legacy 32×32 (from 16×16 upscale) or catalog art upscaled to 48+.
  legacyUpscaled,

  /// Generated from templates/recolors in the animal catalog.
  catalogGenerated,
}
