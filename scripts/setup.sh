#!/usr/bin/env bash
type _import &>/dev/null || _import() { [ -s /tmp/${1} ] || curl -sf --compressed "https://raw.githubusercontent.com/hajimeo/samples/master/bash/$1" -o /tmp/${1}; . /tmp/${1}; }

_import "utils.sh"
_import "setup_security.sh"


usage() {
    echo "Setup and start service for Security Demo (LDAP/LDAPS, Kerberos, SAML, RUT etc.)

USAGE:
    $BASH_SOURCE
or
    $BASH_SOURCE -f <f_some_function> [-a <function arguments>]

NOTE:
  Global variables start with _ and all capital letters.
  Local variables also start with _ and all small letters.
"
}


### Global variables for this script ##########################################
: ${_APP_USER:="security-demo"}
: ${_APP_DIR:="/var/tmp/share/${_APP_USER%/}"}
: ${_NXRM_APT_PROXY:=""}
: ${_NXRM_PYPI_PROXY:=""}


### Executable functions (start with f_) #######################################
function f_apt_proxy() {
    local _url="${1:-"${_NXRM_APT_PROXY}"}"
    local _src_url="${2:-"http://archive.ubuntu.com/ubuntu/"}"
    if [ -s /etc/apt/sources.list ] && _isUrl "${_url}" "Y"; then
        sed -i.bak "s@${_src_url%/}/@${_url%/}/@g" /etc/apt/sources.list || return $?
        apt-get update || return $?
    fi
}


### main() #####################################################################
main() {
    if ! type apt-get &>/dev/null; then
        _log "ERROR" "This script is currently only for Ubuntu (20.04)"
        return 1
    fi

    # Set apt proxy repo (NXRM3)
    if ! f_apt_proxy "${_NXRM_APT_PROXY}"; then
        _log "ERROR" "Updating sources.list with ${_NXRM_APT_PROXY} failed."
        return 1
    fi
    # Install required commands:
    apt-get install -y sudo curl net-tools || return $?

    # Create non root user for the application
    if ! f_useradd "${_APP_USER}"; then
        _log "ERROR" "Adding ${_APP_USER} user failed."
        return 1
    fi

    # Install and setup OpenLDAP
    if ! f_ldap_server_install; then
        _log "ERROR" "f_ldap_server_install failed."
        return 1
    fi
    # Install and setup Kerberos to use OpenLDAP
    if ! f_kdc_install; then
        _log "ERROR" "f_kdc_install failed."
        return 1
    fi
    # Install PhpSimpleSaml
    if ! f_simplesamlphp; then
        _log "ERROR" "f_simplesamlphp failed."
        return 1
    fi
    # Install dnsmasq
    if ! f_dnsmasq; then
        _log "ERROR" "f_dnsmasq failed."
        return 1
    fi
    # TODO: Setup Apache2 with RUT
}

if [ "$0" = "$BASH_SOURCE" ]; then
    _FUNCTION_EVAL=""
    _FUNCTION_ARGS=""
    # parsing command options
    while getopts "f:a:h" opts; do
        case $opts in
            f)
                _FUNCTION_EVAL="$OPTARG"
                ;;
            a)
                _FUNCTION_ARGS="$OPTARG"
                ;;
            h)
                usage | less
                exit 0
        esac
    done

    # if -f is specified, execute that functiona and exit
    if [[ "$_FUNCTION_EVAL" =~ ^f_ ]]; then
        eval "$_FUNCTION_EVAL ${_FUNCTION_ARGS}"
        exit $?
    fi

    main
fi