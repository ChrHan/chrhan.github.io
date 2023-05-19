all: install serve

install:
	bundle install

serve:
	bundle exec jekyll serve --livereload --drafts

# example: make draft DRAFT_TITLE="'new post!'"
draft:
	bundle exec jekyll draft $(DRAFT_TITLE)

# move draft to post
# example: make publish FILE_PATH="./_drafts/...md"
publish:
	bundle exec jekyll publish $(FILE_PATH)

# move post back to draft
# example: make unpublish FILE_PATH="./_posts/...md"
unpublish:
	bundle exec jekyll unpublish $(FILE_PATH)
