#!/bin/bash
VERSION=$1
git archive --format=tar --prefix=kaya-$VERSION/ v$VERSION | gzip >../kaya-$VERSION.tar.gz
