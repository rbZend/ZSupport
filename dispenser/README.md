# Log Dispenser

The idea of this tool is - we replace the regular log files of [Zend Server](http://www.zend.com/en/products/zend_server) with named pipes and we put the Dispenser on the receiving end of these pipes.

Now we do this - we set the maximum verbosity in all of Zend Server's components and let Dispenser process all of the messages coming in on the pipes. Based on a very simple filter (plain text match, no fancy stuff like regex) the dispenser will output only the messages of the desired log level (2 by default) into the corresponding regular log files.

So far, pretty useless, but there is more. The combination of __"show"__ and __"hide"__ filters actually allows to catch in the logs very specific messages. And they don't even have to be Zend Server logs. For example, an intranet application writes its own log files and we want the usual verbosity + any messages in any verbosity which occur around midnight - can be done.

Dispenser can also optionally output the whole incoming stream (with a timestamp) into a separate file. It will also rotate both the regular log and the full output when they reach predefined size. Rotating the logs may be useful in cases like *__php.log__*.

Dispenser has a configurable buffer for each log. This buffer can be flushed into the regular log, if the message matches one of the trigger filters (__"ERROR"__, for example). This allows us to look deeper into error conditions without consuming gigabytes of disk space for full verbosity logging.

## How to Use

For now only tested on Linux. Can probably work on macOS without modifications. They also have named pipes in Windows, but this needs some research and testing.

To run and read the configuration from *__dispenser.yaml__* in the same directory:

```
$ ./dispenser
```

Will take path to some other configuration file as an optional parameter:

```
$ ./dispenser /usr/local/zend/etc/MyDispenserConf.yaml
```

## Configuration

__WiP__

## What are these shell scripts - *setup_zs.sh* and *candy_yaml_gen.sh*?

- __setup_zs.sh__ - can be used to create a directory for pipe files and to reconfigure Zend Server to write logs into this directory. I will also add the automatic configuration of log verbosity 5 for all of Zend Server components.

- __candy_yaml_gen.sh__ - the "candy" array/object in the YAML file contains configuration for each of the pipe-log pairs. It is just hard to write each of them manually. Although now I'm thinking that I may want to rewrite the configuration structure a little, so that references can be used more in "candy".
