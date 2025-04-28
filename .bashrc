# Terminal settings
if [[ "$TERM" == "dumb" ]]; then
    PS1='$ '
else
    PS1="[\h \W]\$ "
fi
shopt -s direxpand
export IGNOREEOF=5


# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -f "$HOME/.secrets" ]; then 
    source $HOME/.secrets #Things I don't need on github, e.g. _lab, EMAIL, GITHUB_PAT...
fi


extra="nemo functions aliases emacs singularity nextflow r"
for e in $extra; do
  if [ -f ~/.bash.d/$e ]; then
    . ~/.bash.d/$e
   fi
done


if [ -f ~/.cargo/env ]; then	    
 . ~/.cargo/env
fi

## Move to the default working location
if [ -d "$_working" ] && [ -z "$TMUX" ] ; then
    cd $_working
fi
   

export MAMBA_EXE=${_lab}/working/$USER/home/bin/micromamba
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
       
if [ -f "$MAMBA_EXE" ]; then
    micromamba activate dev
fi


# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/nemo/stp/babs/working/kellyg/code/bin/julia-install/bin:*)
        ;;

    *)
        export PATH=/nemo/stp/babs/working/kellyg/code/bin/julia-install/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<
