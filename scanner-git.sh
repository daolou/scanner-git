#!/bin/bash

logSwitch=1
directory=""
chars="未找到终端，请安装 "
declare -a allGitRepo
declare -a apps
apps=(iTerm2 iTerm Terminal)

function debug() {
  if [ $logSwitch == 0 ]
  then
    return
  fi
  echo "debug function.name ${FUNCNAME[1]} args.length $# args.values $*"
}

function isGitRepo() {
  for info in $(ls -al "$1")
  do
    if [ "$info" == '.git' ]
    then
      return 1;
    fi
  done
  return 2;
}

function isChangeGitRepo() {
  cd "$1" || return
  if [ -z "$(git status --porcelain)" ]
  then
    return 1;
  else
    return 2;
  fi
}

function findAllGitRepoWithChange() {
  local path=$1
  isGitRepo "$path"
  if [ $? -eq 1 ]
  then
    echo "is git $path"
    isChangeGitRepo "$path"
    if [ $? -eq 2 ]
    then
      allGitRepo[${#allGitRepo[*]}]=$path
    fi
  else
    echo "not git $path"
  fi
  
  for file in $(ls "${path}")
  do
    if [[ -d $path"/"$file ]] && [[ "$file" != "output" ]] && [[ "$file" != "node_modules" ]]
    then
      findAllGitRepoWithChange "$path"/"$file"
    fi
  done
}

function openTerminal() {
  for file in "${allGitRepo[@]}"
  do
    for app in "${apps[@]}";do
      open -a "$app" "$file" 2>/dev/null
      if [[ $(echo $?) == 0 ]]; then
        echo "即将使用 $app.app 打开..."
        exit 0
      fi
      chars+=$app/
    done
    
    echo "${chars%/*}"
    exit 0
  done
}

if [ $# == 0 ]
then
  directory=$(pwd)
else
  directory=$(cd "$1" || "$1";pwd)
fi

findAllGitRepoWithChange "$directory"
debug "${allGitRepo[@]}"
openTerminal
