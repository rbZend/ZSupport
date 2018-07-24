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
.. 110) ZS 8.5 - 32 bit               .. 322) ZS 8.5 - 32 bit (openSSL 1.0)
   111) ZS 8.5 - 64 bit                  323) ZS 8.5 - 32 bit (Apache 2.4)
   112) ZS 8.5 - 64 bit (Apache 2.4)     324) ZS 8.5 - 64 bit (openSSL 1.0)
   113) ZS 8.5 - power8 (LE)             325) ZS 8.5 - 64 bit (Apache 2.4)
.. 114) ZS 9.0 - 64 bit                  326) ZS 8.5 - power8 (LE)
   115) ZS 9.0 - power8 (LE)          .. 327) ZS 9.0 - 64 bit
.. 116) ZS 9.1 - 64 bit                  328) ZS 9.0 - power8 (LE)
   117) ZS 9.1 - power8 (LE)          .. 329) ZS 9.1 - 64 bit
.. 118) ZS 2018.0 - 64 bit               330) ZS 9.1 - power8 (LE)
   119) ZS 2018.0 - power8 (LE)       .. 331) ZS 2018.0 - Apache 2.4
                                         332) ZS 2018.0 - Debian 9
 SLES / OpenSUSE                         333) ZS 2018.0 - openSSL 1.1 (*)
.. 209) ZS 8.5 - 32 bit                  334) ZS 2018.0 - power8 (LE)
   210) ZS 8.5 - 64 bit
                                              (*) - Ubuntu 18.04

   c) Cancel

EOS

echo -e "Input your selection [c] : \c"
read -r choice
else
choice=$1
fi

case $choice in
	# RHEL
	("110") export ZS="8.5"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("111") export ZS="8.5"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;
	("112") export ZS="8.5"; export FL=rpm_apache2.4; export Rs="x86_64|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;
	("113") export ZS="8.5"; export FL=rpm_apache2.4; export Rs="ppc64le|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="ppc64";;

	("114") export ZS="9.0"; export FL=rpm_apache2.4; export Rs="x86_64|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;
	("115") export ZS="9.0"; export FL=rpm_apache2.4; export Rs="ppc64le|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="ppc64";;

	("116") export ZS="9.1"; export FL=rpm_apache2.4; export Rs="x86_64|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;
	("117") export ZS="9.1"; export FL=rpm_apache2.4; export Rs="ppc64le|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="ppc64";;

	("118") export ZS="2018.0"; export FL=rpm_apache2.4; export Rs="x86_64|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;
	("119") export ZS="2018.0"; export FL=rpm_apache2.4; export Rs="ppc64le|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="ppc64";;

	# SLES
	("209") export ZS="8.5"; export FL=sles; export Rs="i586|noarch"; export OS="SUSE"; export ARCH="32bit";;
	("210") export ZS="8.5"; export FL=sles; export Rs="x86_64|noarch"; export OS="SUSE"; export ARCH="64bit";;

	# Debian
	("322") export ZS="8.5"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="32bit";;
	("323") export ZS="8.5"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="32bit";;
	("324") export ZS="8.5"; export FL=deb_ssl1.0; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-openSSL_1.0"; export ARCH="64bit";;
	("325") export ZS="8.5"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="64bit";;
	("326") export ZS="8.5"; export FL=deb_power8; export Rs=".*_all.deb$|.*_ppc64el.deb$|dists/.*"; export OS="Debian-power8"; export ARCH="ppc64";;

	("327") export ZS="9.0"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="64bit";;
	("328") export ZS="9.0"; export FL=deb_power8; export Rs=".*_all.deb$|.*_ppc64el.deb$|dists/.*"; export OS="Debian-power8"; export ARCH="ppc64";;

	("329") export ZS="9.1"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="64bit";;
	("330") export ZS="9.1"; export FL=deb_power8; export Rs=".*_all.deb$|.*_ppc64el.deb$|dists/.*"; export OS="Debian-power8"; export ARCH="ppc64";;

	("331") export ZS="2018.0"; export FL=deb_apache2.4; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Apache_2.4"; export ARCH="64bit";;
	("332") export ZS="2018.0"; export FL=deb_debian9; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-Debian_9"; export ARCH="ppc64";;
	("333") export ZS="2018.0"; export FL=deb_ssl1.1; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian-openSSL_1.1"; export ARCH="64bit";;
	("334") export ZS="2018.0"; export FL=deb_power8; export Rs=".*_all.deb$|.*_ppc64el.deb$|dists/.*"; export OS="Debian-power8"; export ARCH="ppc64";;

	(""|"c")  echo "  Exiting..." ; exit 0;; 
	(*) echo "  Your input was not recognised." ; echo "  Exiting..." ; exit 1
