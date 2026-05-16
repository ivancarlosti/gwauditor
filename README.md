# Google Workspace admin script (gwadmin)
A PowerShell launcher for common Google Workspace administration tasks driven by [GAM](https://github.com/GAM-team/GAM/). Designed around offboarding-style operations: archiving a user's mailbox into a group, moving their Drive content into a Shared Drive, transferring their calendars and event-organizer rights to another account, and managing mailbox delegation.

<!-- buttons -->
[![Stars](https://img.shields.io/github/stars/ivancarlosti/gwauditor?label=⭐%20Stars&color=gold&style=flat)](https://github.com/ivancarlosti/gwauditor/stargazers)
[![Watchers](https://img.shields.io/github/watchers/ivancarlosti/gwauditor?label=Watchers&style=flat&color=red)](https://github.com/sponsors/ivancarlosti)
[![Forks](https://img.shields.io/github/forks/ivancarlosti/gwauditor?label=Forks&style=flat&color=ff69b4)](https://github.com/sponsors/ivancarlosti)
[![Downloads](https://img.shields.io/github/downloads/ivancarlosti/gwauditor/total?label=Downloads&color=success)](https://github.com/ivancarlosti/gwauditor/releases)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ivancarlosti/gwauditor?label=Activity)](https://github.com/ivancarlosti/gwauditor/pulse)  
[![GitHub Issues](https://img.shields.io/github/issues/ivancarlosti/gwauditor?label=Issues&color=orange)](https://github.com/ivancarlosti/gwauditor/issues)
[![License](https://img.shields.io/github/license/ivancarlosti/gwauditor?label=License)](LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/ivancarlosti/gwauditor?label=Last%20Commit)](https://github.com/ivancarlosti/gwauditor/commits)
[![Security](https://img.shields.io/badge/Security-View%20Here-purple)](https://github.com/ivancarlosti/gwauditor/security)  
[![Code of Conduct](https://img.shields.io/badge/Code%20of%20Conduct-2.1-4baaaa)](https://github.com/ivancarlosti/gwauditor?tab=coc-ov-file)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/ivancarlosti?label=GitHub%20Sponsors&color=ffc0cb)][sponsor]
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00)][buymeacoffee]
[![Patreon](https://img.shields.io/badge/Patreon-f96854)][patreon]
<!-- endbuttons -->

## Features

The launcher exposes a numbered menu. Each item validates the admin account, the source mailbox, and (where applicable) the target before running its GAM command.

1. **Copy mailbox messages to a group** — archives every message from a user mailbox into a Google Group's archive.
   ```
   gam user <source> archive messages <targetGroup> max_to_archive 0 doit
   ```
2. **Move Drive content to a new Shared Drive** — creates a fresh Shared Drive named `Migrated from <source> - <datetime>` and moves the source user's My Drive content into it.
   ```
   gam user <admin>  create teamdrive "Migrated from <source> - <datetime>"
   gam user <admin>  add drivefileacl <sdid> user <source> role organizer
   gam user <source> move drivefile root teamdriveparentid <sdid> mergewithparent
   ```
3. **Transfer calendars to another account** — reassigns secondary calendars and, for the primary calendar (which Google won't let you transfer), reassigns the organizer of all *future* events to the target user. After this runs, the target user can cancel those events and Google will send proper cancellation notices to invitees, even if the source user is later deleted.
   ```
   gam user <source> transfer calendars <target>
   gam user <source> update event <eventid> calendar primary newowner <target>
   ```
4. **List / add / remove mailbox delegation** — manage who has delegated access to a mailbox.
   ```
   gam user <source> show delegates
   gam user <source> add delegates <delegate>
   gam user <source> del delegates <delegate>
   ```
5. **Change GAM project** — re-select which GAM multi-project profile to use.
6. **Exit script**.

## Configuration

Set variables at the top of `gwadmin.ps1` if your install differs from the defaults:
```
$GAMpath = "C:\GAM7"
$gamsettings = "$env:USERPROFILE\.gam"
$destinationpath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
```

`$GAMpath` — the GAM application folder.

`$gamsettings` — the GAM multi-project settings folder.

`$destinationpath` — where any local output ends up (currently used only for temp files).

Check `testing-guideline.md` as a suggested testing checklist.

## Instructions
* Download the latest release and extract it locally ([releases](https://github.com/ivancarlosti/gwauditor/releases/latest)).
* Adjust the variables in `gwadmin.ps1` if needed.
* Run `gwadmin.ps1` from PowerShell (right-click → Run with PowerShell, or `powershell -ExecutionPolicy Bypass -File .\gwadmin.ps1`).
* Pick a GAM project, then choose a menu option and follow the prompts.

If PowerShell blocks the script with "Running scripts is disabled on this system", see `POWERSHELL_ISSUE.md`.

## Requirements
* Windows 10+ or Windows Server 2019+
* [GAM](https://github.com/GAM-team/GAM/) installed and configured for multi-project use
* PowerShell 5.1 or later

<!-- footer -->
---

## 🧑‍💻 Consulting and technical support
* For personal support and queries, please submit a new issue to have it addressed.
* For commercial related questions, please [**contact me**][ivancarlos] for consulting costs. 

| 🩷 Project support |
| :---: |
If you found this project helpful, consider [**buying me a coffee**][buymeacoffee]
|Thanks for your support, it is much appreciated!|

[cc]: https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/adding-a-code-of-conduct-to-your-project
[contributing]: https://docs.github.com/en/articles/setting-guidelines-for-repository-contributors
[security]: https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository
[support]: https://docs.github.com/en/articles/adding-support-resources-to-your-project
[it]: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository#configuring-the-template-chooser
[prt]: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository
[funding]: https://docs.github.com/en/articles/displaying-a-sponsor-button-in-your-repository
[ivancarlos]: https://ivancarlos.me
[buymeacoffee]: https://buymeacoffee.com/ivancarlos
[patreon]: https://www.patreon.com/ivancarlos
[paypal]: https://icc.gg/donate
[sponsor]: https://github.com/sponsors/ivancarlosti
