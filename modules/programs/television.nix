{
  lib,
  pkgs,
  config,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };
  cfg = config.programs.television;
in
{
  meta.maintainers = [ lib.maintainers.awwpotato ];

  options.programs.television = {
    enable = lib.mkEnableOption "television";
    package = lib.mkPackageOption pkgs "television" { nullable = true; };
    settings = lib.mkOption {
      type = tomlFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          tick_rate = 50;
          ui = {
            use_nerd_font_icons = true;
            ui_scale = 120;
            show_preview_panel = false;
          };
          keybindings = {
            quit = [ "esc" "ctrl-c" ];
          };
        }
      '';
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/television/config.toml`.
        See <https://github.com/alexpasmantier/television/blob/main/.config/config.toml>
        for the full list of options.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile."television/config.toml" = lib.mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "config.toml" cfg.settings;
    };
  };
}
