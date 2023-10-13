#!/usr/bin/env bash

function has-keychain-environment-variable () {
    [ -n "$1" ] || printf "Missing environment variable name\n"
    local check_in_store=$(security find-generic-password -a ${USER} -D "environment variable" -s "${1}" 2>&1 | grep "svce" | cut -d \" -f 4)

    if [ -z "${check_in_store}" ] ; then
        echo 0
        return
    fi
    
    if [ ${check_in_store} == ${1} ] ; then
        echo 1
    else
        echo 0
    fi
}

function keychain-environment-variable () {
    [ -n "$1" ] || printf "Missing environment variable name\n"
    security find-generic-password -w -a ${USER} -D "environment variable" -s "${1}"
}

function set-keychain-environment-variable () {
    [ -n "$1" ] || printf "Missing environment variable name\n"
    
    printf "Input ${1} value (read README.md): "
    read -s secret
    printf "\n"
    
    ( [ -n "$1" ] && [ -n "$secret" ] ) || return 1
    security add-generic-password -U -a ${USER} -D "environment variable" -s "${1}" -w "${secret}"
}