# Google Workspace Auditor script
This script collects users, groups and Shared Drives of a Google Workspace environment on .xlsx file for audit and review purposes

## Status
<a target="_blank" href="./"><img src="https://img.shields.io/github/stars/ivancarlosti/gwauditor?style=flat" /></a>
<a target="_blank" href="./"><img src="https://img.shields.io/github/last-commit/ivancarlosti/gwauditor" /></a>
[![GitHub Issues](https://img.shields.io/github/issues/ivancarlosti/gwauditor)](https://github.com/ivancarlosti/gwauditor/issues)
[![License](https://img.shields.io/github/license/ivancarlosti/gwauditor)](LICENSE)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/ivancarlosti?label=GitHub%20Sponsors)][sponsor]
[![Security](https://img.shields.io/badge/Security-View%20Here-blue)](https://github.com/ivancarlosti/gwauditor/security)
[![Security](https://img.shields.io/badge/Security-Dependabot%20Active-success)](https://github.com/ivancarlosti/gwauditor/security/advisories)
[![Code of Conduct](https://img.shields.io/badge/Code%20of%20Conduct-View%20Here-purple)](https://github.com/ivancarlosti/gwauditor/CODE_OF_CONDUCT.md)
[![Contributor Covenant](https://img.shields.io/badge/Code%20of%20Conduct-1.4-4baaaa)](https://github.com/ivancarlosti/gwauditor/CODE_OF_CONDUCT.md)

This script collects users, groups, mailboxes delegation, Shared Drives, YouTube accounts, Analytics accounts, policies of a [Google Workspace](https://workspace.google.com/) environment on .xlsx file for audit and review purposes, the file is archived in a .zip file including a screenshot with hash MD5 of the .xlsx file and the script executed. Note that it's prepared to run on [GAM](https://github.com/GAM-team/GAM/) configured for multiple projects, change accordly if needed. This project also offer extra features:
- Archive mailbox messages to group
- List, add or remove mailbox delegation

Set variables if different of defined:
```
$GAMpath = "C:\GAM7"
$gamsettings = "$env:USERPROFILE\.gam"
$destinationpath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
```

`$GAMpath` defines the GAM application folder

`$gamsettings` defines the settings folder of GAM

`$destinationpath` defines the location were script result is saved

Check `testing-guideline.md` file as suggestion for testing guideline

You can find scripts related to mailbox delegation and mailbox archive to group in `Other scripts` folder

## Instructions
* Save all .ps1 files locally (download [here](https://github.com/ivancarlosti/gwauditor/zipball/master))
* Change variables of `mainscript.ps1` if needed
* Run `mainscript.ps1` on PowerShell (right-click on file > Run with PowerShell)
* Follow instructions selecting project name, option 1 to generate audit report and collect .zip file on `$destinationpath`

## Screenshots
*parts ommited on screenshots are related to project/profile name

![image](https://github.com/user-attachments/assets/489b37e0-c042-4df2-9ac9-4f5871a8d95f)
*Script startup*

![image](https://github.com/user-attachments/assets/08cb9aab-cb7a-4444-bf1e-f32a518ba190)
*Script completed*

![image](https://github.com/user-attachments/assets/6d642c0c-dfd8-4810-b674-6280b81857ce)
*.zip file content*

## Requirements
* Windows 10+ or Windows Server 2019+
* [GAM v7+](https://github.com/GAM-team/GAM/) using multiproject setup 
* PowerShell
* Module `ImportExcel` on PowerShell (not required to run extra features)

---

## Consulting and technical support
* For personal support and queries, please submit a new issue to have it addressed.
* For commercial related questions, please contact me directly forconsulting costs. 

## Project support
| If you found this project helpful, consider |
| :---: |
[**buying me a coffee**][buymeacoffee], [**donate by paypal**][paypal], [**sponsor this project**][sponsor] or just [**leave a star**](../..)⭐
|Thanks for your support, it is much appreciated!|

## License
[MIT](LICENSE) © [Ivan Carlos][ivancarlos]

[cc]: https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/adding-a-code-of-conduct-to-your-project
[contributing]: https://docs.github.com/en/articles/setting-guidelines-for-repository-contributors
[security]: https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository
[support]: https://docs.github.com/en/articles/adding-support-resources-to-your-project
[it]: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository#configuring-the-template-chooser
[prt]: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository
[funding]: https://docs.github.com/en/articles/displaying-a-sponsor-button-in-your-repository
[ivancarlos]: https://ivancarlos.me
[buymeacoffee]: https://www.buymeacoffee.com/ivancarlos
[paypal]: https://icc.gg/donate
[sponsor]: https://github.com/sponsors/ivancarlosti
