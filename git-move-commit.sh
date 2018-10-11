# This script moves 1 commit from your current branch to a new branch then switches back to your original branch
# if you specify a 2nd argument you can specify a remote master branch different to origin/master
# This is useful if you want a quick bug fix or fix an error message, but push it separately to your current work.
# You can put this in your .bashrc file in a function e.g. movecommit() so you can do `$ movecommit newbranch` from the command line.

NEW_BRANCH=$1
MASTER_BRANCH=${2:-origin/master}

ORIGINAL_BRANCH=$(git branch | grep \* | cut -d ' ' -f2) || return "$?"
COMMIT_SHA=$(git rev-parse HEAD) || return "$?"

echo 1. Stashing any outstanding work..
STASH_RESULT=$(git stash) || return "$?"

echo
echo 2. Creating new branch $NEW_BRANCH from $MASTER_BRANCH..
git checkout -b $NEW_BRANCH $MASTER_BRANCH || return "$?"

echo
echo 3. Cherry picking a single commit..
git cherry-pick $COMMIT_SHA || return "$?"

echo
echo 4. Switching back to original branch: $ORIGINAL_BRANCH
git checkout $ORIGINAL_BRANCH || return "$?"

echo
echo 5. Rolling original branch back 1 commit..
git reset --hard HEAD~1 || return "$?"

if [ "$STASH_RESULT" != "No local changes to save" ]; then
echo
	6. echo Un-stashing..
	git stash pop || return "$?"
fi
