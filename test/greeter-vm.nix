{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  networking.hostName = "greeter-test";

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  virtualisation = {
    diskSize = 10 * 1024;
    memorySize = 2 * 1024;
    cores = 2;
  };

  users.users.thibaud = {
    enable = true;
    initialPassword = "invoke_wife";
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
  };

  system.stateVersion = "25.11";
}
