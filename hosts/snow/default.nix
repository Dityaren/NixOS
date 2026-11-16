{ self, inputs, ... }: {
  flake.nixosConfigurations.snow = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      vars = self.vars;
    };

    modules = [
      self.nixosModules.hostConfiguration
      self.nixosModules.nixSettings
    ];
  };
}
