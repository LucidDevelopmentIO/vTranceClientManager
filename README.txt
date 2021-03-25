Current Features:

Auto Login/Character Selection
Round-Robin Click Broadcast To Slaves
"!shop" on all Clients
"!points" on all Clients
Window Position/Title Change
Closing of all Clients
Click X/Y repeatably. I.e for Scrolls/Bread [No higher then 20 in Config or you'll regreat it] 


Set-Up:

(Have vTrance Dofus Client Quality set to "Average"/"Medium" Along with general 800x600 Window Size) 

1. Extract the vTrance Account&Window Manager folder onto your desktop/where ever you want.
2. Open Config.ini with Notepade/Another Reader
3. Edit Key "Path" for your vTrance Dofus.exe Example shown in Config.
4. Edit Key "Clicks" this is for Click X/Y repeatably feature. Don't set this higher then 20.
5. Run the vTrance Account&Window Manager.exe (or .ahk if you want to run source ahk must be downloaded)
6. Once the program is loaded, right click the table and click "Add Account"
7. Add your account details, login/password. Then, click "Add Character".
8. Pop-up input window is now shown. Enter your character's name. This is always shown as the windows Title. 
    Examples are; Lucid (Window Shown: Dofus-Lucid) Lucid-Iop (Window Shown: Dofus-Lucid-Iop) 
9. Enter your character slot. If it's your first character, then "1", so-forth.
10. Drop-down "Character" should be selected with the new character. If it is not, select it. You can add all your characters for this account. Once done, Click "Save n Close".
11. Click "Refresh Table" due to unknown bug I didn't want to track down, the table will not auto-refresh. You must do this manually. 
12. Right Click an account name then > Edit Account can edit the data here. 
13. Once all your Accounts and Characters are added+selected, select (either Ctrl+Click which one's you want - OR - Shift+Click Top Account + Bottom Account for all) the accounts and click "Launch Selected". This is now open X Dofus Client's login, select the character and position the window+rename the window.
14. Once your Characters are launched and logged in, position the windows how you would like them saved. Once they're positioned, click "Save Positions" on the Program. X, Y, W, H are now added to the table + recorded in Config.ini


You must be using the updated client for logins to work!
Hotkeys: (Download the correct one or either and edit it yourself)

Both:
Ctrl+Escape: Terminate Program
Ctrl+1: Sends "!shop"
Ctrl+2: Sends "!points"
Mouse Button 1 || Ctrl+LButton => Round-House Click On Slave Windows
Mouse Button 2 || Alt+LButton:: Click X/Y repeatably



Let me know if you have any problems/questions. 


Tips/Known Bugs: 
0. Have vTrance Dofus Client Quality set to "Average"
1. Have Display all mobs turned off in settings. 
2. When using the Round-Robin Click Broadcast To Slaves in a "walking" distance, click the corners of the tiles. 
    This is because once client might select another clients character instead of moving.
3. Your own Connection speed. You might have to increase the scripts Sleep if you get infiniate loading. 
    Sleep Lines: 
        127 -> Sleep, 550 (Sleep between Game Client Launches)
        168 -> Sleep, 1500 (Sleep between Server Connection (Server Selection))