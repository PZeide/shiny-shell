self: {modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/qemu-vm.nix")
    self.nixosModules.greeter
  ];

  networking.hostName = "greeter-dev";

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  virtualisation = {
    diskSize = 10 * 1024;
    memorySize = 2 * 1024;
    cores = 2;
  };

  users.users.dev = {
    enable = true;
    initialPassword = "wife";
    createHome = true;
    isNormalUser = true;
    extraGroups = ["wheel"];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.shiny-shell-greeter = {
    enable = true;
    user = "dev";
    session = "hyprland";
  };

  system.stateVersion = "25.11";
}
