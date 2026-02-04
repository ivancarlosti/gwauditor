<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

### How to Fix "Running Scripts is Disabled on this System" in PowerShell

PowerShell is blocking your script due to its execution policy settings, which are in place for security reasons. You can change these settings easily to allow your script to run.

#### **Recommended Steps**

1. **Open PowerShell as Administrator**
    - Click Start, search for PowerShell.
    - Right-click and select **Run as Administrator**.
2. **Check Current Execution Policies**
    - Run:

```
Get-ExecutionPolicy -List
```

    - This displays the policies for each scope (see table below for explanations).
3. **Unblock Script Execution for Your User**
    - To allow scripts for your user only (safest):

```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

        - *RemoteSigned* allows scripts you write and scripts downloaded from the internet if they are signed.
4. **If You Need to Allow All Scripts (Less Secure)**
    - Run:

```
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```

        - This will allow any script to run, regardless of source. Use only if you trust the scripts you’re executing.
5. **Confirm Security Prompts**
    - If prompted, press **Y** to confirm or type **A** (if asked) to accept all future changes[^1_1][^1_2][^1_3].

#### **If You Still Get the Error (Group Policy Enforced)**

If changing the execution policy doesn’t work, your system might have a Group Policy overriding this setting:

- Press `Win + R`, type `gpedit.msc`, and press Enter.
- Navigate to:

```
Local Computer Policy > Computer Configuration > Administrative Templates > Windows Components > Windows PowerShell
```

- Double-click **Turn on Script Execution**.
- Set it to **Enabled** and choose **Allow all scripts** (or less permissive option if desired)[^1_1][^1_4].


#### **Execution Policy Scopes Explained**

| Scope | Description |
| :-- | :-- |
| MachinePolicy | Enforced by Group Policy for entire machine |
| UserPolicy | Enforced by Group Policy for current user |
| Process | Applies only to current PowerShell session |
| CurrentUser | Applies to scripts run by current Windows user |
| LocalMachine | Applies to all users on the computer |

*Execution policies set at higher scopes (MachinePolicy, UserPolicy) override lower scopes (CurrentUser, LocalMachine)[^1_5].*

#### **Quick Troubleshooting**

- If only running a script once, you can bypass the policy by running:

```
powershell -ExecutionPolicy Bypass -File .\mainscript.ps1
```

- Use `RemoteSigned` or `Unrestricted` mindfully, as they lower script execution restrictions.

**Note:** Always revert your execution policy to the original or a safer state (such as `Restricted`) after running untrusted or experimental scripts for security[^1_6][^1_5].

**References:**
Information sourced directly from Microsoft documentation and community troubleshooting discussions[^1_1][^1_2][^1_5][^1_3].

<div style="text-align: center">⁂</div>

[^1_1]: https://stackoverflow.com/questions/4037939/powershell-says-execution-of-scripts-is-disabled-on-this-system

[^1_2]: https://www.addictivetips.com/windows-tips/fix-running-scripts-is-disabled-on-this-system-powershell-on-windows-10/

[^1_3]: https://techpress.net/powershell-running-scripts-is-disabled-on-this-system-error/

[^1_4]: https://learn.microsoft.com/en-us/answers/questions/506985/powershell-execution-setting-is-overridden-by-a-po

[^1_5]: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.5

[^1_6]: https://www.youtube.com/watch?v=ChRef6Z8UD4

[^1_7]: https://answers.microsoft.com/en-us/windows/forum/all/cannot-get-powershell-script-to-run/900edc39-35e8-4896-92d0-05aad75eac87

[^1_8]: https://superuser.com/questions/106360/how-to-enable-execution-of-powershell-scripts

[^1_9]: https://learn.microsoft.com/en-us/answers/questions/3740158/cannot-get-powershell-script-to-run

[^1_10]: https://adamtheautomator.com/set-executionpolicy/

[^1_11]: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.5

[^1_12]: https://www.youtube.com/watch?v=N2Axkw00Flg

[^1_13]: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.5\&rut=459b26fec52a14755fbe25de9c676e1e9b897f03730570c69e5b368ad8ae747c

[^1_14]: https://dev.to/jackfd120/resolving-npm-execution-policy-error-in-powershell-a-step-by-step-guide-for-developers-32ip

[^1_15]: https://www.softwareverify.com/blog/enabling-and-disabling-powershell-script-execution/

[^1_16]: https://learn.microsoft.com/pt-br/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.5

[^1_17]: https://lazyadmin.nl/powershell/running-scripts-is-disabled-on-this-system/

[^1_18]: https://tecadmin.net/powershell-running-scripts-is-disabled-system/

[^1_19]: https://stackoverflow.com/questions/41117421/ps1-cannot-be-loaded-because-running-scripts-is-disabled-on-this-system

[^1_20]: https://sentry.io/answers/bypass-and-set-powershell-script-execution-policies/

