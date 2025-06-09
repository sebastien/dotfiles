#!/usr/bin/env gmake -f
BACKUP_PATHS+=~/.ssh
BACKUP_PATHS+=~/Workspace
BACKUP_EXCLUDE+=*.zpaq* *.zpaq .cache
include $(HOME)/Workspace/Perso/zbaq/src/mk/zbaq.mk

