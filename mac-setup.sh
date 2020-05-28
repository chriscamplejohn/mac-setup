#!/bin/sh

println() {
  printf "%s\n" "$@"
}

printbanner() {
 cat << "EOF"
                       ___  ____    ____       _               
 _ __ ___   __ _  ___ / _ \/ ___|  / ___|  ___| |_ _   _ _ __  
| '_ ` _ \ / _` |/ __| | | \___ \  \___ \ / _ \ __| | | | '_ \ 
| | | | | | (_| | (__| |_| |___) |  ___) |  __/ |_| |_| | |_) |
|_| |_| |_|\__,_|\___|\___/|____/  |____/ \___|\__|\__,_| .__/ 
                                                        |_|    
EOF
}

ensure_file_exists() {
  touch $1
}

ensure_bash_profile_exists() {
  ensure_file_exists ~/.bash_profile
}

ensure_zprofile_exists() {
  ensure_file_exists ~/.zprofile
}

idempotent_append_to_file() {
  local file="$1"
  local text="$2"

  if ! grep -qF "$text" $file; then
    echo "$text" >> $file
  fi
}

idempotent_append_to_bash_profile() {
  idempotent_append_to_file ~/.bash_profile $@
}

idempotent_append_to_zprofile() {
  idempotent_append_to_file ~/.zprofile $@
}

reload_bash_profile() {
  source ~/.bash_profile
}

