---
layout: post
title: "Workaround on multiple GitLab.com account and Private Terraform Module"
date: 2022-08-28 20:00:00
categories: gitlab terraform
---

# The Problem

When you have multiple credential of GitLab.com and you want to separate SSH keys used, there is no out-of-the-box / simple solution.

Your options are:
1. [Configure different host for each of your usage](https://medium.com/uncaught-exception/setting-up-multiple-gitlab-accounts-82b70e88c437#:~:text=it%20more%20memorable.-,Cloning%20repositories,-When%20cloning%20repositories) (e.g. change git host AND how you clone repositories), OR
2. [Override local git configs for each folder locally](https://medium.com/uncaught-exception/setting-up-multiple-gitlab-accounts-82b70e88c437#:~:text=add%20the%20following%20snippet)

This article assumes that you are using option 2, with addition of Terraform Modules on private repositories

When git configs are separated and Terraform needs to load modules from private repository, Terraform will perform `ssh` command, which will not use Overriden local git config
To prevent this issue, you need to add the following command before invoking `terraform`:

```
    export GIT_SSH_COMMAND='ssh -i /path/to/account/with/access'
```

For some unknown reason, local `gitconfig` which override settings would not work unless specified using `GIT_SSH_COMMAND` - using this command will ensure your terraform pulls from private git repo using correct credentials.

To make it easier, you can use the following alias on your `.bashrc` or `.zshrc` to wrap your `terraform` command with correct SSH key:

```
    alias terraform="GIT_SSH_COMMAND='ssh -i /path/to/account/with/access' terraform"
```
