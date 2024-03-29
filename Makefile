default: test

nextify:
	bundle exec rake nextify

test: nextify
	bundle exec rake
	CI=true bundle exec rake

lint:
	bundle exec standardrb

release: test lint
	git status
	RELEASING_PACO=true gem release -t
	git push
	git push --tags
