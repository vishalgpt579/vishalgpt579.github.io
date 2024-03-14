# Hardware notes

## Hardware IP:

- Jetson Tx2: 172.22.22.1
- UR5: 172.22.22.2
- LIDAR: 172.22.22.3
- Acer Predator / Host Laptop: 172.22.22.4

## UR5

### Packages neeeded

- _[Univeral Robot](https://github.com/fmauch/universal_robot) by fmauch_

- _[Universal_Robots_ROS_Driver](https://github.com/UniversalRobots/Universal_Robots_ROS_Driver)_

>  Reminber: shayak_bot package needs to be in another workspace to avoid UR5 robot conflict. For final implementation remove UR5 meta-package from sahayak_bot package.


### Communication

- To communicate with UR5,
	- Connect ethernet from the bottom on the controller box to tx2 (For not with Lab laptop no 5)
	- Tx2 side (Host side)
		- Make sure 2 packages are present inside the workspace
		- run 
```bash
roslaunch ur_robot_driver ur5_bringup.launch robot_ip:=172.22.22.2 kinematics_config:=${HOME}/my_robot_calibration.yaml
```
	- UR5 side
		- Start `URCap` node, by starting the `rosStartup.urcap` file. 
		- Wait for tx2 to start the comm


	
> Changes made:
* Inside `ur5_moveit_config/controllers.yaml`
```xml
action_ns: /scaled_pos_joint_traj_controller/follow_joint_trajectory
```
* No remapping needed between `/follow_joint_trajectory` & `/scaled_pos_joint_traj_controller/follow_joint_trajectory`, comment that line inside `ur5_moveit_config/launch/ur5_moveit_planning_execution.launch` .

#### Starting `rosStart.urp` automatically

```bash
rosservice call /ur_hardware_interface/dashboard/play
```

#### Stopping any program
```bash
rosservice call /ur_hardware_interface/dashboard/stop
```
### Gripper Controlling

- To Close the gripper, call `/ur_hardware_interface/set_io` service with following .. 
```bash
rosservice call /ur_hardware_interface/set_io "fun: 1
pin: 16
state: 1.0"
```
- To open
```bash
rosservice call /ur_hardware_interface/set_io "fun: 1
pin: 16
state: 0.0" 
```
- Speed control, keep Pin 17 high for slow gripping action(recommended) and low otherwise.
```bash
rosservice call /ur_hardware_interface/set_io "fun: 1
pin: 17
state: 1.0"
```

> TO DO - controlling the gripping lenght with analog voltage, check out service message type [ur_msgs/SetIO](http://docs.ros.org/en/kinetic/api/ur_msgs/html/srv/SetIO.html) and [grippers manual](file:///tmp/mozilla_vishal0/RG2_User__Manual_enEN_V1.9.2.pdf) on page 13.  

### UR5 planning

- Once UR5 have successfully connected, run the following line to start MoveIt planner.

```bash
roslaunch ur5_moveit_config ur5_moveit_planning_execution.launch
```

```bash
roslaunch ur5_moveit_config moveit_rviz.launch config:=true
```
> To DO: add cuboids in UR5 description as replacement for gripper and camera ! **VERY IMPORTANT, DO NOT IMPLEMENT MANY TESTS BEFORE PERFORMING THIS TASK**

## LIDAR

- Model: TiM561-2050101
- Data connection: Ethernet (IP: 172.22.22.3)
- Power connection: Connector M12, 5-pin, A-coded
	- Input: 9V - 28V (Brown wire)
	- Gnd: Blue wire
	- Reference : [Website](https://www.sick.com/in/en/detection-and-ranging-solutions/2d-lidar-sensors/tim5xx/tim561-2050101/p/p369446), [datasheet](https://cdn.sick.com/media/pdf/6/46/446/dataSheet_TiM561-2050101_1071419_en.pdf)

- Command to start the node
```bash
roslaunch sick_scan sick_tim_5xx.launch hostname:=172.22.22.3
```
> 10K and 35K ke lidar se bhi kam ho jayega - Soofiyan .

## Mapping methodoly

Mapping was done using "ROS multiple system", where after many iteration jetson Tx2 was assigned the master and my laptop was assigned as a host

### Connection

> Remember both the host and the Master should have similar kind of OS and packages to run "ROS mutliple system".

- In Master macchine, inside `bashrc` we change the address of the Rosmaster. Inside bashrc following lines were added.
```bashrc
export ROS_MASTER_URI=http;//172.22.22.1:11311
export ROS_IP=172.22.22.1
```

- In the host master, in this case Acer Laptop, add the following lines inside `bashrc`.
```bashrc
export ROS_MASTER_URI=http;//172.22.22.1:11311
export ROS_IP=172.22.22.4
```

- Once both, master and host are inside a network. Since the tx2 is already running rosmaster at `172.22.22.1` and publishing data on port `11311`, all we needs to be no the host side is to run `roscore`. All the data will be availablle.

> Note: Ethernet network is preferred over wifi for mapping since the laser scan updation rate and mapping speed might not match.

### Gmapping 

- Testing were done on first floor of KreSIT building, the results were _okay-ish_

- However, for larger area error accumulation over time is too great. Soofiyan and Simrannjeet have recommended to use [slam_toolkit](https://github.com/SteveMacenski/slam_toolbox), [slam_cartography](http://wiki.ros.org/cartographer). 

#### testing single bag file with different mapping techniques
- Record bag file with following data
	- `/tf`
	- `/tf_static`
	- `/scan`
	- `/odom`
	- `/imu`
	- `/orientation`

- Apparently, even if we record `/tf` or `/tf_static`, that hold the structural data of the bot's sensors and its joints. Rosbag is not capable to replay them in desired manner.

