all: release deploy 

release:
	grunt release

deploy: release
	@echo Syncing release folder with Amazon S3
	s3cmd sync release/ s3://vertigo-test1

clean:
	grunt clean

ls:
	s3cmd ls s3://vertigo-test1

.PHONY: all
