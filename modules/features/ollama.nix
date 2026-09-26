{ pkgs, ... }:

{
  flake.nixosModules.ollama =
    {
      vars,
      pkgs,
      ...
    }:
    {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
        loadModels = [
          "qwen2.5-coder:1.5b-base-q4_K_M"
        ];
      };

    };
}
