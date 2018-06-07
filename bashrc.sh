export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cabal/bin:/usr/local/opt/coreutils/libexec/gnubin:$HOME/bin:/usr/local/sbin:$PATH"

#export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

export EDITOR="nano"

alias ls="ls --color=auto"
alias grep="grep --color=auto"

export PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'

export HISTCONTROL="ignoreboth"


export GIT_SSH="/usr/bin/ssh"

function network_location() {
    scselect | awk '{if ($1=="*") print $3}' | sed 's/[()]//g'
}

function restart_proxy() {
    pkill -9 cntlm

    location=$(scselect | awk '{if ($1=="*") print $3}' | sed 's/[()]//g')

    if [[ "$location" == "Work" ]]; then
        cntlm -c $HOME/work/cntlm.conf &
        export no_proxy="internal"
        export NO_PROXY="$no_proxy"
    else
        cntlm -c $HOME/.config/cntlm.conf &
        unset no_proxy
        unset NO_PROXY
    fi
}

# Nix
if [ -e ~/.nix-profile/bin/ghc ]; then
  eval $(grep export ~/.nix-profile/bin/ghc)
  export NIX_GHC="$HOME/.nix-profile/bin/ghc"
  export NIX_GHCPKG="$HOME/.nix-profile/bin/ghc-pkg"
  export NIX_GHC_DOCDIR="$HOME/.nix-profile/share/doc/ghc/html"
  export NIX_GHC_LIBDIR="$HOME/.nix-profile/lib/ghc-$($NIX_GHC --numeric-version)"
  # eval $(grep export ~/.nix-profile/bin/ghc)
fi

export TERMINFO_DIRS="$HOME/.nix-profile/share/terminfo"

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix

# Otherwise it can't find it.
export AWS_CA_BUNDLE="${NIX_SSL_CERT_FILE}"
