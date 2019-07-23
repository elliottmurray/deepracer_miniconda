# Setup

## Requirements
* git > 2.13
* docker and docker-compose installed
* aws credentials and a profile created locally 

## Install
To clone this it has a git submodule so if you have git more recent than 2.13 you can use

```
git clone --recurse-submodules -j8 git@github.com:elliottmurray/deepracer_miniconda.git 
```

Make sure you have a named profile created in your aws credentials file

Ensure you have a suitable environment variable for AWS_DEFAULT_PROFILE (should match the profile)

Run
```
docker-compose up
```

## Run
The output should give you a url with a token. Navigate to
```
http://localhost:8888
```
and enter the token.

Open a notebook and make sure it is running python3 deepracer kernel

Open Notebook:
log-anaylsis/DeepRacer Log Analysis.ipynb

Shift enter on a cell executes it
You will need to make one small change. In the 5th executable cell there will be
```
stream_name = 'MY_SIM_ID' ## CHANGE This to your simulation application ID
```

Change this. If you look at your training run you should somewhere see ![Alt text](screenshot.png?raw=true "Deepracer training") and where the simulation log id is (in this case sim-xkts5y54qn7r) copy that in. If you train a new model you might have to change this. Check the fname variable is not being overridden later. Had some bugs with this 

