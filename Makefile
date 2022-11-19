.PHONY: build fixlinks


build:
	mkdocs build
	./fixlinks.sh
	rm -rf .build
	mkdir -p .build/blacksheep
	mv site/* .build/blacksheep
	echo "Ready to publish"


build-v1:
	mkdocs build
	VERSION="v1" ./fixlinks.sh
	rm -rf .build
	mkdir -p .build/blacksheep/v1
	mv site/* .build/blacksheep/v1
	echo "Ready to publish"


# requires env variable PYAZ_ACCOUNT_KEY
publish-dev:
	pyazblob upload --path .build/ --account-name "neoteroideveuwstacc" -cn "\$web" -r -f


fixlinks:
	./fixlinks.sh


clean:
	rm -rf site/
	rm -rf .build/
