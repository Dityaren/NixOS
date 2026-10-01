{ pkgs, ... }:

{
  flake.nixosModules.ollama =
    {
      vars,
      pkgs,
      ...
    }:
    {
      services = {
        ollama = {
          enable = true;
          package = pkgs.ollama-cuda;
          loadModels = [
            "qwen2.5-coder:1.5b-base-q4_K_M"
            "qwen2.5-coder:1.5b"
            "qwen3:4b"
          ];
        };

        open-webui = {
          enable = true;
          host = "127.0.0.1";
          port = 8080; # Default port
          environment = {
            OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
            OLLAMA_BASE_URL = "http://127.0.0.1:11434";
            ANONYMIZED_TELEMETRY = "False";
            DO_NOT_TRACK = "True";
            SCARF_NO_ANALYTICS = "True";
          };
        };

      };

    };
}
