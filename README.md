# TextStateServer

响应状态内容并根据反馈执行特定任务的服务端程序。

## 文档目录

- [部署指南](#部署指南)
- [编译指南](#编译指南)

## 部署指南

本指南包括了运行环境、配置方法和运行状态的基本检查。

### 运行环境

因为本指南使用的是预编译好的程序，所以系统需要保证和编译环境一致。具体编译过程请参考[编译指南](#编译指南)章节。

- 最低内存要求：256MB

### 配置应用

使用命令解压打包好的程序：

```bash
tar -zxvf text_state_server-1.0.0-bin.tar.gz
```

进入主目录并创建配置文件:

```bash
cd text_state_server
touch .env
```

请使用自己擅长的编辑器编辑 `.env` 文件，并粘贴以下模板配置：

```
TEXT_STATE_SERVER_STATE_FILE=<读取状态内容的文件>
TEXT_STATE_SERVER_TMP_FILE2=<写入客户端二返回数据的文件>
TEXT_STATE_SERVER_TMP_FILE3=<写入客户端三返回数据的文件>
TEXT_STATE_SERVER_PORT=<监听的端口>
```

编辑配置，将以上模板中的 `<中文注释>` 替换成自己的参数即可（不保留尖括号），参数的详细解释请参考下面内容。

文件路径相关参数：

- `TEXT_STATE_SERVER_STATE_FILE`: 此文件内容将作为状态响应给所有客户端，例如 `/etc/config.txt`。
- `TEXT_STATE_SERVER_TMP_FILE2`: 接收到客户端二返回的数据时写入到的文件，例如 `/tmp/2.txt`。此文件无需预先创建，但必须保证父级目录具有可写权限。
- `TEXT_STATE_SERVER_TMP_FILE3`: 接收到客户端三返回的数据时写入到的文件，例如 `/tmp/3.txt`。此文件无需预先创建，但必须保证父级目录具有可写权限。

网络服务相关参数：

- `TEXT_STATE_SERVER_PORT`: 监听的端口，例如 `21337`。一般建议端口号大于 `1024` 且不与常用软件端口号冲突。

所有参数获取完毕并确认有效以后，填充到配置文件中便可尝试启动服务端程序。

### 启动应用

保持或进入解压后的 text_state_server 主目录，保证 `.env` 文件也在此目录中，使用以下命令启动：

```bash
./bin/text_state_server start_iex
```

稍作初始化相关的等待，就会看到此条日志输出：

```
Running server at 0.0.0.0:<your_port> (udp)
```

这表示一切正常。如果在启动过程中出现任何错误，程序会崩溃并给出原因。如果出现了非致命的问题，会出现红色或黄色的日志。

如果出现无法理解的问题，请联系开发者。

## 编译指南

此指南包括了本项目的编译到打包过程。

### 环境准备

构建本项目需要安装 Erlang OTP 22+ 以及 Elixir 1.12 版本，构建环境决定了对部署环境的选择（两种环境须保持一致）。

#### 通过 asdf（推荐）

使用 asdf 可以让系统同时存在多个不同版本的 Erlang 和 Elixir。它可以让本项目永久摆脱系统软件源提供的工具链的版本束缚，根据自身需要随意切换到指定的某个旧版或最新版本上。

安装 asdf：

```bash
sudo apt install curl git -y
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc
echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.bashrc
```

安装 asdf 插件：

```bash
asdf plugin-add erlang
asdf plugin-add elixir
```

如果您的系统包管理不是 Aptitude (Deiban 系的 apt/apt-get 工具) 请参考[官方页面](https://asdf-vm.com/#/core-manage-asdf)。

在进行下一步之前，您需要安装一些满足从源码构建 Erlang 的依赖包。因为 Erlang 是运行一切的基础，对它的版本和功能保持高度的可控性，是建议摆脱系统软件源提供的 Erlang 包的主要原因。顺带一提，在大多数具有固定维护周期的 Linux 发行版上，Erlang 的大版本几乎不会升级。当前使用 Elixir 1.12 构建本项目，而 OTP 22 是该版本 Elixir 支持的最低版本，即将被淘汰。

安装构建 Erlang 所需的依赖包（Ubuntu 20.04）：

```bash
sudo apt install \
  build-essential \
  libssl-dev automake \
  autoconf \
  libncurses5-dev \
  xsltproc \
  fop \
  libxml2-utils
```

安装当前项目所需的工具链（Erlang + Elixir）：

```bash
KERL_CONFIGURE_OPTIONS="--without-javac \
  --without-odbc \
  --without-wx \
  --without-observer \
  --without-debugger \
  --without-et" \
asdf install
```

上面的命令会从源码构建 Erlang，过程可能会比较长。

完成后在终端运行 `iex` 命令，成功的话会进入一个交互式 Shell 且没有任何报错。以及，此命令输出的第一行内容还会显示 Elang/OTP 和 Elixir 的版本。

_提示：如果您想知道这背后做了什么，请查看源码根目录的 `.tool-versions` 文件。此文件记录了 Erlang 和 Elixir 版本，所谓的 `asdf install` 就是安装此文件中的指定版本。`KERL_CONFIGURE_OPTIONS` 是编译 Erlang 的一些附加参数，考虑到服务器环境不需要图形，关闭了一些无关的功能，它可以让构建结果更加精小。_

### 构建项目

解压 text_state_server-1.0.0-src.tar.gz 文件，并进入主目录：

```bash
tar -zxvf text_state_server-1.0.0-src.tar.gz
cd text_state_server-1.0.0
```

构建项目：

```bash
# 安装依赖
MIX_ENV=prod mix deps.get
# 编译代码
MIX_ENV=prod mix compile
# 打包运行环境
MIX_ENV=prod mix release
```

_注意：部分命令可能会产生一些警告，这是正常的。_

依次执行完毕且没有失败就表示可以生成压缩包了。

### 打包项目

请保证处于 text_state_server-1.0.0 目录中，执行以下命令：

```bash
cd _build/prod/rel
tar -zcvf text_state_server-1.0.0-bin.tar.gz text_state_server/
```

至此，生成的压缩文件已经可部署至运行机器人的服务器上了。

经历上述过程以后运行时已经被最小化的包含在压缩包中了，部署环境不需要安装任何工具即可直接运行。但如上有提，部署机器人的服务器系统需要保证和构建环境的系统版本一致。这是因为 Elixir 是一门虚拟机语言，运行于 Beam（类似于 Java 的 JVM）中，复杂的 Erlang/Beam 运行时难以构建为纯静态的结果，所以部分底层运行时组件仍然存在一些的动态链接（这是要求运行环境和编译环境需要一致的原因）。
