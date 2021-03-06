package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"github.com/go-ini/ini"
	"os"
	"path/filepath"
	"strings"
)

var usage string = `
A tool designed to compare Zend Server's "etc" directories - all .ini files, directive by directive.

Usage:
       zs-etcCompare <output mode> <old etc path> <new etc path>

"output mode" should be one of:
  help            - print these usage instructions
  human           - human-readable output
  csv             - CSV output with field names
  json            - JSON output
  html            - HTML output
  `
var result string
var iniObject *ini.File

func main() {
	flag.Parse()
	mode := flag.Arg(0)

	switch mode {
	default:
		result = usage
	case "human":
		result = produceHuman()
	case "json":
		result = produceJson()
	case "html":
		result = produceHtml()
	case "csv":
		result = produceCsv()
	}
	fmt.Printf("%s\n", result)

}

func iniList(path string, f os.FileInfo, err error) error {
	if strings.HasSuffix(path, ".ini") {
		_ = iniObject.Append(path)
	}
	return nil
}

func mergeStringMaps(m1 map[string]string, m2 map[string]string) map[string]string {
	for key, value := range m2 {
		m1[key] = value
	}
	return m1
}

func getDirectories() (string, string) {
	old := flag.Arg(1)
	new := flag.Arg(2)
	return old, new
}

func parseDir(dir string) map[string]string {
	iniObject = ini.Empty()
	_ = filepath.Walk(dir, iniList)
	sections := iniObject.SectionStrings()
	KVpairs := make(map[string]string, 1000)
	for _, section := range sections {
		KVpairs = mergeStringMaps(KVpairs, iniObject.Section(section).KeysHash())
	}
	return KVpairs
}

func getDiff() map[string]map[string]string {
	oldEtc, newEtc := getDirectories()
	var oldCfg = make(map[string]string, 1000)
	var newCfg = make(map[string]string, 1000)
	var diffCfg = make(map[string]map[string]string, 1000)

	oldCfg = parseDir(oldEtc)
	newCfg = parseDir(newEtc)

	for kN, vN := range newCfg {
		if vO, ok := oldCfg[kN]; ok {
			// directive from New exists in Old
			if vO != vN {
				diffCfg[kN] = map[string]string{"old": vO, "new": vN}
			}
			delete(oldCfg, kN)

		} else {
			// directive from New doesn't exist in Old
			diffCfg[kN] = map[string]string{"old": "__undefined__", "new": vN}
		}
	}

	// directives from Old that don't exist in New
	for kO, vO := range oldCfg {
		diffCfg[kO] = map[string]string{"old": vO, "new": "__undefined__"}
	}

	return diffCfg
}

func produceHuman() string {
	data := getDiff()
	var formatted string
	for key, values := range data {
		o, _ := values["old"]
		n, _ := values["new"]
		formatted += fmt.Sprintf("%s:\n      old:  %s\n      new:  %s\n\n", key, o, n)
	}
	return formatted
}
func produceJson() string {
	data := getDiff()
	jList, _ := json.Marshal(data)
	return fmt.Sprintf("%s", jList)
}
func produceHtml() string {
	data := getDiff()
	var formatted string = `<!DOCTYPE html>
<html>
<head>
	<title>Zend Server's "etc" comparison results</title>
	<style>
		body {background: #BDE; font: 10pt arial, sans-serif;}
		table {margin: 15px}
		th, h1 {font-weight: bold; text-align: center; background: #7BC;}
		tr:nth-child(even) {background: #CCC}
		tr:nth-child(odd) {background: #FFF}
	</style>
</head>
<body>
<h1>Zend Server's <em>etc</em> comparison results</h1>
<table>
`
	oldEtc, newEtc := getDirectories()
	formatted += fmt.Sprintf("<tr><th>Directive</th><th>Old Value<br>%s</th><th>New Value<br>%s</th></tr>\n", oldEtc, newEtc)
	for key, values := range data {
		o, _ := values["old"]
		n, _ := values["new"]
		formatted += fmt.Sprintf("<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n", key, o, n)
	}
	formatted += "</table>\n</body>"
	return formatted
}
func produceCsv() string {
	data := getDiff()
	var formatted string = "\"directive\",\"old_value\",\"new_value\"\n"
	for key, values := range data {
		o, _ := values["old"]
		n, _ := values["new"]
		formatted += fmt.Sprintf("\"%s\",\"%s\",\"%s\"\n", key, o, n)
	}
	return formatted
}
