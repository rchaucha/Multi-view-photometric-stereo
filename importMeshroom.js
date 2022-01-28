var fs = require('fs');
var path = process.argv[2];

var data = JSON.parse(fs.readFileSync(path,'utf-8'));

var text = '';
var f = data.intrinsics[0].pxFocalLength;
var x0 = data.intrinsics[0].principalPoint[0];
var y0 = data.intrinsics[0].principalPoint[1];

text += 'uid = [];\n\n';
text += 'pathToPictures = {};\n\n';

text += 'K = [' + f +' 0 ' + x0 + ';\n 0 ' + f + ' ' + y0 + ';\n 0 0 1];\n\n'

for (var poseIndex = 0; poseIndex < data.poses.length; poseIndex++) {

    var currentPose = data.poses[poseIndex];

    var currentId = currentPose.poseId;
    text += 'uid(' + (poseIndex + 1) + ') = ' + currentId + ';\n\n';
    
    for(var viewInd = 0;  viewInd < data.views.length; viewInd++){
        var currentView = data.views[viewInd];
        if(currentView.poseId == currentId){
            var currentPath = currentView.path;
        }
    }
    text += 'pathToPictures{' + (poseIndex + 1) + '} = "' + currentPath + '";\n\n'; 
    
    text += 'R_complete(:,:,' + (poseIndex + 1) + ') = [';
    
    for (var rowIndex = 0; rowIndex < currentPose.pose.transform.rotation.length; rowIndex++) {
    
        var row = currentPose.pose.transform.rotation[rowIndex];
        if ((rowIndex + 1) % 3 != 0) {
            text += row + ' ';
        } else if((rowIndex + 1) == 9) {
            text += row + '];\n\n';
        } else {
            text += row + ';\n';
        }
    }
    text += 'C_complete(:,' + (poseIndex + 1) + ') = [';
    text += currentPose.pose.transform.center.join(';') + '];\n\n\n';
}

console.log(text);
