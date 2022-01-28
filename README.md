# Multi-view photometric stereo

## Goal
The goal of this project is to use PS with multiple camera poses, in opposition to usual PS where only the light is moving.
Here, we suppose that the light comes from the built-in flash of the camera, assuming that the light and the camera positions are the same.


## Terminology
PS : photometric stereo
SfM : Structure from motion
MVS : Multi-view stereoscopy


## Process
First step :
- Computation of cameras poses and height of scattered points using the SfM of Meshroom
- Projection of these 3D points into each image (of each camera). We only keep points that are visible from all cameras
- Application of photometric stereo algorithm for these points to get surface normals
- Concurrently, run the Meshroom MVS algorithm to get a 3D mesh of the scene that we can use to compute vertices normals
- We then compute the angle between the two normals for each point and plot them on a heatmap to see where the difference is the biggest
Note : since SfM points are not the same as the MVS ones, we have to find for each SfM point the nearest MVS one.

Second step :
The same idea is applied, but this time we first launch MVS to get a dense point cloud which we then use to compute normals using PS.
Advantage : We get more normals to compare, and they are at the exact same points
Drawback : The PS is based on the height of each point computed using MVS, which is not ideal. The resulting normals won't be as accurate.


## Test on computer-generated images
Synthetic images generated using https://github.com/bbrument/lambertianRendering_v1.

Launch test_synthese.m


## Test on real data
Launch test_real_sfm.m to use only the nearest MVS points to the ones found by SfM
Launch test_real_mvs.m to use all MVS points
