#!/bin/bash

if ! command -v zip > /dev/null 2>&1; then
    echo "ERROR: The script needs 'zip' installed in the system"
    echo
    exit 1
fi
if ! command -v unzip > /dev/null 2>&1; then
    echo "ERROR: The script needs 'unzip' installed in the system"
    echo
    exit 1
fi

function error {
    eReset='\e[0m'
    eBold='\e[1m'
    eRed='\e[31m'


    echo
    echo -e "${eRed}${eBold}$1${eReset}"
    echo
    exit 1
}

function usage {

    eReset='\e[0m'
    eBold='\e[1m'
    eDefault='\e[39m'
    eRed='\e[31m'
    eGreen='\e[32m'
    eYellow='\e[33m'
    eBlue='\e[34m'

    echo
    echo -e "${eRed}${eBold}$1${eReset}"

    cat <<EOH

Usage:

$0 <export archive> <base version> <target version> [exclusive]

        <export archive> -  full or relative path to the ZIP file generated
                            by Zend Server's "Export Configuration" feature.

        <base version>   -  the PHP version to be used as source configuration.

        <target version> -  the PHP version's configuration to generate and
                            apply (make active), based on <base version>.

        [exclusive]      -  (optional) - if set, only the <target version>
                            configuration is generated and applied. The third
                            PHP version's configuration will be left as it is,
                            if it exists, and will not be generated, if it
                            doesn't exist.

Examples:

EOH
echo -e "${eDefault}$0 ${eBlue}zs_config_2019_07_15_17_06_42.zip${eGreen} 7.1${eRed} 7.3${eReset}"
echo "  This will overwrite the configurations of PHP 7.2 and 7.3 based on PHP 7.1"
echo "  and make PHP 7.3 active."
echo
echo -e "${eDefault}$0 ${eBlue}zs_config_2019_07_15_17_06_42.zip${eGreen} 7.2${eRed} 7.3${eYellow} exclusive${eReset}"
echo "  This will overwrite only the configurations of PHP 7.3 based on PHP 7.2 and"
echo "  make PHP 7.3 active. The configuration of PHP 7.1 will not be affected."
echo
echo
exit 1
}

function ex2im {
    #  $1 - base, $2 - target
    peB="php_extensions_php_$1.sql"
    pdB="php_directives_php_$1.sql"
    zeB="zend_extensions_php_$1.sql"

    for baseFile in $peB $pdB $zeB; do
        if [ ! -f $baseFile ]; then
            error "ERROR: base version configuration ($1) missing or incomplete"
        fi
    done

    echo "Creating configuration for PHP $2:"
    peT="php_extensions_php_$2.sql"
    pdT="php_directives_php_$2.sql"
    zeT="zend_extensions_php_$2.sql"

    deprDir=(sql.safe_mode mbstring.func_overload track_errors)
    deprExt=(mcrypt)

    filterDir=''
    for directive in ${deprDir[@]}; do
        if grep -E "\('$directive'," $pdB  > /dev/null 2>&1; then
            echo "  Removing the directive '$directive'"
        fi
        filterDir=$(echo "\('$directive',|$filterDir" | sed 's@|$@@')
    done
    grep -vE "$filterDir" $pdB > $pdT

    # overkill with just one deprecated extension, still
    filterExt=''
    for extension in ${deprExt[@]}; do
        if grep -E "\('$extension'," $peB  > /dev/null 2>&1; then
            echo "  Removing the extension '$extension'"
        fi
        filterExt=$(echo "\('$extension',|$filterExt" | sed 's@|$@@')
    done
    grep -vE "$filterExt" $peB > $peT

    cp $zeB $zeT

    sed -i "s|'$1');|'$2');|g" $pdT
    sed -i "s|/php/$1/etc/|/php/$2/etc/|g" $pdT
    sed -i "s|'$1');|'$2');|g" $peT
    sed -i "s|'$1');|'$2');|g" $zeT

    # there is a slight possibility that this file also contains the full path to INI
    sed -i "s|/php/$1/etc/|/php/$2/etc/|g" $peT

}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage ""
fi
if [ ! $# -ge 3 ]; then
    usage "ERROR: at least 3 parameters are required"
fi
if [ ! -f "$1" ]; then
    usage "ERROR: $1 is not a file"
fi
if [ "$2" != "7.1" ] && [ "$2" != "7.2" ] && [ "$2" != "7.3" ]; then
    usage "ERROR: base version $2 is incorrect. Expected one of: '7.1', '7.2' or '7.3'"
fi
if [ "$3" != "7.1" ] && [ "$3" != "7.2" ] && [ "$3" != "7.3" ]; then
    usage "ERROR: target version $3 is incorrect. Expected one of: '7.1', '7.2' or '7.3'"
fi
if [ "$2" == "$3" ]; then
    error "ERROR: base version and target version are the same"
fi
if [ "$4" != "" ] && [ "$4" != "exclusive" ]; then
    usage "ERROR: 'exclusive' is the only valid option in the 4th position"
elif [ "$4" == "exclusive" ]; then
    excl=true
else
    excl=false
fi


ts="ex2im-$(date +%s)"
mkdir "/tmp/$ts" || exit 1

if ! unzip "$1" -d "/tmp/$ts" > /dev/null; then
    error "ERROR: extracting $1 failed"
fi
cd "/tmp/$ts"


ex2im $2 $3

if ! $excl; then
    ver3=$(echo -e "7.1\n7.2\n7.3" | grep -vE "$2|$3")
    ex2im $2 $ver3
fi

echo "Activating PHP $3"
sed -i "s|,7\\.[123],|,$3,|" metadata

echo "Creating the configuration archive:"
zipName="ZS_converted_configuration_${2}to${3}_$(date +%Y-%m-%d_%H.%M.%S).zip"
zip -9 $zipName * && echo "  Archive created at $PWD/$zipName"
if mv $zipName /tmp/; then
    echo "  Archive moved to /tmp/$zipName"
    cd - > /dev/null
    rm -rf "/tmp/$ts" && echo "Temporary directory /tmp/$ts removed"
    eReset='\e[0m'
    eBlue='\e[34m'
    mv /tmp/$zipName . && echo -e "Configuration archive moved to current directory\n\n   ${eBlue}$zipName${eReset}"
    echo
    echo "Done"
    echo
fi

