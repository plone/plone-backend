#!/usr/bin/env bash
globalTests+=(
        utc
        no-hard-coded-passwords
        override-cmd
)

imageTests+=(
	[plone/plone-backend]='
		plone-basics
		plone-site
		plone-addons
		plone-arbitrary-user
		plone-zeoclient
		plone-relstorage
	'
)

globalExcludeTests+=(
	
)
