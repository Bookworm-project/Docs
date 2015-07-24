sources=$(wildcard *.md)

all: _book pages

_book: $(sources)
	rm -rf _tmp
	gitbook build

# build _book and push diff to gh-pages branch
# using a temporary git repo to rebase the changes onto
# Strategy from
# http://aaren.me/thesis/2014/10/27/auto-build-jekyll-github-pages/


pages: _book
	root_dir=$$(git rev-parse --show-toplevel) && \
	mkdir _tmp && \
	cd _tmp && \
	git init --quiet && \
	git remote add origin $${root_dir} && \
	git pull --quiet origin gh-pages && \
	git rm -rf --cached --quiet * && \
	rsync -a $${root_dir}/_book/ . && \
	git add -A && git commit --quiet -m "update gh-pages" && \
	git push origin master:gh-pages && \
	cd ..

