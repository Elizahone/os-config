{config, nixpkgs, ... } :

{

  programs.zsh = {
    enable = true;
    autocd = false;
    dotDir = "${config.xdg.configHome}/zsh";
    history.path = "${config.xdg.configHome}/zsh/zsh_history";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Content of .zshenv, replacing the old .zshenv / env.sh.
    # XDG_* variables are already provided by home-manager.
    envExtra = ''
      # Machine-specific overrides (optional, not tracked)
      [ -f "$HOME/.shell_local" ] && . "$HOME/.shell_local"
      export EDITOR=nvim
    '';

    # Content of .zshrc: the old utils.sh functions and the prompt.
    initContent = ''
      # ── shell functions ──────────────────────────────────────────────────
      elzh_proxy() {
        case $1 in
          set)
            export https_proxy=http://localhost:7890
            export http_proxy=http://localhost:7890
            printf 'successfully set\n'
            ;;
          unset)
            unset https_proxy
            unset http_proxy
            printf 'successfully unset\n'
            ;;
          help | *)
            cat <<'EOF_HELP'
      [USAGE]:     elzh_proxy [command]
          set  :        set `https_proxy` and `http_proxy` to localhost:7890.
          unset:        unset these env aforementioned.
          help :        print help information.
      EOF_HELP
            ;;
        esac
      }

      ncd() {
        NVIM_CD_TMP=/tmp/nvim_cd nvim "$@"
        cd "$(cat /tmp/nvim_cd)"
      }

      # ── prompt (pure zsh, replaces zim's prompt-pwd/git-info/duration-info) ─
      setopt PROMPT_CR PROMPT_SP PROMPT_SUBST
      autoload -Uz add-zsh-hook vcs_info
      zmodload zsh/datetime   # provides $EPOCHSECONDS

      # duration-info: how long the last command took (only if >= 2s)
      typeset -g _elzh_cmd_start=0 _elzh_duration=""
      _elzh_preexec() { _elzh_cmd_start=$EPOCHSECONDS }
      _elzh_precmd_duration() {
        local elapsed
        if (( _elzh_cmd_start > 0 )); then
          elapsed=$(( EPOCHSECONDS - _elzh_cmd_start ))
          (( elapsed >= 2 )) && _elzh_duration=" %F{244}''${elapsed}s%f" || _elzh_duration=""
        else
          _elzh_duration=""
        fi
        _elzh_cmd_start=0
      }

      # git-info: branch, staged '+', unstaged '!', ahead '>', behind '<', stash '$'
      zstyle ':vcs_info:git:*' check-for-changes true
      zstyle ':vcs_info:git:*' stagedstr '+'
      zstyle ':vcs_info:git:*' unstagedstr '!'
      zstyle ':vcs_info:git:*' formats ' %F{135}(%b%c%u%m)%f'
      zstyle ':vcs_info:git:*' actionformats ""
      zstyle ':vcs_info:git+set-message:*' hooks elzh-git-misc

      +vi-elzh-git-misc() {
        local counts ahead behind misc="" gitdir
        counts=$(git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
        if [[ -n $counts ]]; then
          local -a parts
          parts=(''${=counts})
          behind=$parts[1]
          ahead=$parts[2]
          (( ahead  > 0 )) && misc+='>'
          (( behind > 0 )) && misc+='<'
        fi
        gitdir=$(git rev-parse --git-dir 2>/dev/null)
        [[ -n $gitdir && -f $gitdir/refs/stash ]] && misc+='$'
        hook_com[misc]+=$misc
      }

      _elzh_precmd() {
        _elzh_precmd_duration
        vcs_info
        # nix-shell indicator: IN_NIX_SHELL is set by nix-shell / nix develop
        if [[ -n $IN_NIX_SHELL ]]; then
          _elzh_nix_info=' %F{81}[nix-shell]%f'
        else
          _elzh_nix_info=""
        fi
      }
      add-zsh-hook preexec _elzh_preexec
      add-zsh-hook precmd _elzh_precmd

      # %~ is the cwd with $HOME collapsed to ~ (like zim's prompt-pwd).
      PS1="%F{220}╭─%F{34}%n%F{40}@%F{46}%m %F{154}[%~]%f\''${_elzh_nix_info}\''${vcs_info_msg_0_}\''${_elzh_duration}"$'\n'"%F{154}╰λ%f "
      RPS1=""
    '';
  };

}
