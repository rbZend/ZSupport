# zs-recoverZPK

A tool designed to list and/or extract ZPK files from Zend Server's database.

`zs-recoverZPK [parameters]`

Parameters:

       -s, --source
           database source. One of:
           sqlite://path/to/deployment.db
           mysql://user:password@host[:port]/database

       -z, --zpkID
           ID of the package that needs to be recovered. If ZPK ID (package ID)
           is not specified, the tool will display the list of applications
            in the database.

       -o, --otputDir        default = . (current directory)
           directory where the ZPK will be saved

Example:

       $ cd /usr/local/zend/bin
       $ zs-recoverZPK --zpkID=17 --source=sqlite://../var/db/deployment.db -o ~/Desktop
