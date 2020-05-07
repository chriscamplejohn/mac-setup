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

install_chrome() {
  if ! brew cask list google-chrome >/dev/null; then
    brew cask install google-chrome
  else
    println "Chrome already installed...updating!"
    brew cask upgrade google-chrome
  fi
}

install_vscode() {
  if ! command -v code >/dev/null; then
    brew cask install visual-studio-code
  else
    println "VSCode already installed...updating!"
    brew cask upgrade visual-studio-code
  fi
}

install_slack() {
  if ! brew cask list slack >/dev/null; then
    brew cask install slack
  else
    println "Slack already installed...updating!"
    brew cask upgrade slack
  fi
}

install_docker() {
  if ! brew cask list docker >/dev/null; then
    brew cask install docker
  else
    println "Docker Desktop already installed...updating!"
    brew cask upgrade docker
  fi
}

install_authy() {
  if ! brew cask list authy >/dev/null; then
    brew cask install authy
  else
    println "Authy already installed...updating!"
    brew cask upgrade authy
  fi
}

install_virtualbox() {
  if ! brew cask list virtualbox >/dev/null; then
    brew cask install virtualbox
  else
    println "Virtualbox already installed...updating!"
    brew cask update virtualbox
  fi
}

install_firefox() {
  if ! brew cask list firefox >/dev/null; then
    brew cask install firefox
  else
    brew cask upgrade firefox
  fi
}

install_dotnetcore() {
  if ! brew cask list dotnet-sdk >/dev/null; then
    brew cask install dotnet-sdk
  else
    println "Dotnet Core SDK already installed...updating!"
    brew cask upgrade dotnet-sdk
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
