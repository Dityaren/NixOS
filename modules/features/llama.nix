{ ... }:

{
  # Local FIM code-completion server for minuet-ai.nvim (see nvim/lua/plugins.lua).
  # Sized for 4 GB VRAM: Qwen2.5-Coder-1.5B at Q8_0
  # ~1.6 GB of weights, and an 8k context keeps the KV cache small, leaving
  # headroom for the compositor and other GPU uses.
  flake.nixosModules.llama =
    { pkgs, vars, ... }:
    let
      # CUDA build. This needs `nixpkgs.config.allowUnfree = true`, and unless the
      # CUDA binary cache is configured it compiles from source, which takes long.
      llamaCpp = pkgs.llama-cpp.override { cudaSupport = true; };
    in
    {
      environment.systemPackages = [ llamaCpp ];

      home-manager.users.${vars.username} = {
        systemd.user.services.llama-fim = {
          Unit = {
            Description = "llama.cpp FIM server for Neovim completion";
            After = [ "network-online.target" ];
          };

          Service = {
            # -hf downloads the GGUF on first start into ~/.cache/llama.cpp.
            # To use a file you downloaded yourself, replace the two -hf arguments with:
            #   -m /path/to/model.gguf
            ExecStart = builtins.concatStringsSep " " [
              "${llamaCpp}/bin/llama-server"
              "-hf ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF"
              "--host 127.0.0.1"
              "--port 8012"
              "-ngl 99" # offload every layer to the GPU
              "-c 8192" # small context: saves VRAM, plenty for FIM
              "-np 1" # one slot, so the whole context is not split between slots
              "-b 1024 -ub 1024"
              "--cache-reuse 256" # reuse the KV cache between keystrokes
            ];
            Restart = "on-failure";
            RestartSec = 5;
          };

          # Starts with session or start manually:
          #   systemctl --user start llama-fim
          # Install.WantedBy = [ "default.target" ];
        };
      };
    };
}
