#!/bin/sh
# Credits:
# - http://stackoverflow.com/a/3232082
# - http://stackoverflow.com/a/5195741

continue_script () {
    # call with a prompt string or use a default
    # 
    read -r -p "${1:-Continue? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

test_command () {
    "$@"
    local status=$?
    return $status
}

cd "$(dirname "$0")"

rm -f ./build/*
mkdir -p ./.work

echo 'build all symbols fonts...'
cp ./fonts/pomicons-regular.ttf ./build
cp ./fonts/fontawesome-regular.ttf ./build


if test_command ./scripts/fu-relocate ./fonts/octicons-regular.ttf --save-as='.work/octicons-regular-relocated.ttf' --to='0xf200' 2>&1 | awk '{print "[scripts/fu-relocate.py] " $0}'
then 
    echo $(2>&1 | awk '{print "[FAILED scripts/fu-relocate.py] " $0}')
    if ! continue_script "./fonts/octicons-regular.ttf failed to build. Continue? [y/N]"
    then
        echo "Exited."
        exit 1
    fi
fi

cp ./.work/octicons-regular-relocated.ttf ./build/octicons-regular.ttf


echo 'export maps for all fonts...'
./scripts/fu-map ./build/pomicons-regular.ttf --namespace 'POMICONS' 2> /dev/null > ./build/pomicons-regular.sh
./scripts/fu-map ./build/octicons-regular.ttf --namespace 'OCTICONS' 2> /dev/null > ./build/octicons-regular.sh
./scripts/fu-map ./build/fontawesome-regular.ttf --namespace 'AWESOME' 2> /dev/null > ./build/fontawesome-regular.sh

echo 'you can find fonts and maps in local ./build directory :-)'
echo 'done!'
