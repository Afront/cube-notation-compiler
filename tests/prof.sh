#!/usr/bin/env bash

args="$@"

_help="
Help: $(basename $0) [options]

Options:
	profile	<options> Profiles the program, and then prints the dump file
	print <limit>	Prints the newest dump file
"


function profile {
	cd ..
	if [[ "$1" == "--without-type-checking" ]]; then
		bundle exec ruby tests/prof.rb
	else
		export RBS_TEST_TARGET='Token,TurnToken,CodeTkn,Char,Lexer,Parser,CodeGenerator,CodeOptimizer,TargetCodeGenerator,Interpreter'
		bundle exec ruby -r bundler/setup -r rbs/test/setup tests/prof.rb
	fi

	cd tests
}

function print {
	cd ""$(cd $(dirname $0) && pwd)"/tmp/prof" || exit
	echo "$(ls -t | head -n1)"
	bundle exec stackprof "$(ls -t | head -n1)" --text --limit $1
}

if [ $# -eq 0 ]
then
	profile
	print
else
	if [[ "$1" == "profile" ]]; then
		profile $2
		print
	elif [[ "$1" == "print" ]]; then
		print $2
	elif [[ "$1" == "help" ]]; then
		echo "$_help"
	else
		print $1
	fi
fi
