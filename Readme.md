![](code-orange-heading.png)

# What
Code Orange is a script and files to set the Visual Studio Code icon to orange, as it was when originally released.

# Why
I never understood why so many developers--people who generally have no visual design sense--decided that the orange Visual Studio Code icon was where they would take their stand.

I *liked* the orange, for a few reasons:
1.  It stood out from my purple Visual Studio icon.
2.  It was bold.
3.  I don't have some childhood trauma related to orange.

[Visual Studio Code September 2017](https://code.visualstudio.com/updates/v1_17#_new-visual-studio-code-logo) <= The introduction of the orange icon

[The Icon Journey](https://code.visualstudio.com/blogs/2017/10/24/theicon) <= The reversion to blue

[My blog post about Code Orange](https://www.softwaremeadows.com/posts/tidbits_vs_code-_orange_icon_resurrection/)

# Installation
**Required files**    
*	CodeOrange.ps1
*	code_70x70.png
*	code_150x150.png
*	code_file.ico

**Steps**    
1.	Clone or download the repository. Keep the icons and the Powershell script in a folder together.
2.	Run the Powershell script.

The script does the following
1.	Copies the orange icons to the appropriate folder.
2.	Updates the Visual Studio Code registry settings to point to the orange icons.
3.	Optionally creates a shortcut on the Desktop.
4.	Attempts to update the icon cache so that the new icon is shown immediately. If this doesn't work, you should restart your computer.

To have an orange icon in your taskbar, drag the shortcut from the Desktop onto the taskbar and you'll be prompted to pin it. You only need to do this the first time.

# Caveats
On Windows, it's not practical to change the icon completely back to orange. That would require modifying the code.exe file. But you can get most of the way there. The script will change the icon for:

1.  Right-click folder/file > Open with VS Code
2.  Right-click pinned shortcut > Visual Studio Code
3.  Shortcut

It won't change the icon in the VS Code editor, or in context menu `Right-click pinned shortcut > New Window`

# Change History

**2018-09-08**  
The script now prompts for whether to create the desktop shortcut+icon. In most cases, after the first run, you won't need to. It also refreshes the icon cache, so you should see the change immediately.

**2018-08-19**  
I improved the script to manage the entire icon replacement, and am handling the recent change to VS Code using a user-profile-based install.
