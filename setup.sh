# VM
SETUP_USER="root"
SETUP_HOST="128.199.223.31"

# General
INSTALL_GENERAL=false
INSTALL_VIM=false
INSTALL_NGINX=false

# Languages
INSTALL_NODE=false
NODE_VERSION="v6.11.2"
INSTALL_PYTHON=false
PYTHON_VERSION="2.7.10"
INSTALL_RUBY=false
RUBY_VERSION="2.2.1"

# Database
INSTALL_MYSQL=false
MYSQL_PASSWORD="12345678"

# APP
SETUP_APP=false
APP_NAME="express"
APP_ROOT="/home/$SETUP_USER/apps/$APP_NAME"

# Script
if $INSTALL_GENERAL ; then
  ssh "$SETUP_USER@$SETUP_HOST" "
    touch ~/.bash_profile
    sudo apt-get update
    sudo apt-get -y install git curl build-essential sudo wget apt-utils
    sudo apt-get -yq install --no-install-recommends --no-install-suggests cmake cron ssh build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev libsqlite3-dev sqlite3 python-software-properties
  "
fi

if $INSTALL_NGINX; then
  ssh "$SETUP_USER@$SETUP_HOST" "
    sudo add-apt-repository ppa:nginx/stable
    sudo apt-get -y update
    sudo apt-get -y install nginx
    sudo service nginx start
  "
fi

if $INSTALL_VIM ; then
  ssh "$SETUP_USER@$SETUP_HOST" "
    sudo apt-get -y install vim silversearcher-ag
    sudo apt-get -y upgrade
    git clone https://github.com/adlerhsieh/.vim.git ~/.vim
    cd ~/.vim ; git submodule init
    cd ~/.vim ; git submodule update --recursive
    cp ~/.vim/misc/.vimrc ~/.vimrc
    cp ~/.vim/misc/onedark.vim ~/.vim/bundle/vim-colorschemes/colors/onedark.vim
  "
fi

if $INSTALL_NODE ; then
  ssh "$SETUP_USER@$SETUP_HOST" "
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
    echo 'export export NVM_DIR=\"\$HOME/.nvm\"' >> ~/.bash_profile
    echo '[ -s \"\$NVM_DIR/nvm.sh\"  ] && . \"\$NVM_DIR/nvm.sh\"' >> ~/.bash_profile
    source ~/.bash_profile
    nvm install $NODE_VERSION
    node --version
  "
fi

if $INSTALL_PYTHON; then
  ssh "$SETUP_USER@$SETUP_HOST" "
    sudo apt-get -y install make libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev xz-utils
    apt-get -y upgrade
    curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
    echo 'export PYENV_ROOT=\"\$HOME/.pyenv\"' >> ~/.bash_profile
    echo 'export PATH=\"\$PYENV_ROOT/bin:\$PATH\"' >> ~/.bash_profile
    source ~/.bash_profile
    pyenv update
    pyenv install $PYTHON_VERSION
    pyenv global $PYTHON_VERSION
  "
fi

if $INSTALL_RUBY; then
  ssh "$SETUP_USER@$SETUP_HOST" "
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
    echo 'export RBENV_ROOT=\"\$HOME/.rbenv\"' >> ~/.bash_profile
    echo 'export PATH=\"\$RBENV_ROOT/bin:\$PATH\"' >> ~/.bash_profile
    source ~/.bash_profile
    rbenv install $RUBY_VERSION
    rbenv global $RUBY_VERSION
  "
fi

if $INSTALL_MYSQL; then
  ssh "$SETUP_USER@$SETUP_HOST" "
    debconf-set-selections <<< 'mysql-server mysql-server/root_password password $MYSQL_PASSWORD'
    debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD'
    sudo apt-get -y install mysql-common mysql-client libmysqlclient-dev mysql-server
    service mysql start
  "
fi

if $SETUP_APP ; then
  ssh "$SETUP_USER@$SETUP_HOST" "
    mkdir -p $APP_ROOT/shared $APP_ROOT/logs
  "
fi