esac

wget -nv http://repos.zend.com/zend.key -O zend.key

mkdir -p $OS-ZS$ZS
cd $OS-ZS$ZS || exit
wget -nv -O - http://repos.zend.com/zend-server/$ZS/files.lst | grep -E "^$FL/($Rs)" > ZS$ZS-$OS-$ARCH-repo-files.list

if [ "$(uname)" = "Darwin" ]; then
	sed -i "" "s@^$FL/@@g" ZS$ZS-$OS-$ARCH-repo-files.list
else
	# i.e. Linux
	sed -i "s@^$FL/@@g" ZS$ZS-$OS-$ARCH-repo-files.list
	eReset='\e[0m'
	eBold='\e[1m'
	eDim='\e[2m'
	eLink='\e[4m'
	eRed='\e[31m'
	eGreen='\e[32m'
	eYellow='\e[33m'
	eDefault='\e[39m'
fi

while read -r file
do
    dirname=$(dirname "$file")
	mkdir -p "$dirname"
	wget  -P "$dirname" -nv "http://repos.zend.com/zend-server/$ZS/$FL/$file"
done < ZS$ZS-$OS-$ARCH-repo-files.list

cd ..

if [ $# -eq 0 ]
then

echo -e "${eBold}${eRed}"
cat <<EOT



This directory ( $PWD )
 needs to be made accessible over HTTP.
Please either configure your web server to use this directory
 or move it into a directory that is accessible over HTTP.


EOT
echo -e "${eReset}Please enter the URL of this directory - it will be used to output the repository file's contents."
echo -e "For example: ${eYellow}http://${eBold}192.168.0.17/ZS_local_repo${eDefault}"
echo
echo -e "${eLink}http://\c"
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


echo -e "${eReset}Save the text between the lines as ${eBold}$repoFile${eReset} :"

echo -e "${eDim}-------------------------------------------------------------${eReset}${eGreen}"
echo -e "$repoText"
echo -e "${eReset}${eDim}-------------------------------------------------------------${eReset}"

fi

exit 0

cat << EOS
================================================
Old repos:
================================================

   101) ZS 5.6 - 32 bit                  301) ZS 5.6 - 32 bit (openSSL 0.9.8)
   102) ZS 5.6 - 64 bit                  302) ZS 5.6 - 64 bit (openSSL 0.9.8)
.. 103) ZS 6.3 - 32 bit               .. 303) ZS 6.3 - 32 bit (openSSL 0.9.8)
   104) ZS 6.3 - 64 bit                  304) ZS 6.3 - 32 bit (openSSL 1.0)
.. 105) ZS 7.0 - 32 bit                  305) ZS 6.3 - 32 bit (Apache 2.4)
   106) ZS 7.0 - 64 bit                  306) ZS 6.3 - 64 bit (openSSL 0.9.8)
