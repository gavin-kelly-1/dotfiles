# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi


if [ -f "$HOME/.secrets" ]; then 
    source $HOME/.secrets #Things I don't need on github, e.g. my_lab, SLACK_URL
fi

shopt -s direxpand

if [ -d "$my_lab" ]; then
    . ~/.bash.d/nemo
fi



export IGNOREEOF=5

#export LIBGL_ALWAYS_INDIRECT=1
#export RVERSION=4.2.2


#export PYTHONPATH=$PYTHONPATH:${my_lab}working/patelh/code/PYTHON/


export BABS_SINGULARITY_INTERACTIVE_EXTRAS='--bind $HOME/.Xauthority,$HOME/.Xdefaults,$HOME/.Xresources,$HOME/.emacs.d,$HOME/.ssh --env DISPLAY=$DISPLAY'
export RIPGREP_CONFIG_PATH=~/.ripgreprc



# User specific aliases and function

if [ -f ~/.bash.d/aliases ]; then
    . ~/.bash.d/aliases
fi

if [ -f ~/.bash.d/functions ]; then
    . ~/.bash.d/functions
fi

if [ -f ~/.bash.d/emacs ]; then
    . ~/.bash.d/emacs
fi

if [ -f ~/.cargo/env ]; then	    
 . ~/.cargo/env
fi


if [ -d "$my_working"  ]; then
    cd $my_working
fi
   

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/nemo/stp/babs/working/kellyg/home/.local/bin/micromamba';
export MAMBA_ROOT_PREFIX='/nemo/project/home/kellyg/micromamba';
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


export PATH="/camp/home/kellyg/.local/bin:$PATH"
