git清理历史版本


git clone $project_url

cp .git/config .
rm -rf .git
git init
mv config .git/
git add .
git commit -m "clean history"
git push -f origin master



