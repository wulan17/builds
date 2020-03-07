# How To Use: #

 ### Clone ###
 ```bash
 git clone https://github.com/wulan17/builds.git && cd builds
 ```
 
 ### Setup ###
 ```bash
 nano config.sh
 ```
 
 ### Start Build ###
 ```bash
 bash start.sh
 ```
 
 #### Additional Arguments: ####
 ```bash
 bash start.sh $1 $2
   prepare : Re-Init Repo, Re-sync source and build
   sync : Re-sync source and build
   clean : Clean out dir and build 
 ```

 ```bash
 example :
  bash start.sh prepare # Re-init w/o cleaning
  bash start.sh prepare clean # Re-init w/ cleaning
  bash start.sh clean # cleaning and build
 ```

---------------------------------------------------------------------------------------
 Credits:
 =======
[github-release](https://github.com/c4milo/github-release)  
[Telegram API](https://core.telegram.org/api)
---------------------------------------------------------------------------------------


