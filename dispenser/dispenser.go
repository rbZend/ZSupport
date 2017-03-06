package main

import (
	"bufio"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"syscall"
	"time"

	"gopkg.in/yaml.v2"
)

func check(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

type inputDef struct {
	ID         string
	Input      string
	Output     string
	DumpBuffer int      `yaml:"dump_buffer"`
	DumpUpon   []string `yaml:"dump_upon,omitempty"`
	FullOutput bool     `yaml:"full_output,omitempty"`
	RotateAt   int      `yaml:"rotate_at,omitempty"`
	Filters    map[string][]string
}

type dispenserConf struct {
	Reload     string
	CPU        int
	OutputFull map[string]string `yaml:"output_full,omitempty"`
	Candy      []inputDef
}

var config dispenserConf
var channels map[string]chan []string

func main() {

	settingsFile := "dispenser.yaml"
	if len(os.Args) > 1 {
		settingsFile = os.Args[1]
	}

	config = readConfig(settingsFile)
	runtime.GOMAXPROCS(config.CPU)
	channels = make(map[string]chan []string, len(config.Candy))

	for _, input := range config.Candy {
		fmt.Printf("Starting %s. Filters: %v\n", input.ID, input.Filters)
		if input.FullOutput {
			writeBuffer, err := strconv.Atoi(config.OutputFull["write_buffer"])
			check(err)

			channels[input.ID] = make(chan []string, writeBuffer+30)

			// launch full output listener goroutine
			if config.OutputFull["type"] == "file" {
				go writeFullToFile(input.ID)
			} else if config.OutputFull["type"] == "bolt" {
				//TODO: bolt support
				// go writeToBolt(stream.ID)
			}

		}
		go filterStream(input)

	}

	for {
		d, _ := time.ParseDuration("300ms")
		time.Sleep(d)
	}

}

func readConfig(configPath string) (config dispenserConf) {
	var in []byte

	in, err := ioutil.ReadFile(configPath)
	check(err)
	yaml.Unmarshal(in, &config)
	return

}

func fileOpenOrCreate(filePathAndName string, pipe bool) (f *os.File) {
	if pipe {
		// check whether the pipe exists and create if it doesn't
		fCheck, err := os.Stat(filePathAndName)
		if os.IsNotExist(err) {
			if _, err = os.Stat(filepath.Dir(filePathAndName)); os.IsNotExist(err) {
				err = os.MkdirAll(filepath.Dir(filePathAndName), 0777)
				check(err)
			}
			err = syscall.Mknod(filePathAndName, 0666|syscall.S_IFIFO, 0)
			check(err)
			fCheck, err = os.Stat(filePathAndName)
			check(err)
			err = os.Chmod(filePathAndName, 0666)
		}
		check(err)
		if fCheck.Mode()&os.ModeNamedPipe == 0 {
			panic("Input is not a named pipe :(")
		}

		// open input and output and prepare for work
		f, err = os.OpenFile(filePathAndName, os.O_RDWR, os.ModeNamedPipe)
		check(err)
	} else {
		// try to open an existing file
		f, err := os.OpenFile(filePathAndName, os.O_APPEND|os.O_RDWR, os.ModeAppend)
		if err != nil {
			// try to simply create the file
			f, err = os.Create(filePathAndName)
			if _, badPath := err.(*os.PathError); badPath {
				// if create failed and error is of type PathError, create path first
				err = os.MkdirAll(filepath.Dir(filePathAndName), 0777)
				check(err)
				// then retry creating the file
				f, err = os.Create(filePathAndName)
			}
			check(err)
			//err = os.Chmod(filePathAndName, 0666)
			//check(err)

			// right now I can't figure out
			// why f needs to be used after definition in this case,
			// hence this dummy sync
			f.Sync()
		}
	}
	return
}

func filterStream(stream inputDef) {
	// open input and output and prepare for work
	inFile := fileOpenOrCreate(stream.Input, true)
	outFile := fileOpenOrCreate(stream.Output, false)
	defer inFile.Close()
	defer outFile.Close()

	rotateMB := stream.RotateAt * 1048576

	lineBuffer := make([]string, stream.DumpBuffer)

	var scanner = bufio.NewReader(inFile)

	//var byteline []byte
	var line string

	for {
		byteline, _, err := scanner.ReadLine()
		line = string(byteline)
		if err == io.EOF {
			// we shouldn't end up here
			fmt.Print(".")
			continue
		}

		if line != "" {
			// whatever comes in goes into buffer
			lineBuffer = lineBuffer[1:]
			lineBuffer = append(lineBuffer, line)

			// by default the line goes into the log
			pass := true
			matchesShow := false
			matchesHide := false

			// but if there are filters in "show", the default is to not log
			if len(stream.Filters["show"]) > 0 {
				pass = false
				matchesShow = func() bool {
					for _, filter := range stream.Filters["show"] {
						if strings.Contains(line, filter) {
							return true
						}
					}
					return false
				}()
			}

			// "show" has priority over "hide"
			if !matchesShow {
				matchesHide = func() bool {
					for _, filter := range stream.Filters["hide"] {
						if strings.Contains(line, filter) {
							return true
						}
					}
					return false
				}()
			}

			pass = (pass || matchesShow) && !matchesHide

			// if the line matches one of the dump trigger patterns,
			// we're dumping the buffer into the log
			// (the last line of the dump is then the trigger)
			for _, dumpString := range stream.DumpUpon {
				if strings.Contains(line, dumpString) {

					dumpBlock := "** v BEGIN DUMP v ***********************************************\n"
					for i := 0; i < stream.DumpBuffer; i++ {
						if lineBuffer[i] != "" {
							dumpBlock += "**  " + lineBuffer[i] + "\n"
						}
					}
					dumpBlock += "** ^ END DUMP ^ *************************************************\n"

					outFile.WriteString(dumpBlock)
					// empty buffer
					lineBuffer = make([]string, stream.DumpBuffer)

					pass = false
					break
				}
			}

			if pass {
				outFile.WriteString(line + "\n")
			}

			if stream.FullOutput {
				ts := strconv.FormatInt(time.Now().UnixNano(), 10)
				msg := line
				channels[stream.ID] <- []string{ts, msg}
			}
		}
		if rotateMB > 0 {
			if stat, _ := outFile.Stat(); stat.Size() > int64(rotateMB) {
				outFile.Close()
				timestamp := time.Now().Format("2006-01-02__15_04_05.9999")
				err := os.Rename(stream.Output, stream.Output+".rotated."+timestamp)
				check(err)
				outFile = fileOpenOrCreate(stream.Output, false)
			}
		}
	}
}

func writeFullToFile(id string) {
	fullFilePath := config.OutputFull["path"] + fmt.Sprintf("%c", os.PathSeparator) + id + "-full.output"
	fullFile := fileOpenOrCreate(fullFilePath, false)
	dur, _ := time.ParseDuration("100ms")
	var shuttle []string
	var contents string
	bufferSize, _ := strconv.Atoi(config.OutputFull["write_buffer"])
	countDown := bufferSize
	timeout, _ := strconv.Atoi(config.OutputFull["write_timeout"])
	timeout64 := int64(timeout)
	startTime := int64(0)
	// here megabyte = 1024*1024 bytes
	rotateCap, _ := strconv.Atoi(config.OutputFull["cap"])
	rotateMB := rotateCap * 1048576

	for {
		select {
		case shuttle = <-channels[id]:
			countDown--
			if startTime == int64(0) {
				startTime = time.Now().Unix()
			}
			contents += shuttle[0] + " | " + shuttle[1] + "\n"
			if countDown < 1 {
				fullFile.WriteString(contents)
				fullFile.Sync()
				countDown = bufferSize
				startTime = int64(0)
				contents = ""
			}
		default:
			if (startTime != int64(0)) && ((time.Now().Unix() + timeout64) > startTime) {
				fullFile.WriteString(contents)
				fullFile.Sync()
				countDown = bufferSize
				startTime = int64(0)
				contents = ""
			}
			time.Sleep(dur)
		}
		if stat, _ := fullFile.Stat(); stat.Size() > int64(rotateMB) {
			// rotating regardless of current activity
			// may be moved to 'default:' above - to rotate when idle
			fullFile.Close()
			timestamp := time.Now().Format("2006-01-02__15_04_05.9999")
			err := os.Rename(fullFilePath, fullFilePath+".rotated."+timestamp)
			check(err)
			// TODO: makes sense to compress the rotated file
			// go zipRotatedFile(fullFilePath+".rotated."+timestamp)
			fullFile = fileOpenOrCreate(fullFilePath, false)
		}

	}

}
