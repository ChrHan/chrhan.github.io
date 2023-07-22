---
layout: post
title: SECONDS is built-in variable in shell
categories: Shell TIL
tags: Shell TIL
date: 2023-06-01 15:14 +0900
cover-img: ["/assets/images/bash.svg"]
thumbnail-img: "/assets/images/bash.svg"
---
Today I Learned that `SECONDS` is indeed a built-in variable in shell when trying to time startup of Docker....

Initial idea is to create a script which:
1. Run `docker ps`
2. Check if exit code of (1) is not 0
  1. If not 0:
    1. `sleep` for 1 second
    2. Increment timer
  2. If 0, exit loop
3. Post final timer

As I did not know `SECONDS` variable is used as a built-in variable for timer, this is the initial script that I wrote:
```
    #!/bin/bash

    docker ps
    EXIT_STATUS=$?
    SECONDS=0

    while [ ${EXIT_STATUS} -eq 1 ]
    do 
        SECONDS=`expr ${SECONDS} + 1`
        echo "${SECONDS} seconds passed so far..."
        echo "sleeping for 1 seconds"
        sleep 1
        docker ps
        EXIT_STATUS=$?
    done

    echo "${SECONDS} seconds passed until docker ps succeeds!"
```

Upon running this script, I found out that my seconds incremented two times instead of 1 time, with the following log sample:
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
1 seconds passed so far...
sleeping for 1 seconds
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
3 seconds passed so far...
sleeping for 1 seconds
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
5 seconds passed so far...
sleeping for 1 seconds
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
7 seconds passed so far...
...
```

Which brings the question - `SECONDS` was only incremented by 1, but why on every loop it increments by 2?

Then I put these words into google search.....

`shell sleep alters variable`

And [the first result](https://stackoverflow.com/questions/74250921/variable-named-as-seconds-in-bash-script-automatically-changes-after-sleep-is) answers my question perfectly - with [manual link to GNU bash](https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html)

Excerpts from GNU Bash manual:
> SECONDS
This variable expands to the number of seconds since the shell was started. Assignment to this variable resets the count to the value assigned, and the expanded value becomes the value assigned plus the number of seconds since the assignment. The number of seconds at shell invocation and the current time are always determined by querying the system clock. If SECONDS is unset, it loses its special properties, even if it is subsequently reset.


Which comes to conclusion of:
1. `SECONDS` variable is doing the timer for me
2. if (1) is the case, then I can use `SECONDS` in any part of the code directly!

Final script can be found on this [GitHub link](https://github.com/ChrHan/personal-scripts/blob/main/docker-ps-timer.sh):

```
    #!/bin/bash

    # how to run:
    # docker desktop: /Applications/Docker.app/Contents/MacOS/Docker &  ./docker-ps-timer.sh

    docker ps
    EXIT_STATUS=$?
    # found by accident that SECONDS is a built-in variable
    # https://stackoverflow.com/questions/74250921/variable-named-as-seconds-in-bash-script-automatically-changes-after-sleep-is
    # SECONDS=0

    while [ ${EXIT_STATUS} -eq 1 ]
    do 
        # SECONDS=`expr ${SECONDS} + 1`
        echo "${SECONDS} seconds passed so far..."
        echo "sleeping for 1 seconds"
        sleep 1
        docker ps
        EXIT_STATUS=$?
    done

    echo "${SECONDS} seconds passed until docker ps succeeds!"
```

Which fixes the problem as seen on the log:
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
0 seconds passed so far...
sleeping for 1 seconds
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
1 seconds passed so far...
sleeping for 1 seconds
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
2 seconds passed so far...
sleeping for 1 seconds
Error response from daemon: dial unix docker.raw.sock: connect: no such file or directory
3 seconds passed so far...
...
10 seconds passed until docker ps succeeds!
```

Lesson learned - RTFM!
