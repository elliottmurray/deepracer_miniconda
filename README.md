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

## Reward Function

A reward function describes immediate feedback (as a reward or penalty score) when your AWS DeepRacer vehicle moves from one position on the track to a new position. The function's purpose is to encourage the vehicle to make moves along the track to reach a destination quickly without accident or infraction.

### Environment Observations Params

[Input Parameters of the AWS DeepRacer Reward Function](https://docs.aws.amazon.com/deepracer/latest/developerguide/deepracer-reward-function-input.html)

```js
{
    "all_wheels_on_track": Boolean,    # flag to indicate if the vehicle is on the track
    "x": float,                        # vehicle's x-coordinate in meters
    "y": float,                        # vehicle's y-coordinate in meters
    "distance_from_center": float,     # distance in meters from the track center 
    "is_left_of_center": Boolean,      # Flag to indicate if the vehicle is on the left side to the track center or not. 
    "heading": float,                  # vehicle's yaw in degrees
    "progress": float,                 # percentage of track completed
    "steps": int,                      # number steps completed
    "speed": float,                    # vehicle's speed in meters per second (m/s)
    "steering_angle": float,           # vehicle's steering angle in degrees
    "track_width": float,              # width of the track
    "waypoints": [[float, float], … ], # list of [x,y] as milestones along the track center
    "closest_waypoints": [int, int]    # indices of the two nearest waypoints.
}
```

AWS provides some example for rewarding particular behavior

### Follow the center line

This example determines how far away the agent is from the center line and gives higher reward if it is closer to the center of the track. It will incentivize the agent to closely follow the center line.

```python
def reward_function(params):
    '''
    Example of rewarding the agent to follow center line
    '''

    # Read input parameters
    track_width = params['track_width']
    distance_from_center = params['distance_from_center']

    # Calculate 3 markers that are at varying distances away from the center line
    marker_1 = 0.1 * track_width
    marker_2 = 0.25 * track_width
    marker_3 = 0.5 * track_width

    # Give higher reward if the car is closer to center line and vice versa
    if distance_from_center <= marker_1:
        reward = 1.0
    elif distance_from_center <= marker_2:
        reward = 0.5
    elif distance_from_center <= marker_3:
        reward = 0.1
    else:
        reward = 1e-3  # likely crashed/ close to off track

    return float(reward)
```

### Stay inside the two borders

This example simply gives high rewards if the agent stays inside the borders and lets the agent figure out what is the best path to finish a lap. It is easy to program and understand, but will be likely to take longer time to converge.

```python
def reward_function(params):
    '''
    Example of rewarding the agent to stay inside the two borders of the track
    '''

    # Read input parameters
    all_wheels_on_track = params['all_wheels_on_track']
    distance_from_center = params['distance_from_center']
    track_width = params['track_width']

    # Give a very low reward by default
    reward = 1e-3

    # Give a high reward if no wheels go off the track and
    # the agent is somewhere in between the track borders
    if all_wheels_on_track and (0.5*track_width - distance_from_center) >= 0.05:
        reward = 1.0

    # Always return a float value
    return float(reward)
```
### Prevent zig-zag

This example incentivizes the agent to follow the center line but penalizes with lower reward if it steers too much, which will help prevent zig-zag behavior. The agent will learn to drive smoothly in the simulator and likely display the same behavior when deployed in the physical vehicle.

```python
def reward_function(params):
    '''
    Example of penalize steering, which helps mitigate zig-zag behaviors
    '''

    # Read input parameters
    distance_from_center = params['distance_from_center']
    track_width = params['track_width']
    steering = abs(params['steering_angle']) # Only need the absolute steering angle

    # Calculate 3 markers that are at varying distances away from the center line
    marker_1 = 0.1 * track_width
    marker_2 = 0.25 * track_width
    marker_3 = 0.5 * track_width

    # Give higher reward if the agent is closer to center line and vice versa
    if distance_from_center <= marker_1:
        reward = 1
    elif distance_from_center <= marker_2:
        reward = 0.5
    elif distance_from_center <= marker_3:
        reward = 0.1
    else:
        reward = 1e-3  # likely crashed/ close to off track

    # Steering penality threshold, change the number based on your action space setting
    ABS_STEERING_THRESHOLD = 15

    # Penalize reward if the agent is steering too much
    if steering > ABS_STEERING_THRESHOLD:
        reward *= 0.8

    return float(reward)
```

## Hyperparameter