install() {
  local app=${1#*install_}
  printf "Installing %s...\n" "$app"

  local func="install_$app"
  $func
  
  printf "Done installing %s!\n" "$app"
}

install_all() {
  local all_install_funcs=$(grep -o "^install_\w*" ./mac-setup.sh)

  for func in $all_install_funcs
  do
    if [ "$func" != 'install_all' ]; then install $func; fi
  done
}

install_homebrew() {
  if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    println "Homebrew already installed...updating!"
    brew update
    brew cleanup
  fi

  brew -v
}

install_zprofile_redirect() {
  ensure_bash_profile_exists
  
  idempotent_append_to_zprofile "source ~/.bash_profile"
}

install_useful_aliases() {
  idempotent_append_to_bash_profile "alias dc=docker-compose"
  idempotent_append_to_bash_profile "alias gc=gcloud"
  idempotent_append_to_bash_profile "alias tf=terraform"
  idempotent_append_to_bash_profile "alias tg=terragrunt"

  # TODO - fix this! Need multiline support from idempotent_append_to_bash_profile
  # idempotent_append_to_bash_profile "function awsp() {" 'printf "Setting AWS Profile to %s" "$1"' 'export AWS_PROFILE=$1' "}"

  reload_bash_profile
}

install_chrome() {
  if ! brew cask list google-chrome >/dev/null 2>&1; then
    brew cask install google-chrome
  else
    println "Chrome already installed...updating!"
    brew cask upgrade google-chrome
  fi
}

install_spotify() {
  if ! brew cask list spotify >/dev/null 2>&1; then
    brew cask install spotify
  else
    println "Spotify already installed...updating!"
    brew cask upgrade spotify
  fi
}

install_vscode() {
  if ! command -v code >/dev/null 2>&1; then
    brew cask install visual-studio-code
  else
    println "VSCode already installed...updating!"
    brew cask upgrade visual-studio-code
  fi
}

install_slack() {
  if ! brew cask list slack >/dev/null 2>&1; then
    brew cask install slack
  else
    println "Slack already installed...updating!"
    brew cask upgrade slack
  fi
}

install_docker() {
  if ! brew cask list docker >/dev/null 2>&1; then
    brew cask install docker
  else
    println "Docker Desktop already installed...updating!"
    brew cask upgrade docker
  fi
}

install_authy() {
  if ! brew cask list authy >/dev/null 2>&1; then
    brew cask install authy
  else
    println "Authy already installed...updating!"
    brew cask upgrade authy
  fi
}

install_virtualbox() {
  if ! brew cask list virtualbox >/dev/null 2>&1; then
    brew cask install virtualbox
  else
    println "Virtualbox already installed...updating!"
    brew cask update virtualbox
  fi
}

install_firefox() {
  if ! brew cask list firefox >/dev/null 2>&1; then
    brew cask install firefox
  else
    brew cask upgrade firefox
  fi
}

install_dotnetcore() {
  if ! brew cask list dotnet-sdk >/dev/null 2>&1; then
    brew cask install dotnet-sdk
  else
    println "Dotnet Core SDK already installed...updating!"
    brew cask upgrade dotnet-sdk
  fi
}

install_git() {
  if ! brew list git >/dev/null 2>&1; then
    brew install git
  else
    println "Git already installed...updating!"
    brew upgrade git
  fi
}

install_github() {
  if ! brew cask list github >/dev/null 2>&1; then
    brew cask install github
  else
    println "Github Desktop already installed...updating!"
    brew cask upgrade github
  fi
}

install_npm() {
  if ! command -v npm >/dev/null; then
    brew install npm
  else
    println "NPM already installed...updating!"
    brew upgrade npm
  fi
}

install_nss() {
  if ! command -v certutil >/dev/null; then
    brew install nss
  else
    println "NSS already installed...updating!"
    brew upgrade nss
  fi
}

install_mkcert() {
  if ! command -v mkcert >/dev/null; then
    brew install mkcert
    mkcert -install # install the root certificate authority (CA)
  else
    println "Mkcert already installed...updating!"
    brew upgrade mkcert
  fi
}

install_go() {
  if ! command -v go >/dev/null; then
    brew install go
  else
    println "Go already installed...updating!"
    brew upgrade go
  fi
}

install_iterm2() {
  if ! brew cask list iterm2 >/dev/null 2>&1; then
     brew cask install iterm2
  else
    println "ITerm2 already installed...updating!"
    brew cask upgrade iterm2
  fi
}

install_powerline_fonts() {
  # clone
  git clone https://github.com/powerline/fonts.git --depth=1
  # install
  cd fonts
  ./install.sh
  # clean-up a bit
  cd ..
  rm -rf fonts
}

install_nerd_fonts() {
  brew tap homebrew/cask-fonts

  if ! brew cask list font-hack-nerd-font >/dev/null 2>&1; then
    brew cask install font-hack-nerd-font
  else
    println "Nerd Fonts already installed...updating!"
    brew cask upgrade font-hack-nerd-font
  fi
}

install_spaceship_prompt() {
  if ! npm -g ls | grep spaceship-prompt >/dev/null; then
    npm install -g spaceship-prompt
  else
    println "Spaceship Prompt already installed...updating!"
    npm update -g spaceship-prompt
  fi
}

install_ruby() {
  if ! brew list ruby >/dev/null 2>&1; then
    brew install ruby
  else
    println "Ruby already installed...updating!"
    brew upgrade ruby
  fi

  idempotent_append_to_bash_profile 'export PATH="/usr/local/opt/ruby/bin:$PATH"'
  reload_bash_profile
}

install_colorls() {
  if ! gem list colorls | grep colorls >/dev/null; then
    gem install colorls
  else
    println "Colorls gem already installed...updating!"
    gem update colorls
  fi

  idempotent_append_to_bash_profile "export PATH=\""'$PATH:$(ruby -e '"'puts Gem.bindir')\""
  idempotent_append_to_bash_profile "source $(dirname $(gem which colorls))/tab_complete.sh"
  idempotent_append_to_bash_profile "alias ls='colorls'"
  idempotent_append_to_bash_profile "alias ll='colorls -lA --sd'"
  reload_bash_profile
}

install_aws_cli() {
  if ! brew list awscli >/dev/null 2>&1; then
    brew install awscli
  else
    println "AWS CLI already installed...updating!"
    brew upgrade awscli
  fi
}

install_gcp_sdk() {
  if ! brew cask list google-cloud-sdk >/dev/null 2>&1; then
    brew cask install google-cloud-sdk
  else
    println "Google Cloud SDK already installed...updating!"
    brew cask upgrade google-cloud-sdk
  fi

  ## ZSH Specific
  idempotent_append_to_zprofile 'source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"'
  idempotent_append_to_zprofile 'source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"'

  idempotent_append_to_bash_profile "alia"
}

install_rectangle() {
  if ! brew cask list rectangle >/dev/null 2>&1; then
    brew cask install rectangle
  else
    println "Rectangle already installed...updating!"
    brew cask upgrade rectangle
  fi 
}

display_usage() {
  println
  println "USAGE: $0 req1 [opt1 [opt2]..[optn]]"
  println
  println "req1 is the required name of the application to install or update"
  println "opt1 to optn are additional optional required applications to install or update"
  println
  println "The available application names are:"
  println "all - this is a shortcut instead of typing all listed applications"
  
  local all_install_funcs=$(grep -o "^install_\w*" ./mac-setup.sh)

  for func in $all_install_funcs
  do
    if [ "$func" != 'install_all' ]; then println "${func#*install_}"; fi
  done

  println
}

printbanner

if [ "$#" -eq 0 ]; then
  display_usage
else
  for arg
  do install "$arg"
  done
fi
