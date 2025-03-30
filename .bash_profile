# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
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
