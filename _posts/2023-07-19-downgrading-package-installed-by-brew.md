---
layout: post
title: Downgrading package installed by brew
categories: Shell brew TIL
tags: Shell brew TIL
date: 2023-07-19 17:59 +0900
cover-img: ["/assets/images/homebrew.svg"]
thumbnail-img: "/assets/images/homebrew.svg"
---
# Intro/Rant
![Homebrew](/assets/images/homebrew.svg) 

[Homebrew](https://brew.sh/) is one of the most famous package manager for macOS (and Linux!).

Why?

There are numerous post which will tell you all sorts of reasons (ref [#1](https://opensource.com/article/20/6/homebrew-mac), [#2](https://earthly.dev/blog/homebrew-on-m1/), [#3](https://betterprogramming.pub/how-homebrew-serves-52m-packages-per-month-413b9f0cf685)), but for simplicity sake, most tutorial for CLI stuff has `brew` as a pre-requisite!

This blogpost is not discussing about `brew`'s popular status against developers, but rather some inconvenience bug (or [feature](https://github.com/orgs/Homebrew/discussions/155#discussioncomment-133771)?) which occurs when you need specific (non-latest) version of a binary!

These steps are sourced from multiple brilliant sources (ref [#1](https://stackoverflow.com/questions/3987683/homebrew-install-specific-version-of-formula/9832084#9832084), [#2](https://nelson.cloud/how-to-install-older-versions-of-homebrew-packages/), [#3](https://dae.me/blog/2516/downgrade-any-homebrew-package-easily/))

# How-to steps

_Note: for simplicity sake, this example uses `conftest` package, in which the latest was `0.44.0` at the time of writing, and target version to downgrade is `0.34.0`_

1. Check current version of `conftest`

        conftest -v 

        Conftest: 0.44.1
        OPA: 0.54.0

1. Since our target version of `conftest` is `0.34.0`, which is lower than current version `0.44.1`, we need to look for latest commit at `homebrew` [git repository](https://github.com/Homebrew/homebrew-core/) - to find latest commit which contains version `0.34.0` - how? 

   By performing `brew info conftest`

        brew info conftest

        ==> conftest: stable 0.44.1 (bottled), HEAD
        Test your configuration files using Open Policy Agent
        https://www.conftest.dev/
        /opt/homebrew/Cellar/conftest/0.44.1 (8 files, 52.8MB) *
          Poured from bottle using the formulae.brew.sh API on 2023-07-19 at 17:31:19
        From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/conftest.rb
        License: Apache-2.0
        ==> Dependencies
        Build: go ✔
        ==> Options
        --HEAD
                Install HEAD version
        ==> Caveats
        zsh completions have been installed to:
          /opt/homebrew/share/zsh/site-functions
        ==> Analytics
        install: 0 (30 days), 0 (90 days), 0 (365 days)
        install-on-request: 0 (30 days), 0 (90 days), 0 (365 days)
        build-error: 0 (30 days)
   
   Take note of link shown in `From :`, which is now located at [https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/conftest.rb](https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/conftest.rb)

3. Find target version you want by using `brew log conftest` command. This will show `git log` of the `brew` formula selected in your favorite text editor (in CLI!) - sample output from my screen:

        commit d6d316a90b1dd580babbb7ec70b226911ab14528
        Author: BrewTestBot <1589480+BrewTestBot@users.noreply.github.com>
        Date:   Sun Jul 9 05:34:05 2023 +0000
        
            conftest: update 0.44.1 bottle.
        
        commit 37b987c8b2d4279f570024addab68cee6c5b4e70
        Author: Rui Chen <rui@chenrui.dev>
        Date:   Sun Jul 9 00:42:40 2023 -0400
        
            conftest 0.44.1
        
        commit acf20dffb41cfc9188044951f9b16cea53c7e14b
        Author: BrewTestBot <1589480+BrewTestBot@users.noreply.github.com>
        Date:   Wed Jun 7 07:50:52 2023 +0000

4. Look for target version that you want - in this example, find `0.34.0` and take note of the commit SHA:

        commit 93cc2fb873fcf4a71811d3fc34d61d58ef0b79cf
        Author: BrewTestBot <1589480+BrewTestBot@users.noreply.github.com>
        Date:   Tue Aug 2 08:05:32 2022 +0000
        
            conftest: update 0.34.0 bottle.
        
        commit debe60730f13de0d655737f776c722335d0ad073
        Author: BrewTestBot <1589480+BrewTestBot@users.noreply.github.com>
        Date:   Tue Aug 2 05:27:51 2022 +0000
        
            conftest 0.34.0
        
            Closes #107097.
       
   Since there were two commit, pick the first one(`93cc2fb873fcf4a71811d3fc34d61d58ef0b79cf`)!

5. Replace `HEAD` in the URL from Step (2) with commit SHA from Step (4).
   In this example, the combined URL is:
   [https://github.com/Homebrew/homebrew-core/blob/93cc2fb873fcf4a71811d3fc34d61d58ef0b79cf/Formula/conftest.rb](https://github.com/Homebrew/homebrew-core/blob/93cc2fb873fcf4a71811d3fc34d61d58ef0b79cf/Formula/conftest.rb)

6. Modify URL at Step (5) from `github.com` to `raw.githubusercontent.com`, and remove `/blob` so you can download the `.rb` file for further use!
   Final URL: [https://raw.githubusercontent.com/Homebrew/homebrew-core/93cc2fb873fcf4a71811d3fc34d61d58ef0b79cf/Formula/conftest.rb](https://raw.githubusercontent.com/Homebrew/homebrew-core/93cc2fb873fcf4a71811d3fc34d61d58ef0b79cf/Formula/conftest.rb)

7. Uninstall current package from `brew` 

        brew uninstall conftest

        Uninstalling /opt/homebrew/Cellar/conftest/0.44.1... (8 files, 52.8MB)

8. Download raw `.rb` file from Step 6 locally and `brew install` from the locally downloaded file
   File name must not be changed, or `brew install` will report error!

        curl https://raw.githubusercontent.com/Homebrew/homebrew-core/93cc2fb873fcf4a71811d3fc34d61d58ef0b79cf/Formula/conftest.rb > conftest.rb
        brew install conftest.rb

        ==> Downloading https://formulae.brew.sh/api/formula.jws.json
        #################################################################################################################################### 100.0%
        Error: Failed to load cask: conftest.rb
        Cask 'conftest' is unreadable: wrong constant name #<Class:0x000000010b07d080>
        Warning: Treating conftest.rb as a formula.
        ==> Fetching conftest
        ==> Downloading https://ghcr.io/v2/homebrew/core/conftest/manifests/0.34.0
        Already downloaded: /Users/chris/Library/Caches/Homebrew/downloads/4b20beaf460f5ab5e37cc63c5c3d16a970b866186fcf9993353e0722cc5b18a0--conftest-0.34.0.bottle_manifest.json
        ==> Downloading https://ghcr.io/v2/homebrew/core/conftest/blobs/sha256:e701a40383b9e466d6fb2fc4a767fdbfa36cdd6c4f864bf9b34328b36b037b17
        #################################################################################################################################### 100.0%
        Warning: conftest 0.44.1 is available and more recent than version 0.34.0.
        ==> Pouring conftest--0.34.0.arm64_monterey.bottle.tar.gz
        ==> Downloading https://formulae.brew.sh/api/cask.jws.json
        #################################################################################################################################### 100.0%
        ==> Caveats
        zsh completions have been installed to:
          /opt/homebrew/share/zsh/site-functions
        ==> Summary
        🍺  /opt/homebrew/Cellar/conftest/0.34.0: 8 files, 47.2MB
        ==> Running `brew cleanup conftest`...
        Disable this behaviour by setting HOMEBREW_NO_INSTALL_CLEANUP.
        Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).
        Removing: /Users/chris/Library/Caches/Homebrew/conftest--0.34.0... (20.9MB)

9. Check that `conftest` is now using version `0.34.0`, and pin the version to prevent auto-update from `brew install` or `brew update`

        conftest -v 
        Conftest: 0.34.0
        OPA: 0.43.0

        brew pin conftest

10. Done! Enjoy your pinned package~
