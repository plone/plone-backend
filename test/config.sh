#!/usr/bin/env bash
globalTests+=(
        utc
        no-hard-coded-passwords
        override-cmd
)

imageTests+=(
	[plone/plone-backend]='
		plone-basics
		plone-develop
		plone-site
		plone-addons
		plone-arbitrary-user
		plone-zeoclient
		plone-relstorage
		plone-shared-blob-dir
	'
)

globalExcludeTests+=(
	
)
