# PowershellProfile
My powershell profile (type phelp to see available commands)

```
=== Custom PowerShell Profile Help ===

⚙️ Profile
  h / phelp     -> Open this list of commands
  edit-profile  -> Open this profile in editor
  rl / reload   -> Restart Windows Terminal

🧠 Git shortcuts
  gitinit       -> git init/add ./commit
  lazyg         -> git add/commit/push

📦 System / Updates
  admin         -> Restart terminal as Administrator
  update        -> Upgrade all winget packages
  cleantmp      -> Clean ~\AppData\Local\Temp
  cleantrash    -> Clean Recycle Bin

📁 Navigation
  ..            -> Shortcut for 'cd ..'
  ... / cd...   -> Go up 2 directories
  .... / cd.... -> Go up 3 directories
  back          -> Go back to previous directory
  home          -> Go to User Home directory
  desktop       -> Go to Desktop
  documents     -> Go to Documents
  open          -> Open current directory in File Explorer

📄 File Utilities
  unzip <file>  -> Unzip an archive
  grep          -> Search text in files
  touch         -> Create empty file
  find          -> Search files by name
  sha1 / sha256 -> File hashes
  files         -> List only files in current folder
  tree          -> List dirs/files in a tree like format
  findandreplace <file> <find> <replace> -> Replaces all occurrences of a string inside a file

🌐 Network
  download <url> -> Download file to Desktop (wget -c)
  ip            -> Show public IP
  dns <name>    -> Get public IP of a domain name
  http <url>    -> HTTP check
  ports         -> Check open ports

🔧 Utilities
  history <regex> -> Show commandline history
  size          -> Show size of current directory (size of accessible files only)
  sizes         -> Show sizes of directories in current location
  which         -> Show command path
  uptime        -> System uptime
  export <name> <value> -> Creates or updates an environment variable for the current session
  pkill <process-name> -> Kills all processes matching a name

======================================
```
