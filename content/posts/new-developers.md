+++ 
draft = false
date = 2020-10-24T11:01:33-04:00
title = "Things I wish I knew earlier"
slug = "things-i-wish-i-knew-earlier" 
tags = ['development','programs','tips','noob']
categories = ['GitOps','Development','Engineering','noob']
+++

Recently, I've had several conversations with friends and coworkers about things we wished we knew when we were starting out as developers. Unlike lots of people in the field, I don't have a Software Engineering or Computer Science degree. 100% of what I've learned is a combination of on-the-job learning and personal project development.

Even (and especially) with my friends who do have CompSci or Software Engineering backgrounds, while there are a lot of basics that are covered and learned, there are a lot of quality-of-life tips and tricks that just aren't taught. This means that as a developer, you're crippled by the lack of knowledge on how things could be better for your development environment.

Here are just a few things that I've been able to share with people, all of which are things that have been shared with me initially.

-----

### ZSH is Amazing

<center>
<img src="/static/images/posts/new-developers/OMZLogo_BnW.png" style="width:30%;">
</center>

While the BASH shell has gotten very good, and there are plenty of things it can do, it's _nothing_ compared to ZSH.

<center>
<img src="/static/images/posts/new-developers/zsh_git.png" style="border-radius: 10px; width:60%;">
</center>

One of the best things about it is that right out of the box, it can tell you which branch of your git repo you are currently working in. Gone are the days of manually running `git branch` to ensure you're working on the correct branch. It puts that information front and center in a way that can't be missed. Additionally, there are several aliases that come prepared that I end up using often:

```bash
gloga = git log --oneline --all --graph --decorate
gba   = git branch -a
gfa   = git fetch --all --prune --jobs=10
```

While there are dozens more built in ([Check them all out here](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh)), those three are fantastic to get you started. ZSH allowed me to go from a basic terminal user with minimal information to building the terminal the way that fit my needs. Ultimately, this allows me to move more quickly.

-----

### Bash/ZSH Functions & Python Virtual Environments

While most people have probably played with Python virtualenv's in school or in testing, getting it set up and using it consistently can be annoying initially.

Assuming that you're on python3, you'd probably be running something like this every time you start a new project:

```shell
python3 -m venv .env
source .env/bin/activate
```

Similarly, you probably want to make sure you add the `.env/` directory to your `.gitignore` so you don't _accidentally_ commit python binaries and libraries to your Git repo. Can definitely be a PITA, but it's still better than installing your packages/libraries system wide.

We can make this easier with a function!

```bash
# Manage your python3 virtualenv
py3env () {
    # Check if an arg was passed for the venv directory.
    if [[ "$1" != "" ]]; then
        VENVDIR=$1
    else
        VENVDIR=".env"
    fi

    # Evaluate if Virtualenv is already active
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        echo "Virtualenv is already activated."
    else
        # Evaluate if a .env/ directory exists in the current working director
        [ -d "$(pwd)/$VENVDIR" ] && \
        ENVEXIST="True" || ENVEXIST="False"

        # If the directory does not currently exist, create it
        if [ "$ENVEXIST" = "False" ]; then
            echo "Couldn't find $(pwd)/$VENVDIR; creating it now."
            python3 -m venv $VENVDIR
        fi

        # Activate the virtual environment
        echo "Activating the virtual environment."
        source $(pwd)/$VENVDIR/bin/activate

        # Ensuring that .gitignore exists and that the $VENVDIR directory exists in the file.
        [ -f "$(pwd)/.gitignore" ] && \
        GIEXIST="True" || GIEXIST="False"

        ## Ensure the .gitignore file exists
        if [ "$GIEXIST" = "False" ]; then
            echo "Creating the .gitignore file."
        fi

        # Virtualenv Ignore Line
        VELINE="$VENVDIR"

        # Ensure the line in file exists
        if grep -Fxq "$VELINE" "$(pwd)/.gitignore"; then
            :
        else
            echo "$VELINE" >> .gitignore
            echo "Added '$VENVDIR' to the .gitignore."
        fi
    fi
}
```

