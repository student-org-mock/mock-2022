#!/bin/bash

set -ex

echo "Running tests..."

source venv/bin/activate

FAILED=0
LABS=$(cat config/labs.txt)

echo "Current scope: $LABS"

for LAB_NAME in $LABS; do
  echo "Running tests for lab ${LAB_NAME}"

  IS_ADMIN=$(python config/is_admin.py --pr_name "$1")
	if [ "$REPOSITORY_TYPE" == "public" ] && [ "$IS_ADMIN" == 'YES' ] ; then
	  echo '[skip-lab] option was enabled, skipping check...'
	  continue
	fi

	TARGET_SCORE=$(bash config/get_mark.sh ${LAB_NAME})

	if [[ ${TARGET_SCORE} == 0 ]]; then
    echo "Skipping stage"
    continue
  fi

	if ! python -m pytest -m "mark${TARGET_SCORE} and ${LAB_NAME}"; then
    	FAILED=1
	fi
done

if [[ ${FAILED} -eq 1 ]]; then
	echo "Tests failed."
	exit 1
fi

echo "Tests passed."
