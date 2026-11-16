{ ... }:

{
  flake.nixosModules.llama =
    { pkgs, vars, ... }:
    let
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
            ExecStart = builtins.concatStringsSep " " [
              "${llamaCpp}/bin/llama-server"
              "-hf ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF"
              "--host 127.0.0.1"
              "--port 8012"
              "-ngl 99"
              "-c 8192"
              "-np 1"
              "-b 1024 -ub 1024"
              "--cache-reuse 256"
            ];
            Restart = "on-failure";
            RestartSec = 5;
          };

        };
      };
    };
}
