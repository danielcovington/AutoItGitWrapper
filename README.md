AutoIt3Wrapper Git Versioning Patch
===================================

I use AutoIt all the time. I like to use Git to version the scripts that I write. SVN is supported in SciTE .. GIT is not. Hopefully this project will change all that. We are working towards a patch for the `AutoIt3Wrapper.au3` that will allow SciTE4AutoIt3 to utilize Git for Versioning as well as SVN.


### TODO

- [x] Disect current AutoIt3Wrapper.au3 to find dependent functions for versioning.
- [ ] Settle on command syntax for git
- [ ] implement ini changes for git
- [ ] generalize checks against SVN to be user selectable
- [ ] extend rather than re-implement Versioning already built into the Wrapper.
- [ ] add code to handle git.
- [ ] verify that the patched AutoIt3Wrapper.au3 and .exe both work on a clean install.
- [ ] Make it easy and seemless to use

These maybe a touch ambitous and you are more then welcome to contribute, criticize, and test what I have here. Hopefully if you use AutoIt and Git it will help in the end.
