#!/bin/bash


### TODO:
### 1. Nginx repositories cloning (subject to legal clarification)
### 2. Custom Zend Server repositories cloning (e.g. 6.3.0_update2)
### 3. This script's auto-updater
### 4. Verbose output / logging
### 5. Cloning of multiple repositories in one pass

if [ $# -eq 0 ]
then

cat <<EOS
This script will copy the selected repository to current directory:
$PWD

Select the repository to copy:


 RHEL / CentOS / OEL                   Debian / Ubuntu
.. 103) ZS 6.3 - 32 bit               .. 303) ZS 6.3 - 32 bit (openSSL 0.9.8)
   104) ZS 6.3 - 64 bit                  304) ZS 6.3 - 32 bit (openSSL 1.0)
.. 105) ZS 7.0 - 32 bit                  305) ZS 6.3 - 32 bit (Apache 2.4)
   106) ZS 7.0 - 64 bit                  306) ZS 6.3 - 64 bit (openSSL 0.9.8)
.. 107) ZS 8.0 - 32 bit                  307) ZS 6.3 - 64 bit (openSSL 1.0)
   108) ZS 8.0 - 64 bit                  308) ZS 6.3 - 64 bit (Apache 2.4)
   109) ZS 8.0 - 64 bit (Apache 2.4)  .. 309) ZS 7.0 - 32 bit (openSSL 0.9.8)
.. 110) ZS 8.5 - 32 bit                  310) ZS 7.0 - 32 bit (openSSL 1.0)
   111) ZS 8.5 - 64 bit                  311) ZS 7.0 - 32 bit (Apache 2.4)
   112) ZS 8.5 - 64 bit (Apache 2.4)     312) ZS 7.0 - 64 bit (openSSL 0.9.8)
   113) ZS 8.5 - power8 (LE)             313) ZS 7.0 - 64 bit (openSSL 1.0)
.. 114) ZS 9.0 - 64 bit                  314) ZS 7.0 - 64 bit (Apache 2.4)
   115) ZS 9.0 - power8 (LE)          .. 315) ZS 8.0 - 32 bit (openSSL 0.9.8)
                                         316) ZS 8.0 - 32 bit (openSSL 1.0)
 SLES / OpenSUSE                         317) ZS 8.0 - 32 bit (Apache 2.4)
   203) ZS 6.3 - 32 bit                  318) ZS 8.0 - 64 bit (openSSL 0.9.8)
   204) ZS 6.3 - 64 bit                  319) ZS 8.0 - 64 bit (openSSL 1.0)
   205) ZS 7.0 - 32 bit                  320) ZS 8.0 - 64 bit (Apache 2.4)
   206) ZS 7.0 - 64 bit                  321) ZS 8.0 - power8  
   207) ZS 8.0 - 32 bit               .. 322) ZS 8.5 - 32 bit (openSSL 1.0)
   208) ZS 8.0 - 64 bit                  323) ZS 8.5 - 32 bit (Apache 2.4)
   209) ZS 8.5 - 32 bit                  324) ZS 8.5 - 64 bit (openSSL 1.0)
   210) ZS 8.5 - 64 bit                  325) ZS 8.5 - 64 bit (Apache 2.4)
                                         326) ZS 8.5 - power8 (LE)
                                      .. 327) ZS 9.0 - 64 bit
                                         328) ZS 9.0 - power8 (LE)
   c) Cancel

EOS

echo -e "Input your selection [c] : \c"
read -r choice
else
choice=$1
fi

