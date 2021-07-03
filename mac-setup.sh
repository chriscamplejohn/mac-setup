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

  ensure_file_exists "$file"

  if ! grep -qF "$text" "$file"; then
    echo "$text" >> "$file"
  fi
}

idempotent_append_to_profile() {
  idempotent_append_to_zprofile "$@"
}

idempotent_append_to_bash_profile() {
  idempotent_append_to_file ~/.bash_profile "$@"
}

idempotent_append_to_zprofile() {
  idempotent_append_to_file ~/.zprofile "$@"
}

reload_profile() {
  source ~/.zprofile
}

brew_install_or_upgrade() {
  if ! brew list "$1" >/dev/null 2>&1; then
    brew install "$1"
  else
    println "$1 already installed...updating!"
    brew upgrade "$1"
  fi
}

brew_cask_install_or_upgrade() {
  if ! brew list --cask "$1" >/dev/null 2>&1; then
    brew install --cask "$1"
  else
    println "$1 already installed...updating!"
    brew upgrade --cask "$1"
  fi
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

install_bash_profile_redirect() {
  ensure_zprofile_exists
  
  idempotent_append_to_bash_profile "source ~/.zprofile"
}

install_chrome() {
  if ! brew list --cask google-chrome >/dev/null 2>&1; then
    brew install --cask google-chrome
  else
    println "Chrome already installed...updating!"
    brew upgrade --cask google-chrome
  fi
}

install_spotify() {
  brew_cask_install_or_upgrade spotify
}

install_vscode() {
  brew_cask_install_or_upgrade visual-studio-code
}

install_slack() {
  brew_cask_install_or_upgrade slack
}

install_docker() {
  brew_cask_install_or_upgrade docker
  
  idempotent_append_to_profile "alias d=docker"
  idempotent_append_to_profile "alias dc=docker-compose"
  reload_profile
}

install_authy() {
  brew_cask_install_or_upgrade authy
}

install_virtualbox() {
  brew_cask_install_or_upgrade virtualbox
}

install_firefox() {
  brew_cask_install_or_upgrade firefox
}

install_dotnetcore() {
  brew_cask_install_or_upgrade dotnet-sdk
}

install_git() {
  brew_install_or_upgrade git
}

install_npm() {
  brew_install_or_upgrade npm
}

install_nss() {
  brew_install_or_upgrade nss
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
  brew_install_or_upgrade go
}

install_iterm2() {
  brew_cask_install_or_upgrade iterm2
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
  
  brew_cask_install_or_upgrade font-hack-nerd-font
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
  brew_install_or_upgrade ruby

  idempotent_append_to_profile 'export PATH="/usr/local/opt/ruby/bin:$PATH"'
  reload_profile
}

install_colorls() {
  if ! gem list colorls | grep colorls >/dev/null; then
    gem install colorls
  else
    println "Colorls gem already installed...updating!"
    gem update colorls
  fi

  idempotent_append_to_profile "export PATH=\""'$PATH:$(ruby -e '"'puts Gem.bindir')\""
  idempotent_append_to_profile "source $(dirname $(gem which colorls))/tab_complete.sh"
  idempotent_append_to_profile "alias ls='colorls'"
  idempotent_append_to_profile "alias ll='colorls -lA --sd'"
  reload_profile
}

install_aws_cli() {
  brew_install_or_upgrade awscli
}

install_gcp_sdk() {
  brew_cask_install_or_upgrade google-cloud-sdk

  ## ZSH Specific
  idempotent_append_to_zprofile 'source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"'
  idempotent_append_to_zprofile 'source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"'
  idempotent_append_to_profile "alias gc=gcloud"
}

install_rectangle() {
  brew_cask_install_or_upgrade rectangle
}

install_mysql_client() {
  brew_install_or_upgrade mysql-client

  idempotent_append_to_profile 'export PATH="/usr/local/opt/mysql-client/bin:$PATH"'
  reload_profile
}

install_terraform() {
  brew_install_or_upgrade terraform
  
  idempotent_append_to_profile "alias tf=terraform"
  reload_profile
}

install_postman() {
  brew_cask_install_or_upgrade postman
}

install_tree() {
  brew_install_or_upgrade tree
}

install_java() {
  brew_install_or_upgrade java
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
