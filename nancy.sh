#!/bin/bash

cmd=""

case "$1" in
    help )
        echo -e "
\033[1mDESCRIPTION\033[22m

	The Nancy Command Line Interface is a unified way to manage
	database experiments.

	Nancy is a member of Postgres.ai's Artificial DBA team
	responsible for conducting experiments.

\033[1mSYNOPSYS\033[22m

	  nancy <command> [parameters]

\033[1mAVAILABLE COMMANDS\033[22m

	* help

	* prepare-database

	* prepare-workload

	* run
"
        exit 1;
        ;;
    * ) 
        if [ ! -f "./nancy_$1.sh" ]
        then
            >&2 echo "ERROR: Unknown command."
            exit 1;
        fi
        cmd="./nancy_$1.sh"
    ;;
esac

while [ -n "$1" ]
do
    cmd="$cmd $1"
    shift
done

${cmd}

