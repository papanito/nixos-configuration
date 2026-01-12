{ pkgs }:
{
  enable = true;
  enableCompletion = true;
  enableAutosuggestions = true;
  syntaxHighlighting.enable = true;

  oh-my-zsh = {
    enable = true;
    plugins = [ "sudo" ];
    theme = "agnoster";
  };

  shellAliases = {
    ll = "ls -l";
    la = "ls -A";
    ".." = "cd ..";
    g = "git";
    vim = "nvim";
    cat = "bat";
  };

  initContent = ''
    # Personal zsh configuration
    export EDITOR=nvim
    export PATH=$HOME/bin:$PATH

    # History configuration
    export HISTSIZE=10000
    export SAVEHIST=10000
    export HISTFILE=$HOME/.zsh_history

    # Custom functions
    mkcd() {
      mkdir -p "$1" && cd "$1"
    }

    # Custom prompt
    PROMPT='%F{blue}%~ %f%# '

    # Load additional completions
    autoload -Uz compinit
    compinit
  '';
}

