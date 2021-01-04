##### 探索过程

首先先跟着bashdb走了一遍. 发现在"这里"

.

看了看目录结构, 猜测`R.framework`是symlink. 原因是`/Library/Frameworks/R.framework/Versions/`目录下还有4.0, 我觉得不可能重复.

```
quebec@Rhett exec % ls -l /Library/Frameworks/R.framework/Resources
lrwxr-xr-x  1 root  admin  26 Nov 23 14:17 /Library/Frameworks/R.framework/Resources -> Versions/Current/Resources
```

是的, 是链接. 但是指向是`Versions/Current/Resources`

```
quebec@Rhett exec % ls /Library/Frameworks/R.framework/Versions/
3.6     4.0     Current
```

但从这个名字来看, 我猜测它也是link.

```
quebec@Rhett exec % ls -l /Library/Frameworks/R.framework/Versions/Current 
lrwxr-xr-x  1 root  admin  3 Nov 23 14:17 /Library/Frameworks/R.framework/Versions/Current -> 4.0
```

果然如此. 所以就是指向4.0.

再看看, R脚本中怎么指向的.

```
export R_HOME
R_SHARE_DIR=/Library/Frameworks/R.framework/Resources/share
export R_SHARE_DIR
R_INCLUDE_DIR=/Library/Frameworks/R.framework/Resources/include
export R_INCLUDE_DIR
R_DOC_DIR=/Library/Frameworks/R.framework/Resources/doc
export R_DOC_DIR
```

果然, 指向的是链接.
所以我想, 如果想要访问3.6的R怎么办. 只要改Current就可以了.

```
ln -s /Library/Frameworks/R.framework/Versions/3.6/Resources Current
```

于是我快意地直接删除了Current, 发现了一件事, 那就是R没了.. 因为它也是symlink, 没猜错的话, 应该是Current中某个文件的symlink
于是我进入Current, 企图再找到一个R, 我找到了, 就在Resources的根目录下, 它也是y一个symlink, 但是问题来了, 执行它的时候报错:

```
./R: line 240: /Library/Frameworks/R.framework/Resources/etc/ldpaths: No such file or directory
```

但是我发现Current下, 明明就有啊. 我想到, 之前的那个Resource指向的是一个已删除的symlink. 或许我需要对Resource也进行更新.
然后就对了, 我顺利回到了旧的R中去. 通过./R, 我回去了.

##### |总结发现

- 执行R其实是执行一个shell脚本, 这个脚本主要干了这些事:

  - 设置了一些环境变量, 最重要的是`R_HOME_DIR`(`R_HOME=${R_HOME_DIR}`), 其它一些环境变量, 比如下面提到的`R_HOME_DIR`都是依赖`R_HOME`的. 而`R_HOME=/Library/Frameworks/R.framework/Resources`
  - 启动`R_binary=" ${R_HOME}/bin/exec$ {R_ARCH}/R"`. 但如果不经过这个R shell脚本执行是会出错的, 因为它依赖一堆环境变量(之后会说到).
- 刚刚说`R_HOME`的这个路径`/Library/Frameworks/R.framework/Resources`, 其实是一个symlink, 它直接指向的是`/Library/Frameworks/R.framework/Versions/Current`, 而后者也就是`/Library/Frameworks/R.framework/Versions/Current`也是一个symlink, 指向的是`/Library/Frameworks/R.framework/Versions/4.0/Resouces`.
  不同版本的R在`/Library/Frameworks/R.framework/Versions`下, 对每个R, 真实的home目录都是其下(比如`Versions/3.6`)的`Resources`文件夹.
- `/usr/local/bin/R`是个symlink, 指向`Resources`文件夹下的R, 后者也是symlink, 指向的是home目录下bin目录的R. 3.6和4.0的`Resources/bin/R`两个文件完全相同, 因为启动逻辑相同.

###### |如何才能通过`R3.6`执行R3.6?

很简单. 我想只要再创建一个一模一样的shell脚本, 再改一下`R_HOME`的路径, 从`R_HOME=/Library/Frameworks/R.framework/Resources`指向`/Library/Frameworks/R.framework/Versions/3.6/Resouces` 就可以了. 于是我拷贝了R shell脚本到/usr/local/bin/下, 起名叫3.6

仅仅只有这些行不一样:

```
R_HOME_DIR=/Library/Frameworks/R.framework/Versions/3.6/Resources
R_SHARE_DIR=${R_HOME}/share # 其实这是等价的, 之前的脚本用的是绝对路径, 我觉得这种写法很丑陋
R_INCLUDE_DIR=${R_HOME}/include # 同上
R_DOC_DIR=${R_HOME}/doc # 同上
```

然后我就也能使用R3.6了(虽然并没有什么用..).

#### python也是类似的

目录结构都很类似, `/Library/Frameworks/Python.framework/Versions/3.7/`, `Current`和`Resources`也是有的, 不过被我发现都是指向2.7以后, 我就把它删了.
但也有不类似的地方, 3.7下Resources不是home目录, 3.7本身就是, 其下的bin放着pip, idle, python3.7等等.
包放在lib/python3.7下

jupyter lab cd命令是不行的, 甚至不同于RStudio, 至少可以在一个chunk行, 这里是一个chunk都不行.