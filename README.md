# Mac App Dowloader
A simple app that downloads a .zip package with another app in it, installs it and runs.

# Usage
1. Clone repository
2. Fill Config.swift
3. Build

# How it works
1. Downloads a .zip using a link specified in Config.swift
2. Unzips it to a temporary location
3. Moves all .app packages that were present in a .zip package to the /Applications folder or any other specified in Config.swift
4. Runs the freshly installed app(s) and closes itself

# Nice to have
* Ability to delete the installer itself after the installation finishes
