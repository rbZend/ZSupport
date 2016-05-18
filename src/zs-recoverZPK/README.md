# zs-recoverZPK

A tool designed to list and/or extract ZPK files from Zend Server's database.

**`zs-recoverZPK [parameters]`**

Parameters:

       -s, --source
           database source. One of:
           sqlite://path/to/deployment.db
           mysql://user:password@protocol(host:port|path)/database

       -z, --zpkID
           ID of the package that needs to be recovered.
           If ZPK ID (package ID) is not specified, the tool will
           display the list of applications in the database.

       -o, --otputDir        default = . (current directory)
           directory where the ZPK will be saved

Examples:

`$ zs-recoverZPK --zpkID=17 --source=sqlite:///usr/local/zend/var/db/deployment.db --otputDir=~/Desktop`

`$ zs-recoverZPK -z 17 -s 'mysql://root:passw0rd@unix(/var/run/mysqld/mysqld.sock)/ZendServer'`

`$ zs-recoverZPK -z 17 -s 'mysql://root:passw0rd@tcp(192.168.5.150:13306)/ZendServer'`
