{ ... }:

{
  flake.nixosModules.audio = { pkgs, ... }: {
    security.rtkit.enable = true;

    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    environment.systemPackages = with pkgs; [
      alsa-utils
      pavucontrol
      pwvucontrol
      pulseaudio
      pipewire
      wireplumber
      playerctl
    ];
  };
}
