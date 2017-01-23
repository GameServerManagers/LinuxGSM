# How to contribute to LinuxGSM

We are really glad you're reading this, because if you are then you have shown an interest in helping make LinuxGSM great.

If you haven't already, come find us on [Discord](https://gameservermanagers.com/discord). From there you will have contact with other contributers of the project. We want you working on things you're excited about.

Here are some important resources:

  * [Issues Page](https://github.com/GameServerManagers/LinuxGSM/issues) provides a list of areas that could use some work,
  * [Developing LGSM](https://github.com/GameServerManagers/LinuxGSM/wiki/Developing-LGSM) gives a detailed guide on developing LGSM,
  * [LGSM Exit Codes](https://github.com/GameServerManagers/LinuxGSM/wiki/LGSM-Exit-Codes) describes and gives an explanation for exit codes,
  * [gsquery](https://github.com/GameServerManagers/LinuxGSM/wiki/gsquery.py) describes the uses of the gsquery.py file, and
  * [Branching](https://github.com/GameServerManagers/LinuxGSM/wiki/Branching) is our final guide to submitting changes.
  
## Testing

Please make sure all the code you write is working properly **before** you create a pull request. Information on debugging can be found in the following document:
[Debug Command](https://github.com/GameServerManagers/LinuxGSM/wiki/debug)
[Debugging your code](https://github.com/GameServerManagers/LinuxGSM/wiki/Developing-LGSM#testing-and-debugging-your-code)

## Submitting changes

Please send a [GitHub Pull Request to LinuxGSM](https://github.com/GameServerManagers/LinuxGSM/pull/new/develop) with a clear list of what you've done (read more about [pull requests](https://help.github.com/articles/about-pull-requests/)). Please follow our coding conventions (below) and make sure all of your commits are atomic (one feature per commit).

Always write a clear log message for your commits. One-line messages are fine for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    > 
    > A paragraph describing what changed and its impact."
This will help us in understanding your code and determining where problems may arise.

## Coding conventions

Start reading our code and you'll get the hang of it. Explore how functions are organized and you'll see how we strive for readable code.

Please give the following document a read and adjust your code according to its specifications.
[Syntax & Coding Conventions](https://github.com/GameServerManagers/LinuxGSM/wiki/Syntax-&-Conventions)



