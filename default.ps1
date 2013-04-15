Task default -depends all

Task all -depends release, deploy

Task run -depends all {
	Exec { grunt }
}
 
Task release {
	Exec { grunt release }
}

Task deploy { # -depends release {
	Write-Host "Not currently deploying"
	# @echo Syncing release folder with Amazon S3
	# s3cmd sync release/ s3://vertigo-test1
}

Task clean {
	Exec { grunt clean }
}

Task ls {
	# s3cmd ls s3://vertigo-test1
}

Task .PHONY -depends all
