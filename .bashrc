# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -f "$HOME/.secrets" ]; then 
    source $HOME/.secrets #Things I don't need on github, e.g. my_lab, SLACK_URL
fi

shopt -s direxpand

extra="nemo aliases functions emacs singularity"
for e in $extra; do
  if [ -f ~/.bash.d/$e ]; then
    . ~/.bash.d/$e
   fi
done


export IGNOREEOF=5

#export LIBGL_ALWAYS_INDIRECT=1
#export RVERSION=4.2.2


#export PYTHONPATH=$PYTHONPATH:${my_lab}working/patelh/code/PYTHON/


export RIPGREP_CONFIG_PATH=~/.ripgreprc



if [ -f ~/.cargo/env ]; then	    
 . ~/.cargo/env
fi


if [ -d "$my_working" ] && [ -z "$TMUX" ] ; then
    cd $my_working
fi
   

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/nemo/stp/babs/working/kellyg/home/bin/micromamba';
export MAMBA_ROOT_PREFIX='/nemo/stp/babs/working/kellyg/home/share/micromamba';
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


export PATH="/nemo/stp/babs/working/kellyg/home/bin:$PATH"

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