case $choice in
	# RHEL
	("103") export ZS="6.3"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("104") export ZS="6.3"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;

	("105") export ZS="7.0"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("106") export ZS="7.0"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;

	("107") export ZS="8.0"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("108") export ZS="8.0"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;
	("109") export ZS="8.0"; export FL=rpm_apache2.4; export Rs="x86_64|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;

	("110") export ZS="8.5"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("111") export ZS="8.5"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;
	("112") export ZS="8.5"; export FL=rpm_apache2.4; export Rs="x86_64|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;
	("113") export ZS="8.5"; export FL=rpm_apache2.4; export Rs="ppc64le|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;

	("114") export ZS="9.0"; export FL=rpm_apache2.4; export Rs="x86_64|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;
	("115") export ZS="9.0"; export FL=rpm_apache2.4; export Rs="ppc64le|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;

	# SLES
	("203") export ZS="6.3"; export FL=sles; export Rs="ZendServer-i586|ZendServer-noarch"; export OS="SUSE"; export ARCH="32bit";;
	("204") export ZS="6.3"; export FL=sles; export Rs="ZendServer-x86_64|ZendServer-noarch"; export OS="SUSE"; export ARCH="64bit";;

	("205") export ZS="7.0"; export FL=sles; export Rs="i586|noarch"; export OS="SUSE"; export ARCH="32bit";;
	("206") export ZS="7.0"; export FL=sles; export Rs="x86_64|noarch"; export OS="SUSE"; export ARCH="64bit";;

	("207") export ZS="8.0"; export FL=sles; export Rs="i586|noarch"; export OS="SUSE"; export ARCH="32bit";;
	("208") export ZS="8.0"; export FL=sles; export Rs="x86_64|noarch"; export OS="SUSE"; export ARCH="64bit";;

	("209") export ZS="8.5"; export FL=sles; export Rs="i586|noarch"; export OS="SUSE"; export ARCH="32bit";;
	("210") export ZS="8.5"; export FL=sles; export Rs="x86_64|noarch"; export OS="SUSE"; export ARCH="64bit";;

	# Debian
	("303") export ZS="6.3"; export FL=deb; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian"; export ARCH="32bit";;
	("304") export ZS="6.3"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="32bit";;
	("305") export ZS="6.3"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="32bit";;

	("306") export ZS="6.3"; export FL=deb; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian"; export ARCH="64bit";;
	("307") export ZS="6.3"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="64bit";;
	("308") export ZS="6.3"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="64bit";;

	("309") export ZS="7.0"; export FL=deb; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian"; export ARCH="32bit";;
	("310") export ZS="7.0"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="32bit";;
	("311") export ZS="7.0"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="32bit";;

	("312") export ZS="7.0"; export FL=deb; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian"; export ARCH="64bit";;
	("313") export ZS="7.0"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="64bit";;
	("314") export ZS="7.0"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="64bit";;

	("315") export ZS="8.0"; export FL=deb; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian"; export ARCH="32bit";;
	("316") export ZS="8.0"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="32bit";;
	("317") export ZS="8.0"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="32bit";;

	("318") export ZS="8.0"; export FL=deb; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian"; export ARCH="64bit";;
	("319") export ZS="8.0"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="64bit";;
	("320") export ZS="8.0"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="64bit";;

	("321") export ZS="8.0"; export FL=deb_power8; export Rs=".*_all.deb$|.*_ppc64el.deb$|dists/.*"; export OS="Debian-power8"; export ARCH="64bit";;

	("322") export ZS="8.5"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="32bit";;
	("323") export ZS="8.5"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="32bit";;
	("324") export ZS="8.5"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="64bit";;
	("325") export ZS="8.5"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="64bit";;
	("326") export ZS="8.5"; export FL=deb_power8; export Rs=".*_all.deb$|.*_ppc64el.deb$|dists/.*"; export OS="Debian-power8"; export ARCH="64bit";;

	("327") export ZS="9.0"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="64bit";;
	("328") export ZS="9.0"; export FL=deb_power8; export Rs=".*_all.deb$|.*_ppc64el.deb$|dists/.*"; export OS="Debian-power8"; export ARCH="64bit";;

	(""|"c")  echo "  Exiting..." ; exit 0;;
	(*) echo "  Your input was not recognised." ; echo "  Exiting..." ; exit 1
esac

wget -nv http://repos.zend.com/zend.key -O zend.key

mkdir -p $OS-ZS$ZS
cd $OS-ZS$ZS || exit
wget -nv -O - http://repos.zend.com/zend-server/$ZS/files.lst | grep -E "^$FL/($Rs)" > ZS$ZS-$OS-$ARCH-repo-files.list
sed -i "s@^$FL/@@g" ZS$ZS-$OS-$ARCH-repo-files.list

