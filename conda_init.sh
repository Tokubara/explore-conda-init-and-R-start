# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/quebec/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
    echo $PATH    # 的确输出, 可知执行
else
    if [ -f "/Users/quebec/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/quebec/opt/anaconda3/etc/profile.d/conda.sh"
        else
    export PATH="$PATH:/Users/quebec/opt/anaconda3/bin"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<