package main

import (
	"archive/zip"
	"bufio"
	"database/sql"
	"encoding/xml"
	"flag"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	_ "github.com/mattn/go-sqlite3"
	"log"
	"os"
	"regexp"
	"strings"
	"time"
)

var usage string = `
A tool designed to list and/or extract ZPK files from Zend Server's database.

zs-recoverZPK [parameters]

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

       $ cd /usr/local/zend/bin
       $ zs-recoverZPK --zpkID=17 --source=sqlite://../var/db/deployment.db --otputDir=~/Desktop

       $ zs-recoverZPK -z 17 -s 'mysql://root:passw0rd@unix(/var/run/mysqld/mysqld.sock)/ZendServer'

       $ zs-recoverZPK -z 17 -s 'mysql://root:passw0rd@tcp(192.168.5.150:13306)/ZendServer'

`

var appID int = 0
var source string = ""
var outDir string = ""

func check(e error) {
	if e != nil {
		log.Fatal(e)
	}
}

func init() {
	flag.StringVar(&source, "s", "", "")
	flag.StringVar(&source, "source", "", "")
	flag.StringVar(&outDir, "o", "", "")
	flag.StringVar(&outDir, "outputDir", "", "")
	flag.IntVar(&appID, "z", 0, "")
	flag.IntVar(&appID, "zpkID", 0, "")
	flag.Usage = func() {
		fmt.Println(usage)
	}
}

func main() {
	flag.Parse()

	param := strings.SplitN(source, "://", 2)
	switch param[0] {
	default:
		fmt.Println(usage)
	case "mysql":
		// opening the DB
		db, err := sql.Open("mysql", param[1])
		check(err)
		defer db.Close()

		actionSelector(db)
	case "sqlite":
		if _, err := os.Stat(param[1]); err != nil {
			fmt.Println("\nThe specified file path either does not exist or is not accessible.\n\n")
			return
		}

		// opening the DB
		db, err := sql.Open("sqlite3", param[1])
		check(err)
		defer db.Close()

		actionSelector(db)
	}

}

// SafeFileName return safe string that can be used in file names
// ( copied from https://github.com/asaskevich/govalidator/blob/master/utils.go )
func SafeFileName(str string) string {
	name := strings.Trim(str, " ")
	separators, err := regexp.Compile(`[ &=+:/\\\(\)"]`)
	if err == nil {
		name = separators.ReplaceAllString(name, "-")
	}
	legal, err := regexp.Compile(`[^[:alnum:]_-.]`)
	if err == nil {
		name = legal.ReplaceAllString(name, "")
	}
	for strings.Contains(name, "--") {
		name = strings.Replace(name, "--", "-", -1)
	}
	return name
}

func DBprintList(db *sql.DB) {
	var SQL_list string = `SELECT package_id, name, version FROM deployment_packages
WHERE (package_id IN (SELECT package_id FROM deployment_package_data)
AND package_id IN (SELECT package_id FROM deployment_tasks_descriptors
WHERE task_descriptor_id IN (SELECT task_descriptor_id FROM deployment_apps_versions)));`
	listRows, err := db.Query(SQL_list)
	check(err)
	defer listRows.Close()
	for listRows.Next() {
		var package_id int
		var name string
		var version string
		err = listRows.Scan(&package_id, &name, &version)
		check(err)
		fmt.Printf("ID: %-6d %s (ver. %s)\n", package_id, name, version)
	}
	err = listRows.Err()
	check(err)
	fmt.Println()
}

