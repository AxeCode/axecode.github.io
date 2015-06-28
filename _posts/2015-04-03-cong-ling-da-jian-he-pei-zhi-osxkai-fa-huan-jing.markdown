---
layout: post
title: "从零搭建和配置OSX开发环境"
date: 2015-04-03 22:52:14 +0800
comments: true
categories: 技术
keywords: Mac开发环境搭建,OSX开发环境搭建,Ruby开发环境搭建,开发环境搭建
---
对于每一名开发者来说，更换系统或者更换电脑的时候，都免不了花上不短的时间去折腾开
发环境的问题。我本人也是三番两次，深知这个过程的繁琐。所有，根据我自己以往的经验，
以及参考一下他人的意见，整理一下关于在Mac下做各种开发的配置，包含Java, Ruby, Vim,
git, 数据库等等。欢迎补充与修正。

## {% icon fa fa-anchor %} Terminal篇

这篇文章包含配置控制台环境，包括包管理工具, zsh, Vim, git的安装配置。

#### Homebrew, 你不能错过的包管理工具

包管理工具已经成为现在操作系统中不可缺少的一个重要工具了，它能大大减轻软件安装的
负担，节约我们的时间。Linux中常用的有`yum`和`apt-get`工具，甚至Windows平台也
有`Chocolatey`这样优秀的工具，OSX平台自然有它独有的工具。

在OSX中，有两款大家常用的管理工具：`Homebrew`或者`MacPorts`。这两款工具都是为了解决同
样的问题——为OSX安装常用库和工具。Homebrew与MacPorts的主要区别是Homebrew不会破坏OSX
原生的环境，这也是我推荐Homebrew的主要原因。同时它安装的所有文件都是在用户独立空间内
的，这让你安装的所有软件对于该用户来说都是可以访问的，不需要使用`sudo`命令。

> 在安装Homebrew前，你需要前往AppStore下载并安装Xcode.

安装方式：

``` bash
# OSX系统基本上都自带Ruby1.9
# 所以无需先安装Ruby，但是之后我们需要管理Ruby
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

`Homebrew`常用命令：

``` bash
brew list                 # 查看已经安装的包
brew update               # 更新Homebrew自身
brew doctor               # 诊断关于Homebrew的问题(Homebrew 有问题时请用它)
brew cleanup              # 清理老版本软件包或者无用的文件
brew show ${formula}      # 查看包信息
brew search ${formula}    # 按名称搜索
brew upgrade ${formula}   # 升级软件包
brew install ${formula}   # 按名称安装
brew uninstall ${formula} # 按名称卸载
brew pin/unpin ${formula} # 锁定或者解锁软件包版本，防止误升级
```
#### zsh，好用的shell

Shell程序就是Linux/UNIX系统中的一层外壳，几乎所有的应用程序都可以运行在Shell环境
下，常用的有bash, csh, zcsh等。在`/etc/shells`文件中可以查看系统中的各种shell。

``` bash
cat /etc/shells

# List of acceptable shells for chpass(1).
# Ftpd will not allow users to connect who are not using
# one of these shells.

/bin/bash
/bin/csh
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh
```
而zsh是OSX系统原生的shell之一，其功能强大，语法相对于bash更加友好和强大，所以推荐
使用zsh作为默认的shell。

``` bash
# 切换zsh为默认shell
chsh -s $(which zsh)
```

如果你想使用最新的zsh，你可以使用Homebrew，此方法也会保留原生的zsh，防止你在某个
时刻需要它。

``` bash
# 查看最新zsh信息
brew info zsh

# 安装zsh
brew install --disable-etcdir zsh

# 添加shell路径至/etc/shells文件中
# 将 /usr/local/bin/zsh 添加到下面文件中
sudo vim /etc/shells

# 更换默认shell
chsh -s /usr/local/bin/zsh
```

下面贴上我的zsh配置以供参考

{% include_code 我的zsh配置 lang:bash zshrc %}

#### 好用的编辑器 Vim

对于Vim，无需溢美之词，作为与emacs并列的两大编辑器，早已经被无数人奉为经典。而它却
又以超长的学习曲线，使得很多人望而却步。长久以来，虽然拥有大量的插件，却缺少一个
确之有效的插件管理器。所幸，`Vundle`的出现解决了这个问题。

`Vundle`可以让你在配置文件中管理插件，并且非常方便的查找、安装、更新或者删除插件。
还可以帮你自动配置插件的执行路径和生成帮助文件。相对于另外一个管理工具`pathogen`，
可以说有着巨大的优势。

``` bash
# vundle 安装和配置
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