while read -r file
do
        dirname=$(dirname "$file")
	mkdir -p "$dirname"
	wget  -P "$dirname" -nv "http://repos.zend.com/zend-server/$ZS/$FL/$file"
done < ZS$ZS-$OS-$ARCH-repo-files.list

cd ..

if [ $# -eq 0 ]
then

echo -e "\e[1m\e[31m"
cat <<EOT



This directory ( $PWD )
 needs to be made accessible over HTTP.
Please either configure your web server to use this directory
 or move it into a directory that is accessible over HTTP.


EOT
echo -e "\e[0mPlease enter the URL of this directory - it will be used to output the repository file's contents."
echo -e "For example: \e[33mhttp://\e[1m192.168.0.17/ZS_local_repo\e[39m"
echo
echo -e "\e[4mhttp://\c"
read -r URL
echo
echo


repoFile="/etc/apt/sources.list.d/zend_local.list"
repoText="deb http://$URL/$OS-ZS$ZS server non-free"

if [ "$FL" = "rpm" ] || [ "$FL" = "rpm_apache2.4" ]; then
	archReal=$(cut -d"|" -f1 <<< "$Rs")
	archNo=$(cut -d"|" -f2 <<< "$Rs")
	repoFile="/etc/yum.repos.d/zend_local.repo"
	repoText="$(cat <<EORR
[Zend]\n
name=Zend Server Local Repository\n
baseurl=http://$URL/$OS-ZS$ZS/$archReal\n
enabled=1\n
gpgcheck=1\n
gpgkey=http://$URL/zend.key\n
\n
[Zend_noarch]\n
name=Zend Server Local Repository - noarch\n
baseurl=http://$URL/$OS-ZS$ZS/$archNo\n
enabled=1\n
gpgcheck=1\n
gpgkey=http://$URL/zend.key\n
EORR
)"
fi

if [ "$FL" = "sles" ]; then
	archReal=$(cut -d"|" -f1 <<< "$Rs")
	archNo=$(cut -d"|" -f2 <<< "$Rs")
	repoFile="/etc/zypp/repos.d/zend_local.repo"
	repoText="$(cat <<EOSR
[Zend]\n
name=Zend Server Local Repository\n
baseurl=http://$URL/$OS-ZS$ZS/$archReal\n
type=rpm-md\n
enabled=1\n
autorefresh=1\n
gpgcheck=1\n
gpgkey=http://$URL/zend.key\n
\n
[Zend_noarch]\n
name=Zend Server Local Repository - noarch\n
baseurl=http://$URL/$OS-ZS$ZS/$archNo\n
type=rpm-md\n
enabled=1\n
autorefresh=1\n
gpgcheck=1\n
gpgkey=http://$URL/zend.key\n
EOSR
)"
fi


echo -e "\e[0mSave the text between the lines as \e[1m$repoFile\e[0m :"

echo -e "\e[2m-------------------------------------------------------------\e[1m\e[32m"
echo -e "$repoText"
echo -e "\e[0m\e[2m-------------------------------------------------------------\e[0m"

fi

exit 0

cat << EOS
================================================
Old repos:
================================================

   101) ZS 5.6 - 32 bit                  301) ZS 5.6 - 32 bit (openSSL 0.9.8)
   102) ZS 5.6 - 64 bit                  302) ZS 5.6 - 64 bit (openSSL 0.9.8)

   201) ZS 5.6 - 32 bit               
   202) ZS 5.6 - 64 bit               

	("101") export ZS="5.6"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("102") export ZS="5.6"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;

	("201") export ZS="5.6"; export FL=sles; export Rs="ZendServer-i586|ZendServer-noarch"; export OS="SUSE"; export ARCH="32bit";;
	("202") export ZS="5.6"; export FL=sles; export Rs="ZendServer-x86_64|ZendServer-noarch"; export OS="SUSE"; export ARCH="64bit";;

	("301") export ZS="5.6"; export FL=deb; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian"; export ARCH="32bit";;
	("302") export ZS="5.6"; export FL=deb; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian"; export ARCH="64bit";;

================================================
EOS
