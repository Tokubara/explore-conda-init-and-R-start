`~/Playground/play/conda_init`, 这是活动目录.

##### 是怎么得到`~/Playground/play/conda_init`下的各个文件的?

`conda_init.sh`是从`.bash_profile`拷过来的
`conda_exec.sh`是根据`conda_init.sh`中的这句`__conda_setup="$('/Users/quebec/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"`, 执行`/Users/quebec/opt/anaconda3/bin/conda shell.bash hook > conda_exec.sh`得到的(称为A). 还有个对比文件也是`.bash_profile`这里提到的`/Users/quebec/opt/anaconda3/etc/profile.d/conda.sh`文件, 拷贝到这来了, 还是`conda.sh`(称为B). 经比较得知, 后两个文件只差一行, 但差的这一行, 就是天差地别. 这句话是`conda active base`, A有, B没有. 为啥天差地别, 因为这个函数层层调用了`conda_exec.sh`中的各个函数, PATH也是它加上的, PS1也是它改的.

`bashdb conda_exec.sh` watch PATH.

##### conda是怎么init的

```
Watchpoint 0: $PATH changed:
  old value: '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/VMware Fusion.app/Contents/Public:/Library/TeX/texbin:/usr/local/go/bin:/usr/local/share/dotnet:/opt/X11/bin:/usr/local/git/bin:/Users/quebec/opt/anaconda3/condabin'
  new value: '/Users/quebec/opt/anaconda3/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/VMware Fusion.app/Contents/Public:/Library/TeX/texbin:/usr/local/go/bin:/usr/local/share/dotnet:/opt/X11/bin:/usr/local/git/bin:/Users/quebec/opt/anaconda3/condabin'
(/Users/quebec/Playground/play/conda_init/conda_exec.sh:29):
29:         xport PATH
 0: ${PATH%%:*} = /Users/quebec/opt/anaconda3/bin
```

```
 0: ${PATH%%:*} = /Users/quebec/opt/anaconda3/bin
bashdb<11> where
->0 in file `conda_exec.sh' at line 29
##1 __add_sys_prefix_to_path() called from file `conda_exec.sh' at line 54
##2 __conda_activate("activate", "base") called from file `conda_exec.sh' at line 83
##3 conda("activate", "base") called from file `conda_exec.sh' at line 127
##4 source("conda_exec.sh") called from file `/usr/local/bin/bashdb' at line 107
##5 main("conda_exec.sh") called from file `/usr/local/bin/bashdb' at line 0
```

##### 之前我是怎么错误折腾的?

之前我反复注释掉, 又取消注释`.bash_profile`, 没意识到, 它对bash是startup file, 因此改动它很不方便, 但我可以拷贝它的内容, 这样就成了一个普通脚本, 观察效果就要方便很多.
另外, 感觉跟环境还是有些关系的, 之前通过直接`.bash_profile`, 发现它进入的是else分支