``` vim
" 将下面配置文件加入到.vimrc文件中
set nocompatible " 必须
filetype off     " 必须

" 将Vundle加入运行时路径中(Runtime path)
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" 使用Vundle管理插件，必须
Plugin 'gmarik/Vundle.vim'

"
" 其他插件
"

call vundle#end() " 必须
filetype plugin indent on " 必须
```

最后，你只需要执行安装命令，即可以安装好所需的插件。

``` bash
# 在vim中
:PluginInstall

# 在终端
vim +PluginInstall +qall
```

下面列出我的Vim插件和配置

{% include_code Vim插件 lang:vim vimrc.bundles %}
{% include_code Vim配置 lang:vim vimrc %}

#### 新世代的版本管理工具 git

Git是一个分散式版本控制软件。最初的目的是为了更好的管理Linux内核开发而设计。与CVS、
Subversion等集中式版本控制软件不同，Git不需要服务器端软件就可以发挥版本控制的作用。
使得代码的维护和发布变得非常方便。

Git库目录结构

+ hooks   : 存储钩子文件夹
+ logs    : 存储日志文件夹
+ refs    : 存储指向各个分支指针的(SHA-1)的文件夹
+ objects : 存储git对象
+ config  : 存储配置文件
+ HEAD    : 指向当前分支的指针文件路径

``` bash
# 安装git
brew install git
```

Git安装完毕后，只需要使用`git config`简单配置下用户名和邮箱就可以使用了。

+ [Git中文简易指南](http://www.bootcss.com/p/git-guide/)
+ [Git官网帮助](https://help.github.com)

为了使Git更好用，对Git做一些配置，`.gitconfig`文件中可以设置自定义命令等，`.gitignore`
文件是默认被忽略版本管理的文件。

{% include_code gitconfig %}
{% include_code gitignore %}

#### 自动集成 ternimal 环境

感谢`thoughtbot`组织发布的[开源项目](https://github.com/thoughtbot/dotfiles)，可
以轻松的完成上述配置。这是我fork项目的地址(https://github.com/zgs225/dotfiles)，
欢迎fork并完善成属于你自己的配置。

安装步骤：

``` bash
# 更改为zsh, 详细参考上面zsh部分
chsh -s $(which zsh)

# clone 源码
git clone https://github.com/zgs225/dotfiles.git

# 安装rcm
brew tap thoughtbot/formulae
brew install rcm

# 安装上述环境并且完成配置
rcup -d dotfiles -x README.md -x LICENSE -x Brewfile
```

## {% icon fa fa-language %} 语言篇

编程语言五花八门，它们各自的版本也是万别千差。各种语言之间或多或少都存在着向前，
或者向后的不兼容。因为版本不兼容导致的bug也是格外的招人烦。所以，在语言篇这篇，也
是侧重与到编程语言版本管理已经环境控制。

#### 简洁优美的类Lisp语言 Ruby

以Ruby作为语言篇的开篇，足以看得出来我对Ruby的喜爱。虽然它有着这样或者那样令人诟
病的缺点，不过作为让我体会到Web世界美妙的第一门语言，我对Ruby一直有着别样的感情。

目前，Ruby的常用版本是1.9，2.1和最新的2.2。最新版本并不是完全向后兼容，所以如果你
的电脑中存在着老版本的Ruby项目，这时候又想切换到新版本中来，那可就头疼了。好在，
有像`rvm`和`rbenv`这样的Ruby版本管理软件。它们各有优劣，而我喜欢更为自动化的rvm。

一个完整的Ruby环境包括Ruby解释器、安装的RubyGems以及它们的文档。rvm用`gemsets`的
概念，为每一个版本的Ruby提供一个独立的RubyGems环境。可以很方便的在不同的Ruby环境
中切换而不相互影响。

``` bash
# 安装rvm
# 设置mpapis公钥
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

# 安装稳定版rvm
\curl -sSL https://get.rvm.io | bash -s stable
```

由于网络原因，可以将rvm的Ruby安装源修改为国内淘宝的[Ruby镜像服务器](http://ruby.taobao.org)。
该镜像服务器15分钟以此更新，尽量保证与官方同步。这样能提高安装速度。

``` bash
# 出自 http://ruby.taobao.org
sed -i .bak 's!cache.ruby-lang.org/pub/ruby!ruby.taobao.org/mirrors/ruby!' $rvm_path/config/db
```
推荐一篇关于rvm的文章: https://ruby-china.org/wiki/rvm-guide

同样，由于网络原因，需要将RubyGems的安装源修改到镜像服务器上。

``` bash
# 切换源
gem sources --remove https://rubygems.org/
gem sources -a https://ruby.taobao.org/

# 查看源列表
gem sources -l

*** CURRENT SOURCES ***

https://rubygems.org/
```

以上，你就拥有了一个相对舒适的Ruby开发环境，不用为版本和网络问题发愁。啊！天空都
清净了。
