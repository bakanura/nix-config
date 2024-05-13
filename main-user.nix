# main-user.nix

{lib, config, pkgs, ...}:

{
  options = {
    main-user.enable
     = lib.mkEnableOption "eanable user module";

    main-user.userName = lib.mkOption {
      default = "bakanura";
      description = ''
        username
      '';
    };
  };

config = lib.mkIf config.main-user.enable {
  users.users.${config.main-user.userName} = {
    isNormalUser = true;
    initialPassword = "12345";
    description = "baka";
    shell = pkgs.zsh;
    };
  };
}