func DBrecoverZPK(db *sql.DB) {

	// getting the list of chunks for the given package ID
	var SQL_getChunks string = "SELECT package_data_id FROM deployment_package_data WHERE package_id = ? ORDER BY package_data_id ASC"
	chunkIDs_stmt, err := db.Prepare(SQL_getChunks)
	check(err)
	defer chunkIDs_stmt.Close()

	var chunkIDs []int
	rows, err := chunkIDs_stmt.Query(appID)
	check(err)
	defer rows.Close()

	for rows.Next() {
		var package_data_id int
		err = rows.Scan(&package_data_id)
		check(err)

		chunkIDs = append(chunkIDs, package_data_id)
	}

	// if the list of chunks has zero length, the ID must be wrong
	var size int = len(chunkIDs)
	if size == 0 {
		fmt.Println("\nNo data segments found for this package ID.\n\n")
		// we'll even display the list for your convenience:
		DBprintList(db)
		return
	}

	// opening the temporary file for writing
	var tmpFile string = outDir + fmt.Sprintf("%c", os.PathSeparator) + "ZPK_TMP_output_" + time.Now().Format("2006-01-02_15.04.05") + ".zip"
	fh, err := os.OpenFile(tmpFile, os.O_RDWR|os.O_APPEND|os.O_CREATE|os.O_TRUNC, 0644)
	check(err)
	wr := bufio.NewWriter(fh)

	// getting chunks and doing buffered writing to file
	/* the buffer size is just a random guess - big chunks have the size of 716 or 1024 kB,
	so 10 MB of memory usage is probably not too much, at the same time, 10 MB means that
	there will be 4-6 disk writes for an average ZPK*/
	var bufferSize int = 10
	var chunk_blob []byte
	for key, value := range chunkIDs {

		/* Although this may be not the most efficient way, we're getting blobs one-by-one.
		Why? We trust that our developers split ZPKs into small chunks for a reason. */
		chunk_stmt, err := db.Prepare("SELECT data FROM deployment_package_data WHERE package_data_id = ? ORDER BY package_data_id ASC")
		check(err)

		err = chunk_stmt.QueryRow(value).Scan(&chunk_blob)
		check(err)

		_, err = wr.Write(chunk_blob)

		// the first chunk will always be written to disk, although the buffer is not full yet - kind of "fail early"
		if (key%bufferSize) == 0 || (key+1) == size {
			// dump buffer to disk
			err = wr.Flush()
			check(err)
			fmt.Printf("\n ... written %d chunks of %d", key+1, size)
		}

		chunk_stmt.Close()
	}

	// closing the temporary file explicitly because we're about to do stuff with it now
	fh.Close()

	// getting the original package's deployment.xml
	tmpZIP, err := zip.OpenReader(tmpFile)
	check(err)
	var xmlData []byte
	for _, f := range tmpZIP.File {
		if f.Name == "deployment.xml" {
			rc, err := f.Open()
			check(err)
			xmlData = make([]byte, f.FileInfo().Size())
			_, err = rc.Read(xmlData)
			check(err)
			rc.Close()
		}

	}
	tmpZIP.Close()

	if len(xmlData) == 0 {
		fmt.Printf("\nCould not get 'deployment.xml' from the recovered package.\nTemporary file saved as - %s\n\n", tmpFile)
		return
	}

	type AppData struct {
		AppName    string `xml:"name"`
		AppVersion string `xml:"version>release"`
	}

	var unXML AppData
	err = xml.Unmarshal(xmlData, &unXML)
	check(err)

	outFileName := fmt.Sprintf("%s-ver.%s_recovered_id%d_%s.zpk", unXML.AppName, unXML.AppVersion, appID, time.Now().Format("2006-01-02_15.04.05"))
	outFile := outDir + fmt.Sprintf("%c", os.PathSeparator) + SafeFileName(outFileName)

	err = os.Rename(tmpFile, outFile)
	check(err)

	fmt.Printf("\n\nPackage saved as %s\n\n", outFile)

}

func outputDirExist() bool {
	if outDir == "" {
		outDir = "."
	}
	dirinfo, err := os.Stat(outDir)
	if err != nil {
		fmt.Println("\nThe specified output directory either does not exist or is not accessible.\n\n")
		return false
	}
	if !dirinfo.IsDir() {
		fmt.Println("\nThe specified output directory doesn't seem to be a directory.\n\n")
		return false
	}
	return true
}

func actionSelector(db *sql.DB) {

	if appID == 0 {
		DBprintList(db)
	} else if outputDirExist() {
		DBrecoverZPK(db)
	}
}
