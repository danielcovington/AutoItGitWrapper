AutoIt3Wrapper Git Versioning Patch
===================================

working towards a patch for the `AutoIt3Wrapper.au3` that will allow SciTE4AutoIt3 to utilize Git for Versioning as well as SVN.


### TODO

- [ ] Disect current AutoIt3Wrapper.au3 to find dependent functions for versioning.
- [ ] Settle on command syntax for git
- [ ] implement ini changes for git
- [ ] generalize checks against SVN to be user selectable
- [ ] add code to handle git
- [ ] verify that the patched AutoIt3Wrapper.au3 and .exe both work on a clean install.