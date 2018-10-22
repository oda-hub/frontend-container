git branch | grep production > /dev/null 2>&1 && { echo "production"; exit 0; }
git branch | grep staging > /dev/null 2>&1 && { echo "staging"; exit 0; }
exit 1