.. 107) ZS 8.0 - 32 bit                  307) ZS 6.3 - 64 bit (openSSL 1.0)
   108) ZS 8.0 - 64 bit                  308) ZS 6.3 - 64 bit (Apache 2.4)
   109) ZS 8.0 - 64 bit (Apache 2.4)     309) ZS 7.0 - 32 bit (openSSL 0.9.8)
                                         310) ZS 7.0 - 32 bit (openSSL 1.0)
   201) ZS 5.6 - 32 bit                  311) ZS 7.0 - 32 bit (Apache 2.4)
   202) ZS 5.6 - 64 bit                  312) ZS 7.0 - 64 bit (openSSL 0.9.8)
   203) ZS 6.3 - 32 bit                  313) ZS 7.0 - 64 bit (openSSL 1.0)
   204) ZS 6.3 - 64 bit..                314) ZS 7.0 - 64 bit (Apache 2.4)
   205) ZS 7.0 - 32 bit               .. 315) ZS 8.0 - 32 bit (openSSL 0.9.8)
   206) ZS 7.0 - 64 bit                  316) ZS 8.0 - 32 bit (openSSL 1.0)
   207) ZS 8.0 - 32 bit                  317) ZS 8.0 - 32 bit (Apache 2.4)
   208) ZS 8.0 - 64 bit                  318) ZS 8.0 - 64 bit (openSSL 0.9.8)
                                         319) ZS 8.0 - 64 bit (openSSL 1.0)
                                         320) ZS 8.0 - 64 bit (Apache 2.4)
                                         321) ZS 8.0 - power8
                                         


	("101") export ZS="5.6"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("102") export ZS="5.6"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;
	("103") export ZS="6.3"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("104") export ZS="6.3"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;
	("105") export ZS="7.0"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("106") export ZS="7.0"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;
	("107") export ZS="8.0"; export FL=rpm; export Rs="i386|noarch"; export OS="RHEL"; export ARCH="32bit";;
	("108") export ZS="8.0"; export FL=rpm; export Rs="x86_64|noarch"; export OS="RHEL"; export ARCH="64bit";;
	("109") export ZS="8.0"; export FL=rpm_apache2.4; export Rs="x86_64|noarch"; export OS="RHEL-Apache_2.4"; export ARCH="64bit";;

	("201") export ZS="5.6"; export FL=sles; export Rs="ZendServer-i586|ZendServer-noarch"; export OS="SUSE"; export ARCH="32bit";;
	("202") export ZS="5.6"; export FL=sles; export Rs="ZendServer-x86_64|ZendServer-noarch"; export OS="SUSE"; export ARCH="64bit";;
	("203") export ZS="6.3"; export FL=sles; export Rs="ZendServer-i586|ZendServer-noarch"; export OS="SUSE"; export ARCH="32bit";;
	("204") export ZS="6.3"; export FL=sles; export Rs="ZendServer-x86_64|ZendServer-noarch"; export OS="SUSE"; export ARCH="64bit";;
	("205") export ZS="7.0"; export FL=sles; export Rs="i586|noarch"; export OS="SUSE"; export ARCH="32bit";;
	("206") export ZS="7.0"; export FL=sles; export Rs="x86_64|noarch"; export OS="SUSE"; export ARCH="64bit";;
	("207") export ZS="8.0"; export FL=sles; export Rs="i586|noarch"; export OS="SUSE"; export ARCH="32bit";;
	("208") export ZS="8.0"; export FL=sles; export Rs="x86_64|noarch"; export OS="SUSE"; export ARCH="64bit";;

	("301") export ZS="5.6"; export FL=deb; export Rs=".*_all.deb$|.*_i386.deb$|dists/.*"; export OS="Debian"; export ARCH="32bit";;
	("302") export ZS="5.6"; export FL=deb; export Rs=".*_all.deb$|.*_amd64.deb$|dists/.*"; export OS="Debian"; export ARCH="64bit";;
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
	("321") export ZS="8.0"; export FL=deb_power8; export Rs=".*_all.deb$|.*_ppc64el.deb$|dists/.*"; export OS="Debian-power8"; export ARCH="ppc64";;



================================================
EOS
