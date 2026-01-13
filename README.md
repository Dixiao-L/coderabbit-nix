# CodeRabbit Nix

Nix flake for [CodeRabbit CLI](https://coderabbit.ai) - AI-powered code review tool.

## Features

- Declarative installation via Nix flakes
- Automatic hourly version updates via GitHub Actions
- Support for x86_64-linux (other platforms need hash updates)

## Usage

### Run directly

```bash
# Run CodeRabbit CLI
nix run github:YOUR_USERNAME/coderabbit-nix

# Or use the short alias
nix run github:YOUR_USERNAME/coderabbit-nix#cr
```

### Add to your flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    coderabbit.url = "github:YOUR_USERNAME/coderabbit-nix";
  };

  outputs = { self, nixpkgs, coderabbit, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            coderabbit.packages.${pkgs.system}.coderabbit
          ];
        })
      ];
    };
  };
}
```

### Use the overlay

```nix
{
  inputs.coderabbit.url = "github:YOUR_USERNAME/coderabbit-nix";

  outputs = { self, nixpkgs, coderabbit, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ coderabbit.overlays.default ];
          environment.systemPackages = [ pkgs.coderabbit ];
        })
      ];
    };
  };
}
```

## Authentication

After installation, authenticate with CodeRabbit:

```bash
coderabbit auth login
# or
cr auth login
```

## Commands

```bash
coderabbit --help           # Show help
coderabbit auth login       # Authenticate
coderabbit review           # Start a code review
```

## Development

### Manual version update

```bash
./scripts/update-version.sh
```

### Build locally

```bash
nix build .#coderabbit
./result/bin/coderabbit --help
```

## Auto-Updates

This repository uses GitHub Actions to automatically check for new CodeRabbit versions every hour. When a new version is detected:

1. A pull request is created with the updated version and hash
2. The PR is automatically merged if the build succeeds

## License

The Nix packaging code in this repository is MIT licensed.
CodeRabbit CLI itself is proprietary software - see [CodeRabbit's terms](https://coderabbit.ai/terms).
