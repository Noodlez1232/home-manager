{ config, lib, pkgs, ... }:
with lib;
let
  cfg = options.programs.bemenu;

  colorsToOptions = colors:
    (mapAttrsToList (name: value: "--${name} '${value}'"));
in
{
  options.programs.bemenu = {
    enable = mkEnableOption = "a dmenu replacement with native wayland support";
    package = mkOption {
      type = types.package;
      default = pkgs.bemenu;
      defaultText = literalExpression "pkgs.bemenu";
      description = "Package providing {command}`i3blocks`";
    };

    defaultOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "-l 10" "-c" ];
      description = "Extra command line options given to bemenu by default";
    };
    forceBackend = mkOption {
      type = with types; nullOr (enum [ "curses", "wayland", "x11" ]);
      default = null;
      example = "wayland";
      description = "Force a backend when running bemenu";
    };
    forceScale = mkOption {
      type = with types; nullOr (oneOf [ int float ]);
      default = null;
      example = 2;
      description = "Force a specific scaling factor";
    };
    colors = mkOption {
      type = with types; attrsOf str;
      default = { };
      example = literalExpression ''
        {
          "tb" = "#000000";
          "tf" = "#FFFFFF";
        }
      '';
      description = "Colors added to BEMENU_OPTS";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.sessionVariables = mapAttrs (n: v: toString v)
      # Filter out any null or empty attributes
      (filterAttrs (n: v: v != [] && v != null) {
        BEMENU_OPTS = concatStringSep " " ((colorsToOptions cfg.colors) ++ cfg.defaultOptions);
        BEMENU_BACKEND = cfg.forceBackend;
        BEMENU_SCALE = cfg.forceScale;
      });
  };
}
