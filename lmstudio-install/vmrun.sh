#!/bin/bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 2223 tester@127.0.0.1 "export PATH=\$HOME/.lmstudio/bin:\$PATH; $*" 2>&1 | tee -a vm-notes.log