Writing and adding a function like this will allow you to quickly and easily set up and activate your virtual environments without doing a whole lot.

You can scale this idea out and build additional functions to help automate bits and pieces of your workflow.

-----

### VSCode (or Atom) over a standard text editor

While applications like Notepad++ or SublimeText are fantastic, they're not full and complete IDEs for software development. Switching to something like [Visual Studio Code](https://code.visualstudio.com/) will provide you **SO** much more flexibility and capability when working on your code.

With so many available plugins, you can really build the workspace _you_ want and need, not just what Microsoft built. Being able to build your editor with plugins the way you want makes a world of difference.

I cannot stress enough here _how much your developer workspace matters_. You can't understand how efficient you can be until you get your workspace _juuuuust_ right.

Honestly, not a lot to say here, but switch to a proper IDE that you can use for multiple projects. By that I mean unless you're _only_ writing in a single language, I don't recommend working in the various JetBrains IDE applications, in my opinion.

-----

### Better Git Committing

How many times have you committed your code to your repo only to realize you have a typo or added a file by accident? Sure, you can then fix your error, and push a new commit with `fixed typo` or `removed accidental file`, but why not just use `git commit --amend`?

You can use `--amend` to edit your previous commit message and then use `git push -f` to simply fix your commit and push it back as a single commit. The workflow would look something like this in terminal:

```bash
# Changes are made; stage all commits
git stage .
# Add a commit message
git commit -m 'Adding new files'
# Push to Git
git push
# Oh wait whoops, didn't mean to commit that file!
git rm --cached README.md.old
# Gotta stage the new changes
git stage .
# Okay, time to amend my old changes!
git commit --amend
# Save with the same message, and then push it back up over your existing branch!
git push -f
```

Ultimately, amending your commits keeps everything clean for later on if you ever want/need to look back at your history, and if anyone else wants to look at your codebase and commits, it'll keep things looking really crisp.

-----

### Brace Expansion

Need to run a quick command where you need to add a bunch of files of the same filetype? Brace expansion will help you quickly complete your task!

```bash
touch directory/File-{1..5}.md

## Equates to:
touch directory/File-1.md \
    directory/File-2.md \
    directory/File-3.md \
    directory/File-4.md \
    directory/File-5.md
```

It seems really simple, but using brace expansion in various one-off commands, or even scripts, can seriously help you out when it comes to doing things efficiently.

-----

### Advanced Curl Commands

While tools like [Postman](https://www.postman.com/) exist, and are excellent, knowing and being fluent with tools like [curl](https://curl.haxx.se/) is great. It's going to be on almost any Linux system in a real environment, and knowing your way around it will absolutely help. For example, a few commands that you'll want be familiarize yourself with are `--resolve` and the combination of `-H 'Content-Type: application/json'` and `--data`.

`--resolve` can be used to query one domain name as if it's another. For example:

```bash
curl --resolve www.example.com:80:localhost http://www.example.com/
```

If we break down the `resolve` example above, we can understand that we need three colon-separated values:

- The full URL/hostname to spoof
- A TCP Port
- The target URL/hostname to resolve to

If used correctly, you'll be able to resolve one hostname as another. This can be used to bypass DNS or hit domains that aren't available on available DNS servers.

The second bit you'll want to know is how to send JSON data as a POST.

```bash
curl -H 'Content-Type: application/json' --data '{"key": "value"}' http://api.example.com/api/v1/endpoint
```

Inside of your `--data/-d` section, you can either hand-write your JSON, or you can send a file like this:

```bash
curl -H 'Content-Type: application/json' --data @file.json http://api.example.com/api/v1/endpoint
```

Generally, you'll be okay if you omit `-H 'Content-Type: application/json'`, but it can be hit or miss and can make for some difficult troubleshooting because you _assumed_ that the server was responding to your data correctly.

-----

## Additional Thoughts

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com). If something I wrote isn't clear, feel free to ask me a question or tell me to update it!
