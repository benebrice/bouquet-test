#!/bin/sh

#####################
### DOCUMENTATION ###
#####################
# Better Files check all files you're working on the help you to give a better work
# Default : rubocop + reek
# Call: ./better_files.sh
# Parameters: [rubocop|reek]
# Example:
#   ./better_files.sh rubocop
#   ./better_files.sh reek


#
# Check for ruby style errors
# Source: https://gist.github.com/gmodarelli/5b92589ffbe5478628cf

GIT_DIR=./
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
NC='\033[0m'

if git rev-parse --verify HEAD >/dev/null 2>&1
then
	against=HEAD
else
	# Initial commit: diff against an empty tree object
	# Change it to match your initial commit sha
	against=123acdac4c698f24f2352cf34c3b12e246b48af1
fi

# Check if rubocop is installed for the current project
echo $($GIT_DIR)
echo $(rvm list)
echo $($GIT_DIR/bin/bundle exec rubocop -v)

bin/bundle exec rubocop -v >/dev/null 2>&1 || { echo >&2 "${red}[Ruby Style][Fatal]: Add rubocop to your Gemfile"; exit 1; }
bin/bundle exec reek -v >/dev/null 2>&1 || { echo >&2 "${red}[Ruby Style][Fatal]: Add reek to your Gemfile"; exit 1; }

# Get only the staged files
FILES="$(git diff --name-only --diff-filter=AMC | grep "\.rb$" | tr '\n' ' ')"

echo "${green}[Ruby Style][Info]: Checking Ruby Style${NC}"

if [ -n "$FILES" ]
then
	echo "${green}[Ruby Style][Info]: ${FILES}${NC}"

	if [ ! -f '.rubocop.yml' ]; then
	  echo "${yellow}[Ruby Style][Warning]: No .rubocop.yml config file.${NC}"
	fi

	# Run rubocop on the staged files
  if [ "$1" = 'rubocop' ]
  then
    bin/bundle exec rubocop --auto-correct ${FILES}
  elif [ "$1" = 'reek' ]
  then
    bin/bundle exec reek ${FILES}
  else
    bin/bundle exec rubocop --auto-correct ${FILES}
    bin/bundle exec reek ${FILES}
  fi

	if [ $? -ne 0 ]; then
	  echo "${green}[Ruby Style][Work done]: Fix the issues and commit ${NC}"
	  exit 1
	fi
else
	echo "${green}[Ruby Style][Info]: No files to check${NC}"
fi

exit 0
