sources=$(wildcard *.md)

all: _book pages


_book: $(sources)
	gitbook build

# build _site and push diff to gh-pages branch
# using a temporary git repo to rebase the changes onto
pages: _book
# Strategy from
# http://aaren.me/thesis/2014/10/27/auto-build-jekyll-github-pages/
	root_dir=$$(git rev-parse --show-toplevel) && \
	tmp_dir=$$(mktemp -d XXXXXXX) && \
	cd $${tmp_dir} && \
	git init --quiet && \
	git remote add origin $${root_dir} && \
	git pull --quiet origin gh-pages && \
	git rm -rf --cached --quiet * && \
	rsync -a $${root_dir}/_book/ . && \
	git add -A && git commit --quiet -m "update gh-pages" && \
	git push --quiet origin master:gh-pages && \
	rm -rf $(tmp_dir)
